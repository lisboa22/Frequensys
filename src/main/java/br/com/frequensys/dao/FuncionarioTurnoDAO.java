package br.com.frequensys.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import br.com.frequensys.model.Funcionario;
import br.com.frequensys.model.FuncionarioTurno;
import br.com.frequensys.model.Turno;

/**
 * DAO responsável pelas operações de persistência da entidade FuncionarioTurno.
 *
 * Esta classe centraliza toda a comunicação com o banco de dados referente
 * à tabela "funcionarioturno", implementando operações CRUD completas.
 *
 * Estrutura da tabela funcionarioturno:
 * - idFuncionarioTurno (PK, auto_increment)
 * - idFuncionario      (FK → funcionario.id)
 * - idTurno            (FK → turno.id)
 * - dataInicio
 * - dataFim
 *
 * Responsabilidades:
 * - Inserir, atualizar, remover e consultar vínculos funcionário/turno.
 * - Realizar JOIN com "funcionario" e "turno" para popular os objetos aninhados.
 *
 * Observações importantes:
 * - Utiliza PreparedStatement para segurança contra SQL Injection.
 * - A conexão é fornecida externamente e não é gerenciada pela classe.
 * - dataInicio e dataFim são tratadas como java.sql.Date ↔ java.time.LocalDate.
 * - dataFim pode ser null (vínculo sem data de encerramento definida).
 */
public class FuncionarioTurnoDAO {

    private Connection conexao;

    /**
     * Construtor responsável por receber uma conexão ativa com o banco.
     *
     * @param conexao conexão JDBC previamente criada
     */
    public FuncionarioTurnoDAO(Connection conexao) {
        this.conexao = conexao;
    }

    // ==========================
    // ADICIONAR
    // ==========================

    /**
     * Insere um novo vínculo funcionário/turno na base de dados.
     *
     * A coluna idFuncionarioTurno é auto_increment — não é informada no INSERT.
     * As colunas corretas são idFuncionario e idTurno (FKs).
     *
     * @param ft objeto FuncionarioTurno a ser inserido
     * @throws Exception em caso de erro durante execução SQL
     */
    public void adicionarFuncionarioTurno(FuncionarioTurno ft) throws Exception {
        String sql = "INSERT INTO funcionarioturno (idFuncionario, idTurno, dataInicio, dataFim) "
                   + "VALUES (?, ?, ?, ?)";
        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1, ft.getFuncionario().getId());
        stmt.setInt(2, ft.getTurno().getId());
        stmt.setDate(3, ft.getDataInicio() != null ? Date.valueOf(ft.getDataInicio()) : null);
        stmt.setDate(4, ft.getDataFim()    != null ? Date.valueOf(ft.getDataFim())    : null);

