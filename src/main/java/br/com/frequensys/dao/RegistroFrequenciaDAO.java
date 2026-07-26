package br.com.frequensys.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

import br.com.frequensys.model.RegistroFrequencia;

/**
 * DAO responsável pelas operações de persistência da entidade RegistroFrequencia.
 *
 * Esta classe centraliza toda a comunicação com o banco de dados referente
 * à tabela "registrofrequencia", implementando operações CRUD e consultas auxiliares.
 *
 * Responsabilidades:
 * - Inserir, atualizar, remover e consultar registros de frequência
 * - Filtrar registros por funcionário, turno e período
 *
 * Observações importantes:
 * - Utiliza PreparedStatement para segurança contra SQL Injection.
 * - O campo datahora é do tipo DATETIME no banco e LocalDateTime no Java.
 * - A conexão é fornecida externamente e não é gerenciada pela classe.
 */
public class RegistroFrequenciaDAO {

    private Connection conexao;

    /**
     * Construtor responsável por receber uma conexão ativa com o banco.
     *
     * @param conexao conexão JDBC previamente criada
     */
    public RegistroFrequenciaDAO(Connection conexao) {
        this.conexao = conexao;
    }

    /**
     * Insere um novo registro de frequência na base de dados.
     *
     * @param r objeto contendo os dados do registro
     * @throws Exception em caso de erro durante execução SQL
     */
    public void adicionarRegistro(RegistroFrequencia r) throws Exception {
        String sql = "INSERT INTO registrofrequencia "
                   + "(idFuncionario, datahora, idTurno, tipo, status, "
                   + " minutosatraso, minutossaidaantecipada, cargahorariacumprida, observacao) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1,       r.getIdFuncionario());
        stmt.setTimestamp(2, r.getDatahora() != null ? Timestamp.valueOf(r.getDatahora()) : null);
        stmt.setInt(3,       r.getIdTurno());
        stmt.setString(4,    r.getTipo());
        stmt.setString(5,    r.getStatus());
        stmt.setInt(6,       r.getMinutosatraso());
        stmt.setInt(7,       r.getMinutossaidaantecipada());
        stmt.setString(8,    r.getCargahorariacumprida());
        stmt.setString(9,    r.getObservacao());

        stmt.executeUpdate();
        stmt.close();
    }

    /**
     * Atualiza um registro de frequência existente na base de dados.
     *
     * Regra de negócio:
     * - A atualização ocorre com base no id do registro.
     *
     * @param r objeto contendo os novos dados (deve ter o id preenchido)
     * @throws Exception em caso de erro SQL
     */
    public void alterarRegistro(RegistroFrequencia r) throws Exception {
        String sql = "UPDATE registrofrequencia "
                   + "   SET idFuncionario          = ?, "
                   + "       datahora               = ?, "
                   + "       idTurno                = ?, "
                   + "       tipo                   = ?, "
                   + "       status                 = ?, "
                   + "       minutosatraso          = ?, "
                   + "       minutossaidaantecipada = ?, "
                   + "       cargahorariacumprida   = ?, "
                   + "       observacao             = ? "
                   + " WHERE id = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1,       r.getIdFuncionario());
        stmt.setTimestamp(2, r.getDatahora() != null ? Timestamp.valueOf(r.getDatahora()) : null);
        stmt.setInt(3,       r.getIdTurno());
        stmt.setString(4,    r.getTipo());
        stmt.setString(5,    r.getStatus());
        stmt.setInt(6,       r.getMinutosatraso());
        stmt.setInt(7,       r.getMinutossaidaantecipada());
        stmt.setString(8,    r.getCargahorariacumprida());
        stmt.setString(9,    r.getObservacao());
        stmt.setInt(10,      r.getId());

        stmt.executeUpdate();
        stmt.close();
    }

