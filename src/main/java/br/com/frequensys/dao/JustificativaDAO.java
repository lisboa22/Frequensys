package br.com.frequensys.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import br.com.frequensys.model.Funcionario;
import br.com.frequensys.model.Justificativa;
import br.com.frequensys.model.RegistroFrequencia;
import br.com.frequensys.model.Usuario;

/**
 * DAO responsável pelas operações de persistência da entidade Justificativa.
 *
 * CORREÇÕES APLICADAS:
 * 1. listarJustificativas(): JOIN simples no aprovador trocado por LEFT JOIN —
 *    sem isso justificativas com status PENDENTE (idAprovador = NULL) nunca apareciam.
 * 2. listarPorStatus(): SQL completamente reescrito (havia vírgulas faltando
 *    e aliases errados que causavam SQLException).
 * 3. atualizarStatus(): coluna "idUsuarioAprovador" corrigida para "idAprovador".
 * 4. mapear(): aliases alinhados com todos os SELECTs; guard wasNull() protege
 *    o LEFT JOIN do aprovador.
 *
 * SUPORTE AO RELATÓRIO DE JUSTIFICATIVAS:
 * - listarJustificativasFiltradas(): filtros dinâmicos por funcionário, tipo,
 *   status e faixa de dataInicio, usados pelo RelatorioJustificativaController.
 * - contarJustificativasPorMes() / listarAnosJustificativa(): alimentam o
 *   gráfico "Justificativas por Mês" e o seletor de ano.
 */
public class JustificativaDAO {

    private Connection conexao;

    public JustificativaDAO(Connection conexao) {
        this.conexao = conexao;
    }

    // ==========================
    // ADICIONAR
    // ==========================

    public void adicionarJustificativa(Justificativa justificativa) throws Exception {
        String sql = "INSERT INTO justificativa "
                   + "(idFuncionario, idRegistro, tipo, descricao, dataInicio, dataFim, "
                   + " documentoComprovante, status, idAprovador) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1, justificativa.getFuncionario().getId());
        stmt.setInt(2, justificativa.getRegistro().getId());
        stmt.setString(3, justificativa.getTipo());
        stmt.setString(4, justificativa.getDescricao());
        stmt.setDate(5, justificativa.getDataInicio() != null
                        ? Date.valueOf(justificativa.getDataInicio()) : null);
        stmt.setDate(6, justificativa.getDataFim() != null
                        ? Date.valueOf(justificativa.getDataFim()) : null);
        stmt.setString(7, justificativa.getDocumentoComprovante());
        stmt.setString(8, justificativa.getStatus());

        if (justificativa.getAprovador() != null && justificativa.getAprovador().getId() > 0) {
            stmt.setInt(9, justificativa.getAprovador().getId());
        } else {
            stmt.setNull(9, java.sql.Types.INTEGER);
        }

        stmt.executeUpdate();
        stmt.close();
    }

    // ==========================
    // LISTAR TODOS
    // ==========================

    /**
     * CORREÇÃO: aprovador usa LEFT JOIN — justificativas PENDENTES têm
     * idAprovador NULL e eram excluídas silenciosamente com INNER JOIN.
     */
    public List<Justificativa> listarJustificativas() throws Exception {
        List<Justificativa> lista = new ArrayList<>();
        String sql = "SELECT j.id, j.tipo, j.descricao, j.dataInicio, j.dataFim, "
                   + "       j.documentoComprovante, j.status, "
                   + "       f.id  AS idFuncionario, f.nome AS nomeFuncionario, "
                   + "       r.id  AS idRegistro, "
                   + "       u.id  AS idAprovador,  u.nome AS nomeAprovador "
                   + "FROM justificativa j "
                   + "JOIN      funcionario        f ON f.id = j.idFuncionario "
                   + "JOIN      registrofrequencia r ON r.id = j.idRegistro "
                   + "LEFT JOIN usuario            u ON u.id = j.idAprovador "
                   + "ORDER BY j.id DESC";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        ResultSet rs = stmt.executeQuery();
        while (rs.next()) {
            lista.add(mapear(rs));
        }
        rs.close();
        stmt.close();
        return lista;
    }

    // ==========================
    // LISTAR POR STATUS
    // ==========================

    /**
     * CORREÇÃO: SQL inteiro reescrito — versão anterior tinha vírgulas faltando
     * entre colunas e aliases inconsistentes, causando SQLException em runtime.
     */
    public List<Justificativa> listarPorStatus(String status) throws Exception {
        List<Justificativa> lista = new ArrayList<>();
        String sql = "SELECT j.id, j.tipo, j.descricao, j.dataInicio, j.dataFim, "
                   + "       j.documentoComprovante, j.status, "
                   + "       f.id  AS idFuncionario, f.nome AS nomeFuncionario, "
                   + "       r.id  AS idRegistro, "
                   + "       u.id  AS idAprovador,  u.nome AS nomeAprovador "
                   + "FROM justificativa j "
                   + "JOIN      funcionario        f ON f.id = j.idFuncionario "
                   + "JOIN      registrofrequencia r ON r.id = j.idRegistro "
                   + "LEFT JOIN usuario            u ON u.id = j.idAprovador "
                   + "WHERE j.status = ? "
                   + "ORDER BY j.id DESC";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setString(1, status);
        ResultSet rs = stmt.executeQuery();
        while (rs.next()) {
            lista.add(mapear(rs));
        }
        rs.close();
        stmt.close();
        return lista;
    }

