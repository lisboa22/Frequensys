package br.com.frequensys.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;

import br.com.frequensys.model.Turno;

/**
 * DAO responsável pelas operações de persistência da entidade Turno.
 *
 * Esta classe centraliza toda a comunicação com o banco de dados referente
 * à tabela "turno", implementando operações CRUD completas.
 *
 * Responsabilidades:
 * - Inserir, atualizar, remover e consultar turnos.
 *
 * Observações importantes:
 * - Utiliza PreparedStatement para segurança contra SQL Injection.
 * - A conexão é fornecida externamente e não é gerenciada pela classe.
 * - horaEntrada e horaSaida são tratadas como java.sql.Time ↔ java.time.LocalTime.
 * - toleranciaEntrada, toleranciaSaida e cargaHorariaDiaria são armazenados em minutos (INT).
 */
public class TurnoDAO {

    private Connection conexao;

    /**
     * Construtor responsável por receber uma conexão ativa com o banco.
     *
     * @param conexao conexão JDBC previamente criada
     */
    public TurnoDAO(Connection conexao) {
        this.conexao = conexao;
    }

    // ==========================
    // ADICIONAR
    // ==========================

    /**
     * Insere um novo turno na base de dados.
     *
     * @param turno objeto contendo os dados do turno a ser inserido
     * @throws Exception em caso de erro durante execução SQL
     */
    public void adicionarTurno(Turno turno) throws Exception {
        String sql = "INSERT INTO turno (nome, horaEntrada, horaSaida, toleranciaEntrada, "
                   + "toleranciaSaida, cargaHorariaDiaria, status) VALUES (?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setString(1, turno.getNome());
        stmt.setTime(2, turno.getHoraEntrada() != null ? Time.valueOf(turno.getHoraEntrada()) : null);
        stmt.setTime(3, turno.getHoraSaida()   != null ? Time.valueOf(turno.getHoraSaida())   : null);
        stmt.setInt(4, turno.getToleranciaEntrada());
        stmt.setInt(5, turno.getToleranciaSaida());
        stmt.setInt(6, turno.getCargaHorariaDiaria());
        stmt.setString(7, turno.getStatus());

        stmt.executeUpdate();
        stmt.close();
    }

    // ==========================
    // LISTAR
    // ==========================

    /**
     * Recupera todos os turnos cadastrados, ordenados pelo ID.
     *
     * @return lista contendo todos os turnos
     * @throws Exception em caso de erro de acesso ao banco
     */
    public List<Turno> listarTurnos() throws Exception {
        List<Turno> turnos = new ArrayList<>();
        String sql = "SELECT id, nome, horaEntrada, horaSaida, toleranciaEntrada, "
                   + "toleranciaSaida, cargaHorariaDiaria, status "
                   + "FROM turno ORDER BY id";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            Turno turno = new Turno(
                rs.getInt("id"),
                rs.getString("nome"),
                rs.getTime("horaEntrada") != null ? rs.getTime("horaEntrada").toLocalTime() : null,
                rs.getTime("horaSaida")   != null ? rs.getTime("horaSaida").toLocalTime()   : null,
                rs.getInt("toleranciaEntrada"),
                rs.getInt("toleranciaSaida"),
                rs.getInt("cargaHorariaDiaria"),
                rs.getString("status")
            );
            turnos.add(turno);
        }