        stmt.executeUpdate();
        stmt.close();
    }

    // ==========================
    // LISTAR
    // ==========================

    /**
     * Recupera todos os vínculos cadastrados com JOIN em funcionario e turno.
     *
     * Correções aplicadas:
     * - JOIN funcionario usa f.id = ft.idFuncionario (não ft.id)
     * - JOIN turno usa t.id = ft.idTurno (não t.idTurno)
     * - SELECT inclui ft.idFuncionarioTurno para identificar o registro
     *
     * @return lista contendo todos os registros de FuncionarioTurno
     * @throws Exception em caso de erro de acesso ao banco
     */
    public List<FuncionarioTurno> listarFuncionarioTurnos() throws Exception {
        List<FuncionarioTurno> lista = new ArrayList<>();

        String sql = "SELECT ft.idFuncionarioTurno, ft.dataInicio, ft.dataFim, "
                   + "       f.id AS idFuncionario, f.nome AS nomeFuncionario, f.matricula, "
                   + "       t.id AS idTurno, t.nome AS nomeTurno, "
                   + "       t.horaEntrada, t.horaSaida "
                   + "FROM funcionarioturno ft "
                   + "JOIN funcionario f ON f.id = ft.idFuncionario "
                   + "JOIN turno t       ON t.id = ft.idTurno "
                   + "ORDER BY ft.idFuncionarioTurno";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            lista.add(mapear(rs));
        }

        rs.close();
        stmt.close();
        System.out.println("Lista: "+lista);
        return lista;
        
    }

    // ==========================
    // BUSCAR POR ID
    // ==========================

    /**
     * Busca um vínculo específico pelo idFuncionarioTurno (PK), com JOIN em funcionario e turno.
     *
     * @param idFuncionarioTurno identificador do vínculo (PK auto_increment)
     * @return FuncionarioTurno encontrado ou null caso não exista
     * @throws Exception em caso de erro SQL
     */
    public FuncionarioTurno buscarPorId(int idFuncionarioTurno) throws Exception {
        String sql = "SELECT ft.idFuncionarioTurno, ft.dataInicio, ft.dataFim, "
                   + "       f.id AS idFuncionario, f.nome AS nomeFuncionario, f.matricula, "
                   + "       t.id AS idTurno, t.nome AS nomeTurno, "
                   + "       t.horaEntrada, t.horaSaida "
                   + "FROM funcionarioturno ft "
                   + "JOIN funcionario f ON f.id = ft.idFuncionario "
                   + "JOIN turno t       ON t.id = ft.idTurno "
                   + "WHERE ft.idFuncionarioTurno = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idFuncionarioTurno);
        ResultSet rs = stmt.executeQuery();

        FuncionarioTurno ft = null;
        if (rs.next()) {
            ft = mapear(rs);
        }

        rs.close();
        stmt.close();
        return ft;
    }

    // ==========================
    // ALTERAR
    // ==========================

    /**
     * Atualiza os dados de um vínculo existente com base no idFuncionarioTurno (PK).
     *
     * @param ft objeto contendo os novos dados (idFuncionarioTurno obrigatório)
     * @throws Exception em caso de erro SQL
     */
    public void alterarFuncionarioTurno(FuncionarioTurno ft) throws Exception {
        String sql = "UPDATE funcionarioturno "
                   + "SET idFuncionario = ?, idTurno = ?, dataInicio = ?, dataFim = ? "
                   + "WHERE idFuncionarioTurno = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1, ft.getFuncionario().getId());
        stmt.setInt(2, ft.getTurno().getId());
        stmt.setDate(3, ft.getDataInicio() != null ? Date.valueOf(ft.getDataInicio()) : null);
        stmt.setDate(4, ft.getDataFim()    != null ? Date.valueOf(ft.getDataFim())    : null);
        stmt.setInt(5, ft.getId()); // idFuncionarioTurno (PK)

        stmt.executeUpdate();
        stmt.close();
    }

    // ==========================
    // EXCLUIR
    // ==========================

    /**
     * Remove permanentemente um vínculo do banco de dados pelo idFuncionarioTurno (PK).
     *
     * @param idFuncionarioTurno identificador do vínculo a ser removido
     * @throws Exception em caso de erro SQL
     */
    public void excluirFuncionarioTurno(int idFuncionarioTurno) throws Exception {
        String sql = "DELETE FROM funcionarioturno WHERE idFuncionarioTurno = ?";
        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idFuncionarioTurno);
        stmt.executeUpdate();
        stmt.close();
    }

    // ==========================
    // RELATÓRIO — LISTAGEM FILTRADA
    // ==========================

    /**
     * Recupera vínculos funcionário/turno aplicando filtros dinâmicos, utilizada
     * pela tela de Relatório de Funcionário x Turno.
     *
     * Filtros aceitos (todos opcionais — passe null/vazio para ignorar):
     * - idFuncionario: filtra por funcionário específico
     * - idTurno: filtra por turno específico
     * - status: "ATIVO" (dataFim nula ou futura) ou "ENCERRADO" (dataFim no passado)
     * - dataInicioDe / dataInicioAte: intervalo sobre a coluna dataInicio
     *
     * @return lista de FuncionarioTurno já filtrada e ordenada
     * @throws Exception em caso de erro de acesso ao banco
     */
    public List<FuncionarioTurno> listarFuncionarioTurnosFiltrados(Integer idFuncionario, Integer idTurno,
            String status, java.time.LocalDate dataInicioDe, java.time.LocalDate dataInicioAte) throws Exception {

        List<FuncionarioTurno> lista = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT ft.idFuncionarioTurno, ft.dataInicio, ft.dataFim, "
              + "       f.id AS idFuncionario, f.nome AS nomeFuncionario, f.matricula, "
              + "       t.id AS idTurno, t.nome AS nomeTurno, "
              + "       t.horaEntrada, t.horaSaida "
              + "FROM funcionarioturno ft "
              + "JOIN funcionario f ON f.id = ft.idFuncionario "
              + "JOIN turno t       ON t.id = ft.idTurno "
              + "WHERE 1=1 ");

        if (idFuncionario != null) {
            sql.append("AND ft.idFuncionario = ? ");
        }
        if (idTurno != null) {
            sql.append("AND ft.idTurno = ? ");
        }
        if (status != null && status.equalsIgnoreCase("ATIVO")) {
            sql.append("AND (ft.dataFim IS NULL OR ft.dataFim >= CURDATE()) ");
        } else if (status != null && status.equalsIgnoreCase("ENCERRADO")) {
            sql.append("AND (ft.dataFim IS NOT NULL AND ft.dataFim < CURDATE()) ");
        }
        if (dataInicioDe != null) {
            sql.append("AND ft.dataInicio >= ? ");
        }
        if (dataInicioAte != null) {
            sql.append("AND ft.dataInicio <= ? ");
        }

        sql.append("ORDER BY ft.idFuncionarioTurno DESC");

        PreparedStatement stmt = conexao.prepareStatement(sql.toString());

        int idx = 1;
        if (idFuncionario != null) {
            stmt.setInt(idx++, idFuncionario);
        }
        if (idTurno != null) {
            stmt.setInt(idx++, idTurno);
        }
        if (dataInicioDe != null) {
            stmt.setDate(idx++, Date.valueOf(dataInicioDe));
        }
        if (dataInicioAte != null) {
            stmt.setDate(idx++, Date.valueOf(dataInicioAte));
        }

        ResultSet rs = stmt.executeQuery();
        while (rs.next()) {
            lista.add(mapear(rs));
        }

        rs.close();
        stmt.close();
        return lista;
    }

    // ==========================
    // RELATÓRIO — GRÁFICO (vínculos iniciados por mês)
    // ==========================

    /**
     * Retorna um array de 12 posições com a quantidade de vínculos cujo
     * dataInicio caiu em cada mês do ano informado (índice 0 = Janeiro).
     *
     * @param ano ano de referência (baseado em dataInicio)
     * @return array int[12] com as quantidades por mês
     * @throws Exception em caso de erro de acesso ao banco
     */
    public int[] contarVinculosPorMes(int ano) throws Exception {
        int[] dados = new int[12];

        String sql = "SELECT MONTH(dataInicio) AS mes, COUNT(*) AS qtd "
                   + "FROM funcionarioturno "
                   + "WHERE dataInicio IS NOT NULL AND YEAR(dataInicio) = ? "
                   + "GROUP BY MONTH(dataInicio)";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, ano);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            int mes = rs.getInt("mes");
            if (mes >= 1 && mes <= 12) {
                dados[mes - 1] = rs.getInt("qtd");
            }
        }

        rs.close();
        stmt.close();
        return dados;
    }

    /**
     * Retorna a lista de anos distintos existentes na coluna dataInicio,
     * em ordem decrescente, utilizada para popular o seletor de ano do gráfico.
     *
     * @return lista de anos (Integer) disponíveis
     * @throws Exception em caso de erro de acesso ao banco
     */
    public List<Integer> listarAnosDisponiveis() throws Exception {
        List<Integer> anos = new ArrayList<>();

        String sql = "SELECT DISTINCT YEAR(dataInicio) AS ano FROM funcionarioturno "
                   + "WHERE dataInicio IS NOT NULL ORDER BY ano DESC";

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
    // HELPER — mapeia ResultSet → FuncionarioTurno
    // ==========================

    /**
     * Converte uma linha do ResultSet em um objeto FuncionarioTurno com
     * Funcionario e Turno aninhados.
     *
     * Centraliza o mapeamento para evitar duplicação de código entre
     * listarFuncionarioTurnos() e buscarPorId().
     *
     * @param rs ResultSet posicionado na linha a ser lida
     * @return FuncionarioTurno preenchido
     * @throws Exception em caso de erro de leitura do ResultSet
     */
    private FuncionarioTurno mapear(ResultSet rs) throws Exception {
        Funcionario funcionario = new Funcionario();
        funcionario.setId(rs.getInt("idFuncionario"));
        funcionario.setNome(rs.getString("nomeFuncionario"));
        funcionario.setMatricula(rs.getString("matricula"));

        Turno turno = new Turno();
        turno.setId(rs.getInt("idTurno"));
        turno.setNome(rs.getString("nomeTurno"));
        turno.setHoraEntrada(rs.getTime("horaEntrada") != null
                ? rs.getTime("horaEntrada").toLocalTime() : null);
        turno.setHoraSaida(rs.getTime("horaSaida") != null
                ? rs.getTime("horaSaida").toLocalTime() : null);

        return new FuncionarioTurno(
            rs.getInt("idFuncionarioTurno"), // PK
            funcionario,
            turno,
            rs.getDate("dataInicio") != null ? rs.getDate("dataInicio").toLocalDate() : null,
            rs.getDate("dataFim")    != null ? rs.getDate("dataFim").toLocalDate()    : null
        );
    }
}