    // ==========================
    // BUSCAR POR ID
    // ==========================

    public Justificativa buscarPorId(int id) throws Exception {
        Justificativa j = null;
        String sql = "SELECT j.id, j.tipo, j.descricao, j.dataInicio, j.dataFim, "
                   + "       j.documentoComprovante, j.status, "
                   + "       f.id  AS idFuncionario, f.nome AS nomeFuncionario, "
                   + "       r.id  AS idRegistro, "
                   + "       u.id  AS idAprovador,  u.nome AS nomeAprovador "
                   + "FROM justificativa j "
                   + "JOIN      funcionario        f ON f.id = j.idFuncionario "
                   + "JOIN      registrofrequencia r ON r.id = j.idRegistro "
                   + "LEFT JOIN usuario            u ON u.id = j.idAprovador "
                   + "WHERE j.id = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, id);
        ResultSet rs = stmt.executeQuery();
        if (rs.next()) {
            j = mapear(rs);
        }
        rs.close();
        stmt.close();
        return j;
    }

    // ==========================
    // ALTERAR
    // ==========================

    public void alterarJustificativa(Justificativa justificativa) throws Exception {
        String sql = "UPDATE justificativa SET "
                   + "idFuncionario = ?, idRegistro = ?, tipo = ?, descricao = ?, "
                   + "dataInicio = ?, dataFim = ?, documentoComprovante = ?, "
                   + "status = ?, idAprovador = ? "
                   + "WHERE id = ?";
        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1, justificativa.getFuncionario().getId());
        stmt.setInt(2, justificativa.getRegistro().getId());
        stmt.setString(3, justificativa.getTipo());
        stmt.setString(4, justificativa.getDescricao());
        stmt.setDate(5, justificativa.getDataInicio() != null
                        ? Date.valueOf(justificativa.getDataInicio()) : null);
        stmt.setDate(6, justificativa.getDataFim() != null
                        ? Date.valueOf(justificativa.getDataFim()) : null);
        stmt.setString(7, justificativa.getDocumentoComprovante());
        stmt.setString(8, justificativa.getStatus());

        if (justificativa.getAprovador() != null && justificativa.getAprovador().getId() > 0) {
            stmt.setInt(9, justificativa.getAprovador().getId());
        } else {
            stmt.setNull(9, java.sql.Types.INTEGER);
        }

