package br.com.frequensys.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import br.com.frequensys.model.Perfil;
import br.com.frequensys.model.Usuario;
import br.com.frequensys.utils.Conexao;
import br.com.frequensys.utils.SenhaUtils;

/**
 * DAO responsável pelas operações de persistência da entidade Usuario.
 *
 * Esta classe centraliza toda a comunicação com o banco de dados referente
 * à tabela "usuario", implementando operações CRUD e autenticação.
 *
 * Responsabilidades:
 * - Inserir, atualizar, remover e consultar usuários
 * - Realizar autenticação baseada em login/senha com verificação BCrypt
 *
 * Observações importantes:
 * - Utiliza PreparedStatement para segurança contra SQL Injection.
 * - Senhas são armazenadas como hash BCrypt — nunca em texto puro.
 * - A conexão é fornecida externamente e não é gerenciada pela classe.
 */
public class UsuarioDAO {

    private Connection conexao;

    /**
     * Construtor responsável por receber uma conexão ativa com o banco.
     *
     * @param conexao conexão JDBC previamente criada
     */
    public UsuarioDAO(Connection conexao) {
        this.conexao = conexao;
    }

    /**
     * Insere um novo usuário na base de dados.
     *
     * Regras de negócio:
     * - A senha deve ser criptografada ANTES de chamar este método.
     *   A criptografia é responsabilidade da camada Controller (UsuarioController).
     *
     * @param usuario objeto contendo os dados do usuário (senha já criptografada)
     * @throws Exception em caso de erro durante execução SQL
     */
    public void adicionarUsuario(Usuario usuario) throws Exception {
        String sql = "INSERT INTO usuario (nome, login, email, status, idperfil, senha) VALUES (?, ?, ?, ?, ?, ?)";
        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setString(1, usuario.getNome());
        stmt.setString(2, usuario.getLogin());
        stmt.setString(3, usuario.getEmail());
        stmt.setString(4, usuario.getStatus());
        stmt.setInt(5, usuario.getPerfil().getId()); // FK do perfil selecionado
        stmt.setString(6, usuario.getSenha()); // Senha já chega criptografada do Controller

        stmt.executeUpdate();
        stmt.close();
    }

    /**
     * Recupera todos os usuários cadastrados.
     *
     * @return lista contendo todos os usuários
     * @throws Exception em caso de erro de acesso ao banco
     */
    public List<Usuario> listarUsuarios() throws Exception {
        List<Usuario> usuarios = new ArrayList<>();
        String sql = "SELECT  u.id, "
	        		+ "    u.nome, "
	        		+ "    u.login, "
	        		+ "    u.email, "
	        		+ "    u.status, "
	        		+ "    u.senha, "
	                + " p.id   AS idperfil, "
	                + " p.nome AS nomeperfil "
	                + " FROM usuario u "
	                + " JOIN perfil p ON p.id = u.idperfil "
	                + " ORDER BY u.id";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            Perfil perfil = new Perfil();
            perfil.setId(rs.getInt("idperfil"));
            perfil.setNome(rs.getString("nomeperfil"));

            Usuario usuario = new Usuario(
                rs.getInt("id"),
                rs.getString("nome"),
                rs.getString("login"),
                rs.getString("email"),
                rs.getString("status"),
                perfil,
                rs.getString("senha")
            );
            usuarios.add(usuario);
        }