        rs.close();
        stmt.close();
        return turnos;
    }

    /**
     * Recupera os turnos filtrados por nome (LIKE, opcional) e/ou status
     * (igualdade exata, opcional). Utilizado pelo RelatorioTurnoController.
     * Qualquer um dos dois parâmetros pode ser null/vazio, caso em que
     * aquele filtro é ignorado.
     *
     * @param nome   trecho do nome a ser buscado (ou null/vazio para ignorar)
     * @param status status exato a ser buscado, ex: "ATIVO"/"INATIVO" (ou null/vazio para ignorar)
     * @return lista de turnos que atendem aos filtros, ordenados pelo ID
     * @throws Exception em caso de erro de acesso ao banco
     */
    public List<Turno> listarTurnosFiltrados(String nome, String status) throws Exception {
        List<Turno> turnos = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
            "SELECT id, nome, horaEntrada, horaSaida, toleranciaEntrada, "
          + "toleranciaSaida, cargaHorariaDiaria, status FROM turno WHERE 1=1"
        );

        boolean temNome   = nome   != null && !nome.trim().isEmpty();
        boolean temStatus = status != null && !status.trim().isEmpty();

        if (temNome)   sql.append(" AND nome LIKE ?");
        if (temStatus) sql.append(" AND status = ?");
        sql.append(" ORDER BY id");

        PreparedStatement stmt = conexao.prepareStatement(sql.toString());

        int idx = 1;
        if (temNome)   stmt.setString(idx++, "%" + nome.trim() + "%");
        if (temStatus) stmt.setString(idx++, status.trim());

        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            Turno turno = new Turno(
                rs.getInt("id"),
                rs.getString("nome"),
                rs.getTime("horaEntrada") != null ? rs.getTime("horaEntrada").toLocalTime() : null,
                rs.getTime("horaSaida")   != null ? rs.getTime("horaSaida").toLocalTime()   : null,
                rs.getInt("toleranciaEntrada"),
                rs.getInt("toleranciaSaida"),
                rs.getInt("cargaHorariaDiaria"),
                rs.getString("status")
            );
            turnos.add(turno);
        }

        rs.close();
        stmt.close();
        return turnos;
    }

    // ==========================
    // BUSCAR POR ID
    // ==========================

    /**
     * Busca um turno específico pelo ID.
     *
     * @param id identificador do turno
     * @return Turno encontrado ou null caso não exista
     * @throws Exception em caso de erro SQL
     */
    public Turno buscarPorId(int id) throws Exception {
        Turno turno = null;
        String sql  = "SELECT id, nome, horaEntrada, horaSaida, toleranciaEntrada, "
                    + "toleranciaSaida, cargaHorariaDiaria, status "
                    + "FROM turno WHERE id = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, id);
        ResultSet rs = stmt.executeQuery();

        if (rs.next()) {
            turno = new Turno(
                rs.getInt("id"),
                rs.getString("nome"),
                rs.getTime("horaEntrada") != null ? rs.getTime("horaEntrada").toLocalTime() : null,
                rs.getTime("horaSaida")   != null ? rs.getTime("horaSaida").toLocalTime()   : null,
                rs.getInt("toleranciaEntrada"),
                rs.getInt("toleranciaSaida"),
                rs.getInt("cargaHorariaDiaria"),
                rs.getString("status")
            );
        }

        rs.close();
        stmt.close();
        return turno;
    }

    // ==========================
    // BUSCAR TURNO ATIVO POR FUNCIONÁRIO
    // ==========================

    /**
     * Busca o turno ativo de um funcionário pela tabela funcionarioturno.
     *
     * O vínculo correto é: funcionario → funcionarioturno → turno
     *
     * Regras de vigência:
     * - dataInicio <= CURDATE() (vínculo já iniciou)
     * - dataFim IS NULL  → vínculo em aberto, sem encerramento previsto (PERMITIDO)
     * - dataFim >= CURDATE() → vínculo ainda vigente (PERMITIDO)
     *
     * IMPORTANTE: BETWEEN falha quando dataFim é NULL no MySQL.
     * Por isso usamos (ft.dataFim IS NULL OR ft.dataFim >= CURDATE()).
     *
     * Caso o funcionário tenha mais de um vínculo ativo (situação anômala),
     * retorna o registro mais recente pelo maior idFuncionarioTurno.
     *
     * @param idFuncionario identificador do funcionário
     * @return Turno ativo ou null se não houver vínculo vigente na data atual
     * @throws Exception em caso de erro SQL
     */
    public Turno buscarTurnoAtivoPorFuncionario(int idFuncionario) throws Exception {
        String sql = "SELECT t.id, t.nome, t.horaEntrada, t.horaSaida, "
                   + "       t.toleranciaEntrada, t.toleranciaSaida, "
                   + "       t.cargaHorariaDiaria, t.status "
                   + "FROM turno t "
                   + "INNER JOIN funcionarioturno ft ON ft.idTurno = t.id "
                   + "WHERE ft.idFuncionario = ? "
                   + "  AND ft.dataInicio <= CURDATE() "
                   + "  AND (ft.dataFim IS NULL OR ft.dataFim >= CURDATE()) "
                   + "ORDER BY ft.idFuncionarioTurno DESC "
                   + "LIMIT 1";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, idFuncionario);
        ResultSet rs = stmt.executeQuery();

        Turno turno = null;

        if (rs.next()) {
            turno = new Turno(
                rs.getInt("id"),
                rs.getString("nome"),
                rs.getTime("horaEntrada") != null ? rs.getTime("horaEntrada").toLocalTime() : null,
                rs.getTime("horaSaida")   != null ? rs.getTime("horaSaida").toLocalTime()   : null,
                rs.getInt("toleranciaEntrada"),
                rs.getInt("toleranciaSaida"),
                rs.getInt("cargaHorariaDiaria"),
                rs.getString("status")
            );
        }

        rs.close();
        stmt.close();
        return turno;
    }

    // ==========================
    // ALTERAR
    // ==========================

    /**
     * Atualiza os dados de um turno existente com base no id.
     *
     * @param turno objeto contendo os novos dados (id obrigatório)
     * @throws Exception em caso de erro SQL
     */
    public void alterarTurno(Turno turno) throws Exception {
        String sql = "UPDATE turno SET nome = ?, horaEntrada = ?, horaSaida = ?, "
                   + "toleranciaEntrada = ?, toleranciaSaida = ?, cargaHorariaDiaria = ?, "
                   + "status = ? WHERE id = ?";
        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setString(1, turno.getNome());
        stmt.setTime(2, turno.getHoraEntrada() != null ? Time.valueOf(turno.getHoraEntrada()) : null);
        stmt.setTime(3, turno.getHoraSaida()   != null ? Time.valueOf(turno.getHoraSaida())   : null);
        stmt.setInt(4, turno.getToleranciaEntrada());
        stmt.setInt(5, turno.getToleranciaSaida());
        stmt.setInt(6, turno.getCargaHorariaDiaria());
        stmt.setString(7, turno.getStatus());
        stmt.setInt(8, turno.getId());

        stmt.executeUpdate();
        stmt.close();
    }

    // ==========================
    // EXCLUIR
    // ==========================

    /**
     * Remove permanentemente um turno do banco de dados.
     *
     * Regra de negócio:
     * - Caso existam registros vinculados a este turno (FK),
     *   o banco lançará SQLIntegrityConstraintViolationException,
     *   que deve ser tratada na camada Controller.
     *
     * @param id identificador do turno a ser removido
     * @throws Exception em caso de erro SQL
     */
    public void excluirTurno(int id) throws Exception {
        String sql = "DELETE FROM turno WHERE id = ?";
        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, id);
        stmt.executeUpdate();
        stmt.close();
    }
}