package br.com.frequensys.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import br.com.frequensys.model.Setor;

/**
 * DAO responsável pelas operações de persistência da entidade Setor.
 *
 * Esta classe centraliza toda a comunicação com o banco de dados referente
 * à tabela "setor", implementando operações CRUD completas.
 *
 * Responsabilidades:
 * - Inserir, atualizar, remover e consultar setores.
 *
 * Observações importantes:
 * - Utiliza PreparedStatement para segurança contra SQL Injection.
 * - A conexão é fornecida externamente e não é gerenciada pela classe.
 */
public class SetorDAO {

    private Connection conexao;

    /**
     * Construtor responsável por receber uma conexão ativa com o banco.
     *
     * @param conexao conexão JDBC previamente criada
     */
    public SetorDAO(Connection conexao) {
        this.conexao = conexao;
    }

    /**
     * Insere um novo setor na base de dados.
     *
     * @param setor objeto contendo os dados do setor a ser inserido
     * @throws Exception em caso de erro durante execução SQL
     */
    public void adicionarSetor(Setor setor) throws Exception {
        String sql = "INSERT INTO setor (nome, descricao) VALUES (?, ?)";
        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setString(1, setor.getNome());
        stmt.setString(2, setor.getDescricao());

        stmt.executeUpdate();
        stmt.close();
    }

    /**
     * Recupera todos os setores cadastrados, ordenados pelo ID.
     *
     * @return lista contendo todos os setores
     * @throws Exception em caso de erro de acesso ao banco
     */
    public List<Setor> listarSetores() throws Exception {
        List<Setor> setores = new ArrayList<>();
        String sql = "SELECT id, nome, descricao FROM setor ORDER BY id";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            Setor setor = new Setor(
                rs.getInt("id"),
                rs.getString("nome"),
                rs.getString("descricao")
            );
            setores.add(setor);
        }

        rs.close();
        stmt.close();
        return setores;
    }

    /**
     * Recupera os setores cujo nome contenha o filtro informado (case-insensitive,
     * via LIKE). Utilizado pelo RelatorioSetorController para o campo de busca do
     * relatório.
     *
     * @param nome trecho do nome a ser buscado
     * @return lista de setores que atendem ao filtro, ordenados pelo ID
     * @throws Exception em caso de erro de acesso ao banco
     */
    public List<Setor> listarSetoresFiltrados(String nome) throws Exception {
        List<Setor> setores = new ArrayList<>();
        String sql = "SELECT id, nome, descricao FROM setor WHERE nome LIKE ? ORDER BY id";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setString(1, "%" + nome.trim() + "%");

        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            Setor setor = new Setor(
                rs.getInt("id"),
                rs.getString("nome"),
                rs.getString("descricao")
            );
            setores.add(setor);
        }

        rs.close();
        stmt.close();
        return setores;
    }

    /**
     * Busca um setor específico pelo ID.
     *
     * @param id identificador do setor
     * @return Setor encontrado ou null caso não exista
     * @throws Exception em caso de erro SQL
     */
    public Setor buscarPorId(int id) throws Exception {
        Setor setor = null;
        String sql  = "SELECT id, nome, descricao FROM setor WHERE id = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, id);
        ResultSet rs = stmt.executeQuery();

        if (rs.next()) {
            setor = new Setor(
                rs.getInt("id"),
                rs.getString("nome"),
                rs.getString("descricao")
            );
        }

        rs.close();
        stmt.close();
        return setor;
    }

    /**
     * Atualiza os dados de um setor existente com base no id.
     *
     * @param setor objeto contendo os novos dados (id obrigatório)
     * @throws Exception em caso de erro SQL
     */
    public void alterarSetor(Setor setor) throws Exception {
        String sql = "UPDATE setor SET nome = ?, descricao = ? WHERE id = ?";
        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setString(1, setor.getNome());
        stmt.setString(2, setor.getDescricao());
        stmt.setInt(3, setor.getId());

        stmt.executeUpdate();
        stmt.close();
    }

    /**
     * Remove permanentemente um setor do banco de dados.
     *
     * Regra de negócio:
     * - Caso existam registros vinculados a este setor (FK),
     *   o banco lançará SQLIntegrityConstraintViolationException,
     *   que deve ser tratada na camada Controller.
     *
     * @param id identificador do setor a ser removido
     * @throws Exception em caso de erro SQL
     */
    public void excluirSetor(int id) throws Exception {
        String sql = "DELETE FROM setor WHERE id = ?";
        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, id);
        stmt.executeUpdate();
        stmt.close();
    }
}