package br.com.frequensys.controller;

import br.com.frequensys.dao.UsuarioDAO;
import br.com.frequensys.model.Usuario;
import br.com.frequensys.utils.Conexao;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;

/**
 * Controller responsável pelo processo de autenticação de usuários.
 */
@WebServlet("/LoginController")
public class LoginController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Captura parâmetros enviados pelo formulário
        String loginInput = request.getParameter("loginInput");
        String senha      = request.getParameter("senha");
        
        // Bloco try-with-resources garante fechamento automático da conexão
        try (Connection conn = Conexao.getConnection()) {

            // Instancia DAO responsável pela autenticação
            UsuarioDAO usuarioDAO = new UsuarioDAO(conn);

            // Realiza validação das credenciais no banco
            Usuario usuario = usuarioDAO.autenticar(loginInput, senha);
            
            if (usuario != null) {
                // Cria sessão HTTP
                HttpSession sessao = request.getSession(true);

                // Busca o usuário completo (com perfil)
                Usuario usuarioCompleto = usuarioDAO.buscarPorId(usuario.getId());
                
                // Armazena objeto Usuario completo na sessão
                sessao.setAttribute("usuarioLogado", usuarioCompleto != null ? usuarioCompleto : usuario);

                // Redireciona para o Dashboard após login bem-sucedido
                response.sendRedirect(request.getContextPath() + "/");

            } else {
                // ❌ Login inválido: Define a mensagem de erro na sessão
                HttpSession sessao = request.getSession();
                sessao.setAttribute("mensagemErro", "Usuário ou senha inválidos.");
                
                // Redireciona de volta para a página inicial
                response.sendRedirect(request.getContextPath() + "/index.jsp");
            }

        } catch (Exception e) {
            // ❌ Erro técnico: Define mensagem amigável na sessão
            HttpSession sessao = request.getSession();
            sessao.setAttribute("mensagemErro", "Erro ao processar login. Tente novamente mais tarde.");
            
            response.sendRedirect(request.getContextPath() + "/index.jsp");
        }
    }
}