    /**
     * Remove permanentemente um registro de frequência do banco de dados.
     *
     * @param id identificador do registro
     * @throws Exception em caso de erro SQL
     */
    public void excluirRegistro(int id) throws Exception {
        String sql = "DELETE FROM registrofrequencia WHERE id = ?";
        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, id);
        stmt.executeUpdate();
        stmt.close();
    }

    /**
     * Recupera todos os registros de frequência cadastrados,
     * ordenados por datahora e id decrescentes.
     *
     * @return lista contendo todos os registros
     * @throws Exception em caso de erro de acesso ao banco
     */
    public List<RegistroFrequencia> listarRegistros() throws Exception {
        List<RegistroFrequencia> lista = new ArrayList<>();
        String sql = "SELECT * FROM registrofrequencia ORDER BY datahora DESC, id DESC";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            lista.add(mapear(rs));
        }

        rs.close();
        stmt.close();
        return lista;
    }

    /**
     * Busca um registro de frequência específico pelo ID.
     *
     * @param id identificador do registro
     * @return RegistroFrequencia encontrado ou null caso não exista
     * @throws Exception em caso de erro SQL
     */
    public RegistroFrequencia buscarPorId(int id) throws Exception {
        RegistroFrequencia r = null;
        String sql = "SELECT * FROM registrofrequencia WHERE id = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, id);
        ResultSet rs = stmt.executeQuery();

        if (rs.next()) {
            r = mapear(rs);
        }

        rs.close();
        stmt.close();
        return r;
    }

    /**
     * Lista todos os registros de frequência de um funcionário específico,
     * ordenados por datahora decrescente.
     *
     * @param idFuncionario identificador do funcionário
     * @return lista de registros do funcionário
     * @throws Exception em caso de erro SQL
     */
    public List<RegistroFrequencia> listarPorFuncionario(int idFuncionario) throws Exception {
        List<RegistroFrequencia> lista = new ArrayList<>();
        String sql = "SELECT * FROM registrofrequencia WHERE idFuncionario = ? ORDER BY datahora DESC";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idFuncionario);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            lista.add(mapear(rs));
        }

        rs.close();
        stmt.close();
        return lista;
    }

    /**
     * Lista registros de frequência de um funcionário dentro de um período de datas.
     *
     * Útil para geração de relatórios mensais ou consultas por intervalo.
     *
     * @param idFuncionario identificador do funcionário
     * @param inicio        data/hora inicial do período (inclusive)
     * @param fim           data/hora final do período (inclusive)
     * @return lista de registros no período informado
     * @throws Exception em caso de erro SQL
     */
    public List<RegistroFrequencia> listarPorFuncionarioEPeriodo(
            int idFuncionario, LocalDateTime inicio, LocalDateTime fim) throws Exception {

        List<RegistroFrequencia> lista = new ArrayList<>();
        String sql = "SELECT * FROM registrofrequencia "
                   + "WHERE idFuncionario = ? AND datahora BETWEEN ? AND ? "
                   + "ORDER BY datahora ASC";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1,       idFuncionario);
        stmt.setTimestamp(2, Timestamp.valueOf(inicio));
        stmt.setTimestamp(3, Timestamp.valueOf(fim));
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            lista.add(mapear(rs));
        }

        rs.close();
        stmt.close();
        return lista;
    }

    /**
     * Verifica se já existe um registro do tipo informado (ENTRADA ou SAÍDA)
     * para o funcionário na data atual (hoje).
     *
     * Usado para bloquear duplo registro de entrada ou saída no mesmo dia.
     *
     * @param idFuncionario identificador do funcionário
     * @param tipo          "ENTRADA" ou "SAÍDA"
     * @return true se já existe registro do tipo hoje, false caso contrário
     * @throws Exception em caso de erro SQL
     */
    public boolean verificarRegistroHoje(int idFuncionario, String tipo) throws Exception {
        String sql = "SELECT COUNT(*) FROM registrofrequencia "
                   + "WHERE idFuncionario = ? "
                   + "  AND tipo = ? "
                   + "  AND DATE(datahora) = CURDATE()";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1,    idFuncionario);
        stmt.setString(2, tipo.toUpperCase());
        ResultSet rs = stmt.executeQuery();

        boolean existe = false;
        if (rs.next()) {
            existe = rs.getInt(1) > 0;
        }

        rs.close();
        stmt.close();
        return existe;
    }

    /**
     * Lista todos os registros de frequência do funcionário na data atual (hoje),
     * ordenados por datahora crescente (ordem cronológica).
     *
     * Usado para popular a tabela de registros recentes na tela de ponto.
     *
     * @param idFuncionario identificador do funcionário
     * @return lista de registros do dia, em ordem cronológica
     * @throws Exception em caso de erro SQL
     */
    public List<RegistroFrequencia> listarRegistrosHojePorFuncionario(int idFuncionario)
            throws Exception {

        List<RegistroFrequencia> lista = new ArrayList<>();
        String sql = "SELECT * FROM registrofrequencia "
                   + "WHERE idFuncionario = ? "
                   + "  AND DATE(datahora) = CURDATE() "
                   + "ORDER BY datahora ASC";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idFuncionario);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            lista.add(mapear(rs));
        }

        rs.close();
        stmt.close();
        return lista;
    }

    // ── HELPER: converte ResultSet em objeto ──────────────────────────────────

    /**
     * Converte uma linha do ResultSet em um objeto RegistroFrequencia.
     *
     * @param rs ResultSet posicionado na linha a ser lida
     * @return objeto RegistroFrequencia preenchido
     * @throws SQLException em caso de erro de leitura do ResultSet
     */
    private RegistroFrequencia mapear(ResultSet rs) throws SQLException {
        RegistroFrequencia r = new RegistroFrequencia();

        r.setId(rs.getInt("id"));
        r.setIdFuncionario(rs.getInt("idFuncionario"));

        Timestamp ts = rs.getTimestamp("datahora");
        r.setDatahora(ts != null ? ts.toLocalDateTime() : null);

        r.setIdTurno(rs.getInt("idTurno"));
        r.setTipo(rs.getString("tipo"));
        r.setStatus(rs.getString("status"));
        r.setMinutosatraso(rs.getInt("minutosatraso"));
        r.setMinutossaidaantecipada(rs.getInt("minutossaidaantecipada"));
        r.setCargahorariacumprida(rs.getString("cargahorariacumprida"));
        r.setObservacao(rs.getString("observacao"));

        return r;
    }
}
