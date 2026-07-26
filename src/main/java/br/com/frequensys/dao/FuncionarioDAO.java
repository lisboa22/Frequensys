package br.com.frequensys.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import br.com.frequensys.model.Funcionario;
import br.com.frequensys.model.Setor;

/**
 * DAO responsável pelas operações de persistência da entidade Funcionario.
 *
 * Esta classe centraliza toda a comunicação com o banco de dados referente
 * à tabela "funcionario", implementando operações CRUD completas.
 *
 * Responsabilidades:
 * - Inserir, atualizar, remover e consultar funcionários.
 * - Realizar JOIN com a tabela "setor" para popular o objeto Setor dentro de Funcionario.
 * - Autenticar funcionário pelo token para registro de ponto.
 * - Suportar o Relatório de Funcionários: listagem filtrada, admissões por mês
 *   e anos disponíveis para o seletor do gráfico.
 *
 * Observações importantes:
 * - Utiliza PreparedStatement para segurança contra SQL Injection.
 * - A conexão é fornecida externamente e não é gerenciada pela classe.
 * - dataAdmissao é tratada como java.sql.Date ↔ java.time.LocalDate.
 */
public class FuncionarioDAO {

    private Connection conexao;

    /**
     * Construtor responsável por receber uma conexão ativa com o banco.
     *
     * @param conexao conexão JDBC previamente criada
     */
    public FuncionarioDAO(Connection conexao) {
        this.conexao = conexao;
    }

    /**
     * Insere um novo funcionário na base de dados.
     *
     * @param funcionario objeto contendo os dados do funcionário a ser inserido
     * @throws Exception em caso de erro durante execução SQL
     */
    public void adicionarFuncionario(Funcionario funcionario) throws Exception {
        String sql = "INSERT INTO funcionario (nome, cpf, matricula, email, telefone, dataAdmissao, status, idSetor, token) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setString(1, funcionario.getNome());
        stmt.setString(2, funcionario.getCpf());
        stmt.setString(3, funcionario.getMatricula());
        stmt.setString(4, funcionario.getEmail());
        stmt.setString(5, funcionario.getTelefone());
        stmt.setDate(6, funcionario.getDataAdmissao() != null
                        ? Date.valueOf(funcionario.getDataAdmissao()) : null);
        stmt.setString(7, funcionario.getStatus());
        stmt.setInt(8, funcionario.getSetor().getId());
        stmt.setString(9, funcionario.getToken());

        stmt.executeUpdate();
        stmt.close();
    }

    /**
     * Recupera todos os funcionários cadastrados com JOIN no setor.
     *
     * @return lista contendo todos os funcionários
     * @throws Exception em caso de erro de acesso ao banco
     */
    public List<Funcionario> listarFuncionarios() throws Exception {
        List<Funcionario> funcionarios = new ArrayList<>();
        String sql = "SELECT f.id, f.nome, f.cpf, f.matricula, f.email, "
                   + "       f.telefone, f.dataAdmissao, f.status, f.token, "
                   + "       s.id AS idSetor, s.nome AS nomeSetor "
                   + "FROM funcionario f "
                   + "LEFT JOIN setor s ON s.id = f.idSetor "
                   + "ORDER BY f.id";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            funcionarios.add(mapear(rs));
        }