        stmt.setInt(10, justificativa.getId());
        stmt.executeUpdate();
        stmt.close();
    }

    // ==========================
    // ATUALIZAR STATUS
    // ==========================

    /**
     * CORREÇÃO: coluna era "idUsuarioAprovador" — corrigida para "idAprovador"
     * conforme estrutura real da tabela.
     */
    public void atualizarStatus(int id, String novoStatus, int idAprovador) throws Exception {
        String sql = "UPDATE justificativa SET status = ?, idAprovador = ? WHERE id = ?";
        try (PreparedStatement stmt = conexao.prepareStatement(sql)) {
            stmt.setString(1, novoStatus);
            stmt.setInt(2, idAprovador);
            stmt.setInt(3, id);
            stmt.executeUpdate();
        }
    }

    // ==========================
    // EXCLUIR
    // ==========================

    public void excluirJustificativa(int id) throws Exception {
        String sql = "DELETE FROM justificativa WHERE id = ?";
        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, id);
        stmt.executeUpdate();
        stmt.close();
    }

    // ── RELATÓRIO DE JUSTIFICATIVAS ─────────────────────────────────────────

    /**
     * Recupera justificativas aplicando filtros dinâmicos (todos opcionais).
     *
     * Utilizado pelo RelatorioJustificativaController para popular a tabela
     * de detalhamento e calcular os KPIs do relatório.
     *
     * @param idFuncionario filtro exato pelo funcionário (null = todos)
     * @param tipo          filtro exato pelo tipo ("ATESTADO", "FALTA", etc; null/branco = todos)
     * @param status        filtro exato pelo status ("PENDENTE"/"APROVADO"/"REPROVADO"; null/branco = todos)
     * @param dataInicio    data mínima de dataInicio no formato yyyy-MM-dd (opcional)
     * @param dataFim       data máxima de dataInicio no formato yyyy-MM-dd (opcional)
     * @return lista de justificativas que atendem aos filtros informados
     * @throws Exception em caso de erro SQL
     */
    public List<Justificativa> listarJustificativasFiltradas(Integer idFuncionario, String tipo, String status,
                                                               String dataInicio, String dataFim) throws Exception {
        List<Justificativa> lista = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
            "SELECT j.id, j.tipo, j.descricao, j.dataInicio, j.dataFim, "
          + "       j.documentoComprovante, j.status, "
          + "       f.id  AS idFuncionario, f.nome AS nomeFuncionario, "
          + "       r.id  AS idRegistro, "
          + "       u.id  AS idAprovador,  u.nome AS nomeAprovador "
          + "FROM justificativa j "
          + "JOIN      funcionario        f ON f.id = j.idFuncionario "
          + "JOIN      registrofrequencia r ON r.id = j.idRegistro "
          + "LEFT JOIN usuario            u ON u.id = j.idAprovador "
          + "WHERE 1=1 "
        );

        List<Object> parametros = new ArrayList<>();

        if (idFuncionario != null) {
            sql.append("AND j.idFuncionario = ? ");
            parametros.add(idFuncionario);
        }
        if (tipo != null && !tipo.isBlank()) {
            sql.append("AND j.tipo = ? ");
            parametros.add(tipo);
        }
        if (status != null && !status.isBlank()) {
            sql.append("AND j.status = ? ");
            parametros.add(status);
        }
        if (dataInicio != null && !dataInicio.isBlank()) {
            sql.append("AND j.dataInicio >= ? ");
            parametros.add(Date.valueOf(dataInicio));
        }
        if (dataFim != null && !dataFim.isBlank()) {
            sql.append("AND j.dataInicio <= ? ");
            parametros.add(Date.valueOf(dataFim));
        }

        sql.append("ORDER BY j.id DESC");

        PreparedStatement stmt = conexao.prepareStatement(sql.toString());
        for (int i = 0; i < parametros.size(); i++) {
            stmt.setObject(i + 1, parametros.get(i));
        }

        ResultSet rs = stmt.executeQuery();
        while (rs.next()) {
            lista.add(mapear(rs));
        }
        rs.close();
        stmt.close();
        return lista;
    }

    /**
     * Conta quantas justificativas foram abertas (dataInicio) em cada mês de um ano.
     *
     * Usado tanto na carga inicial do gráfico quanto pelo endpoint AJAX
     * "dadosGrafico", acionado ao trocar o ano no seletor.
     *
     * @param ano ano de referência (ex: 2026)
     * @return array de 12 posições (índice 0 = Janeiro ... 11 = Dezembro)
     * @throws Exception em caso de erro SQL
     */
    public int[] contarJustificativasPorMes(int ano) throws Exception {
        int[] justificativasPorMes = new int[12];

        String sql = "SELECT MONTH(dataInicio) AS mes, COUNT(*) AS total "
                   + "FROM justificativa "
                   + "WHERE YEAR(dataInicio) = ? "
                   + "GROUP BY MONTH(dataInicio)";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, ano);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            int mes   = rs.getInt("mes");
            int total = rs.getInt("total");
            if (mes >= 1 && mes <= 12) {
                justificativasPorMes[mes - 1] = total;
            }
        }

        rs.close();
        stmt.close();
        return justificativasPorMes;
    }

    /**
     * Lista, em ordem decrescente, os anos que possuem justificativas registradas
     * (com base em dataInicio). Alimenta o seletor de ano do gráfico.
     *
     * @return lista de anos distintos com justificativas
     * @throws Exception em caso de erro SQL
     */
    public List<Integer> listarAnosJustificativa() throws Exception {
        List<Integer> anos = new ArrayList<>();

        String sql = "SELECT DISTINCT YEAR(dataInicio) AS ano "
                   + "FROM justificativa "
                   + "WHERE dataInicio IS NOT NULL "
                   + "ORDER BY ano DESC";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            anos.add(rs.getInt("ano"));
        }

        rs.close();
        stmt.close();
        return anos;
    }

    // ==========================
    // MAPEAMENTO
    // ==========================

    /**
     * CORREÇÃO: aliases alinhados com todos os SELECTs.
     * Guard wasNull() garante que aprovador fique null quando LEFT JOIN não retorna linha.
     */
    private Justificativa mapear(ResultSet rs) throws SQLException {

        Funcionario funcionario = new Funcionario();
        funcionario.setId(rs.getInt("idFuncionario"));
        funcionario.setNome(rs.getString("nomeFuncionario"));

        RegistroFrequencia registro = new RegistroFrequencia();
        registro.setId(rs.getInt("idRegistro"));

        Usuario aprovador = null;
        int idAprov = rs.getInt("idAprovador");
        if (!rs.wasNull()) {
            aprovador = new Usuario();
            aprovador.setId(idAprov);
            aprovador.setNome(rs.getString("nomeAprovador"));
        }

        return new Justificativa(
            rs.getInt("id"),
            funcionario,
            registro,
            rs.getString("tipo"),
            rs.getString("descricao"),
            rs.getDate("dataInicio") != null ? rs.getDate("dataInicio").toLocalDate() : null,
            rs.getDate("dataFim")    != null ? rs.getDate("dataFim").toLocalDate()    : null,
            rs.getString("documentoComprovante"),
            rs.getString("status"),
            aprovador
        );
    }
}