        rs.close();
        stmt.close();
        return usuarios;
    }

    /**
     * Atualiza dados cadastrais de um usuário existente.
     *
     * Regra de negócio:
     * - A atualização ocorre com base no id.
     *
     * @param usuario objeto contendo novos dados
     * @throws Exception em caso de erro SQL
     */
    public void alterarUsuario(Usuario usuario) throws Exception {
        String sql = "UPDATE usuario SET nome = ?, login = ?, email = ?, status = ?, idperfil = ?, senha = ? WHERE id = ?";
        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setString(1, usuario.getNome());
        stmt.setString(2, usuario.getLogin());
        stmt.setString(3, usuario.getEmail());
        stmt.setString(4, usuario.getStatus());
        stmt.setInt(5, usuario.getPerfil().getId());
        stmt.setString(6, usuario.getSenha()); // Hash BCrypt vindo do Controller
        stmt.setInt(7, usuario.getId());

        stmt.executeUpdate();
        stmt.close();
    }

    /**
     * Remove permanentemente um usuário do banco de dados.
     *
     * @param id identificador do usuário
     * @throws Exception em caso de erro SQL
     */
    public void excluirUsuario(int id) throws Exception {
        String sql = "DELETE FROM usuario WHERE id = ?";
        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, id);
        stmt.executeUpdate();
        stmt.close();
    }

    /**
     * Busca um usuário específico pelo ID.
     *
     * @param id identificador do usuário
     * @return Usuario encontrado ou null caso não exista
     * @throws Exception em caso de erro SQL
     */
    public Usuario buscarPorId(int id) throws Exception {
        Usuario usuario = null;
        String sql = "SELECT u.*, p.id AS idPerfil, p.nome AS nomePerfil "
                   + "FROM usuario u "
                   + "JOIN perfil p ON p.id = u.idperfil "
                   + "WHERE u.id = ?";
        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, id);
        ResultSet rs = stmt.executeQuery();

        if (rs.next()) {
            Perfil perfil = new Perfil();
            perfil.setId(rs.getInt("idPerfil"));
            perfil.setNome(rs.getString("nomePerfil"));

            usuario = new Usuario(
                rs.getInt("id"),
                rs.getString("nome"),
                rs.getString("login"),
                rs.getString("email"),
                rs.getString("status"),
                perfil,
                rs.getString("senha")
            );
        }

        rs.close();
        stmt.close();
       
        return usuario;
    }

    /**
     * Busca usuário pelo e-mail.
     *
     * @param email e-mail do usuário
     * @return Usuario encontrado ou null
     */
    public Usuario buscarPorEmail(String email) {
        String sql = "SELECT * FROM usuario WHERE email = ?";
        Usuario usuario = null;

        try (PreparedStatement ps = conexao.prepareStatement(sql)) {
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                usuario = new Usuario();
                usuario.setId(rs.getInt("id"));
                usuario.setNome(rs.getString("nome"));
                usuario.setEmail(rs.getString("email"));
                usuario.setLogin(rs.getString("login"));
                usuario.setStatus(rs.getString("status"));
            }

        } catch (SQLException e) {
            throw new RuntimeException("Erro ao buscar usuário por e-mail", e);
        }

        return usuario;
    }

    /**
     * Realiza autenticação do usuário com verificação BCrypt.
     *
     * Fluxo de autenticação:
     * 1. Busca o usuário no banco pelo login (email OU login).
     *    IMPORTANTE: A senha NÃO é comparada diretamente no SQL,
     *    pois o banco armazena um hash BCrypt, não a senha em texto puro.
     * 2. Se o usuário for encontrado, utiliza SenhaUtils.verificar()
     *    para comparar a senha digitada com o hash armazenado no banco.
     * 3. Retorna o objeto Usuario apenas se a verificação for bem-sucedida.
     *
     * @param loginInput login ou e-mail informado pelo usuário no formulário
     * @param senhaDigitada senha informada pelo usuário no formulário de login
     * @return Usuario autenticado ou null caso as credenciais sejam inválidas
     */
    public Usuario autenticar(String loginInput, String senhaDigitada) {
        String sql = "SELECT * FROM usuario WHERE (login = ? OR email = ?)";

        try (PreparedStatement ps = conexao.prepareStatement(sql)) {
            ps.setString(1, loginInput);
            ps.setString(2, loginInput);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String hashArmazenado = rs.getString("senha");
                
                
                // Verificação BCrypt: compara senha digitada com o hash do banco
                if (SenhaUtils.verificar(senhaDigitada, hashArmazenado)) {
                    Usuario usuario = new Usuario();
                    usuario.setId(rs.getInt("id"));
                    usuario.setNome(rs.getString("nome"));
                    usuario.setLogin(rs.getString("login"));
                    usuario.setEmail(rs.getString("email"));
                    usuario.setStatus(rs.getString("status"));
         
                    return usuario;
                    
                }
                
            }

        } catch (SQLException e) {
            throw new RuntimeException("Erro ao autenticar usuário", e);
        }

        // Credenciais inválidas — usuário não encontrado ou senha incorreta
        return null;
    }

    /**
     * Retorna o hash BCrypt da senha armazenada para o usuário informado.
     *
     * Usado pelo Controller para verificar se a "senha atual" digitada
     * corresponde ao hash gravado no banco antes de permitir a troca.
     *
     * @param id identificador do usuário
     * @return hash BCrypt da senha ou null se o usuário não for encontrado
     * @throws Exception em caso de erro SQL
     */
    public String buscarHashSenha(int id) throws Exception {
        String sql = "SELECT senha FROM usuario WHERE id = ?";
        try (PreparedStatement stmt = conexao.prepareStatement(sql)) {
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getString("senha");
            }
        }
        return null;
    }

    /**
     * Persiste a nova senha do usuário, já criptografada em BCrypt.
     *
     * A criptografia (SenhaUtils.criptografar) deve ser aplicada pelo
     * Controller ANTES de chamar este método — o DAO nunca recebe nem
     * armazena senhas em texto puro.
     *
     * @param id       identificador do usuário
     * @param novoHash novo hash BCrypt da senha
     * @throws Exception em caso de erro SQL
     */
    public void alterarSenha(int id, String novoHash) throws Exception {
        String sql = "UPDATE usuario SET senha = ? WHERE id = ?";
        try (PreparedStatement stmt = conexao.prepareStatement(sql)) {
            stmt.setString(1, novoHash);
            stmt.setInt(2, id);
            stmt.executeUpdate();
        }
    }

    // ==========================
    // RELATÓRIO — LISTAGEM FILTRADA
    // ==========================

    /**
     * Recupera usuários aplicando filtros dinâmicos, utilizada pela tela de
     * Relatório de Usuários.
     *
     * Filtros aceitos (todos opcionais — passe null/vazio para ignorar):
     * - nome: busca parcial (LIKE) pelo nome do usuário
     * - idPerfil: filtra por perfil específico
     * - status: filtra pelo status exato (ex.: "ATIVO"/"INATIVO")
     *
     * @return lista de Usuario já filtrada e ordenada por nome
     * @throws Exception em caso de erro de acesso ao banco
     */
    public List<Usuario> listarUsuariosFiltrados(String nome, Integer idPerfil, String status) throws Exception {
        List<Usuario> usuarios = new ArrayList<>();

        StringBuilder sql = new StringBuilder(
                "SELECT u.id, u.nome, u.login, u.email, u.status, u.senha, "
              + "       p.id AS idperfil, p.nome AS nomeperfil "
              + "FROM usuario u "
              + "JOIN perfil p ON p.id = u.idperfil "
              + "WHERE 1=1 ");

        if (nome != null && !nome.isBlank()) {
            sql.append("AND u.nome LIKE ? ");
        }
        if (idPerfil != null) {
            sql.append("AND p.id = ? ");
        }
        if (status != null && !status.isBlank()) {
            sql.append("AND u.status = ? ");
        }
        sql.append("ORDER BY u.nome");

        PreparedStatement stmt = conexao.prepareStatement(sql.toString());

        int idx = 1;
        if (nome != null && !nome.isBlank()) {
            stmt.setString(idx++, "%" + nome + "%");
        }
        if (idPerfil != null) {
            stmt.setInt(idx++, idPerfil);
        }
        if (status != null && !status.isBlank()) {
            stmt.setString(idx++, status);
        }

        ResultSet rs = stmt.executeQuery();
        while (rs.next()) {
            Perfil perfil = new Perfil();
            perfil.setId(rs.getInt("idperfil"));
            perfil.setNome(rs.getString("nomeperfil"));

            Usuario usuario = new Usuario(
                rs.getInt("id"),
                rs.getString("nome"),
                rs.getString("login"),
                rs.getString("email"),
                rs.getString("status"),
                perfil,
                rs.getString("senha")
            );
            usuarios.add(usuario);
        }

        rs.close();
        stmt.close();
        return usuarios;
    }
}