        rs.close();
        stmt.close();
        return funcionarios;
    }

    /**
     * Busca um funcionário específico pelo ID, com JOIN no setor.
     *
     * @param id identificador do funcionário
     * @return Funcionario encontrado ou null caso não exista
     * @throws Exception em caso de erro SQL
     */
    public Funcionario buscarPorId(int id) throws Exception {
        Funcionario funcionario = null;

        String sql = "SELECT f.id, f.nome, f.cpf, f.matricula, f.email, "
                   + "       f.telefone, f.dataAdmissao, f.status, f.token, "
                   + "       s.id AS idSetor, s.nome AS nomeSetor "
                   + "FROM funcionario f "
                   + "LEFT JOIN setor s ON s.id = f.idSetor "
                   + "WHERE f.id = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, id);
        ResultSet rs = stmt.executeQuery();

        if (rs.next()) {
            funcionario = mapear(rs);
        }

        rs.close();
        stmt.close();
        return funcionario;
    }

    /**
     * Busca um funcionário pelo token de ponto.
     *
     * @param token token de identificação do funcionário
     * @return Funcionario encontrado ou null caso o token não exista
     * @throws Exception em caso de erro SQL
     */
    public Funcionario buscarPorToken(String token) throws Exception {
        Funcionario funcionario = null;

        String sql = "SELECT f.id, f.nome, f.cpf, f.matricula, f.email, "
                   + "       f.telefone, f.dataAdmissao, f.status, f.token, "
                   + "       s.id AS idSetor, s.nome AS nomeSetor "
                   + "FROM funcionario f "
                   + "LEFT JOIN setor s ON s.id = f.idSetor "
                   + "WHERE BINARY f.token = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setString(1, token);
        ResultSet rs = stmt.executeQuery();

        if (rs.next()) {
            funcionario = mapear(rs);
        }

        rs.close();
        stmt.close();
        return funcionario;
    }

    /**
     * Atualiza os dados de um funcionário existente com base no id.
     *
     * @param funcionario objeto contendo os novos dados (id obrigatório)
     * @throws Exception em caso de erro SQL
     */
    public void alterarFuncionario(Funcionario funcionario) throws Exception {
        String sql = "UPDATE funcionario SET nome = ?, cpf = ?, matricula = ?, email = ?, "
                   + "telefone = ?, dataAdmissao = ?, status = ?, idSetor = ?, token = ? "
                   + "WHERE id = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setString(1, funcionario.getNome());
        stmt.setString(2, funcionario.getCpf());
        stmt.setString(3, funcionario.getMatricula());
        stmt.setString(4, funcionario.getEmail());
        stmt.setString(5, funcionario.getTelefone());
        stmt.setDate(6, funcionario.getDataAdmissao() != null
                        ? Date.valueOf(funcionario.getDataAdmissao()) : null);
        stmt.setString(7, funcionario.getStatus());
        stmt.setInt(8, funcionario.getSetor().getId());
        stmt.setString(9, funcionario.getToken());
        stmt.setInt(10, funcionario.getId());

        stmt.executeUpdate();
        stmt.close();
    }

    /**
     * Remove permanentemente um funcionário do banco de dados.
     *
     * @param id identificador do funcionário a ser removido
     * @throws Exception em caso de erro SQL
     */
    public void excluirFuncionario(int id) throws Exception {
        String sql = "DELETE FROM funcionario WHERE id = ?";
        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, id);
        stmt.executeUpdate();
        stmt.close();
    }

    // ── RELATÓRIO DE FUNCIONÁRIOS ──────────────────────────────────────────

    /**
     * Recupera funcionários aplicando filtros dinâmicos (todos opcionais).
     *
     * Utilizado pelo RelatorioFuncionarioController para popular a tabela
     * de detalhamento e calcular os KPIs do relatório.
     *
     * @param nome        filtro parcial (LIKE) pelo nome do funcionário
     * @param idSetor     filtro exato pelo setor (null = todos)
     * @param status      filtro exato pelo status ("ATIVO"/"INATIVO", null/branco = todos)
     * @param dataInicio  data mínima de admissão no formato yyyy-MM-dd (opcional)
     * @param dataFim     data máxima de admissão no formato yyyy-MM-dd (opcional)
     * @return lista de funcionários que atendem aos filtros informados
     * @throws Exception em caso de erro SQL
     */
    public List<Funcionario> listarFuncionariosFiltrados(String nome, Integer idSetor, String status,
                                                           String dataInicio, String dataFim) throws Exception {
        List<Funcionario> funcionarios = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
            "SELECT f.id, f.nome, f.cpf, f.matricula, f.email, "
          + "       f.telefone, f.dataAdmissao, f.status, f.token, "
          + "       s.id AS idSetor, s.nome AS nomeSetor "
          + "FROM funcionario f "
          + "LEFT JOIN setor s ON s.id = f.idSetor "
          + "WHERE 1=1 "
        );

        List<Object> parametros = new ArrayList<>();

        if (nome != null && !nome.isBlank()) {
            sql.append("AND f.nome LIKE ? ");
            parametros.add("%" + nome + "%");
        }
        if (idSetor != null) {
            sql.append("AND f.idSetor = ? ");
            parametros.add(idSetor);
        }
        if (status != null && !status.isBlank()) {
            sql.append("AND f.status = ? ");
            parametros.add(status);
        }
        if (dataInicio != null && !dataInicio.isBlank()) {
            sql.append("AND f.dataAdmissao >= ? ");
            parametros.add(Date.valueOf(dataInicio));
        }
        if (dataFim != null && !dataFim.isBlank()) {
            sql.append("AND f.dataAdmissao <= ? ");
            parametros.add(Date.valueOf(dataFim));
        }

        sql.append("ORDER BY f.nome");

        PreparedStatement stmt = conexao.prepareStatement(sql.toString());
        for (int i = 0; i < parametros.size(); i++) {
            stmt.setObject(i + 1, parametros.get(i));
        }

        ResultSet rs = stmt.executeQuery();
        while (rs.next()) {
            funcionarios.add(mapear(rs));
        }

        rs.close();
        stmt.close();
        return funcionarios;
    }

    /**
     * Conta quantos funcionários foram admitidos em cada mês de um determinado ano.
     *
     * Usado tanto na carga inicial do gráfico quanto pelo endpoint AJAX
     * "dadosGrafico", acionado ao trocar o ano no seletor.
     *
     * @param ano ano de referência (ex: 2026)
     * @return array de 12 posições (índice 0 = Janeiro ... 11 = Dezembro)
     * @throws Exception em caso de erro SQL
     */
    public int[] contarAdmissoesPorMes(int ano) throws Exception {
        int[] admissoesPorMes = new int[12];

        String sql = "SELECT MONTH(dataAdmissao) AS mes, COUNT(*) AS total "
                   + "FROM funcionario "
                   + "WHERE YEAR(dataAdmissao) = ? "
                   + "GROUP BY MONTH(dataAdmissao)";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, ano);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            int mes   = rs.getInt("mes");
            int total = rs.getInt("total");
            if (mes >= 1 && mes <= 12) {
                admissoesPorMes[mes - 1] = total;
            }
        }

        rs.close();
        stmt.close();
        return admissoesPorMes;
    }

    /**
     * Lista, em ordem decrescente, os anos que possuem admissões registradas.
     * Alimenta o seletor de ano do gráfico "Admissões por Mês".
     *
     * @return lista de anos distintos com admissões
     * @throws Exception em caso de erro SQL
     */
    public List<Integer> listarAnosAdmissao() throws Exception {
        List<Integer> anos = new ArrayList<>();

        String sql = "SELECT DISTINCT YEAR(dataAdmissao) AS ano "
                   + "FROM funcionario "
                   + "WHERE dataAdmissao IS NOT NULL "
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

    // ── HELPER: converte ResultSet em objeto ──────────────────────────────────

    /**
     * Converte uma linha do ResultSet em um objeto Funcionario com Setor aninhado.
     *
     * @param rs ResultSet posicionado na linha a ser lida
     * @return Funcionario preenchido com dados do banco
     * @throws SQLException em caso de erro de leitura do ResultSet
     */
    private Funcionario mapear(ResultSet rs) throws SQLException {
        // idSetor pode ser NULL quando o setor do funcionário foi excluído
        // (LEFT JOIN); nesse caso montamos um Setor "vazio" em vez de deixar
        // o funcionário inteiro desaparecer da listagem.
        Setor setor;
        Object idSetorObj = rs.getObject("idSetor");
        if (idSetorObj != null) {
            setor = new Setor(
                rs.getInt("idSetor"),
                rs.getString("nomeSetor"),
                null // descricao não necessária nas consultas
            );
        } else {
            setor = new Setor(0, "Sem setor", null);
        }

        return new Funcionario(
            rs.getInt("id"),
            rs.getString("nome"),
            rs.getString("cpf"),
            rs.getString("matricula"),
            rs.getString("email"),
            rs.getString("telefone"),
            rs.getDate("dataAdmissao") != null
                ? rs.getDate("dataAdmissao").toLocalDate() : null,
            rs.getString("status"),
            setor,
            rs.getString("token")
        );
    }
}