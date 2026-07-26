package br.com.frequensys.controller;

import br.com.frequensys.dao.PerfilDAO;
import br.com.frequensys.dao.UsuarioDAO;
import br.com.frequensys.model.Perfil;
import br.com.frequensys.model.Usuario;
import br.com.frequensys.utils.Conexao;
import br.com.frequensys.utils.SenhaUtils;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/UsuarioController")
public class UsuarioController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private UsuarioDAO usuarioDAO;
    private PerfilDAO  perfilDAO;

    @Override
    public void init() throws ServletException {
        try {
            usuarioDAO = new UsuarioDAO(Conexao.getConnection());
            perfilDAO  = new PerfilDAO(Conexao.getConnection());
        } catch (Exception e) {
            throw new ServletException("Erro ao inicializar DAOs", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        
        // ==========================
        // VALIDAÇÃO DE SESSÃO (DESATIVADA TEMPORARIAMENTE)
        // ==========================

        if (session == null || session.getAttribute("usuarioLogado") == null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        if (!isAdmin(session)) {
            session.setAttribute("mensagemErro", "Acesso negado. Apenas administradores podem gerenciar usuários.");
            response.sendRedirect(request.getContextPath() + "/DashboardController");
            return;
        }
        // Fim Validação 

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        try {
            listarUsuarios(request, response);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        HttpSession session = request.getSession(false);

        
        // ==========================
        // VALIDAÇÃO DE SESSÃO (DESATIVADA TEMPORARIAMENTE)
        // ==========================

        if (session == null || session.getAttribute("usuarioLogado") == null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        if (!isAdmin(session)) {
            session.setAttribute("mensagemErro", "Acesso negado.");
            response.sendRedirect(request.getContextPath() + "/DashboardController");
            return;
        }
         

        try {
            String action = request.getParameter("action");

            if (action == null) {
                listarUsuarios(request, response);
                return;
            }

            switch (action) {
                case "adicionar":
                    adicionarUsuario(request, response);
                    break;

                case "editar":
                    editarUsuario(request, response);
                    break;

                case "deletar":
                    deletarUsuario(request, response);
                    break;

                default:
                    listarUsuarios(request, response);
                    break;
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ==========================
    // CONTROLE DE ACESSO
    // ==========================
    private boolean isAdmin(HttpSession session) {
        Usuario usuarioLogado = (Usuario) session.getAttribute("usuarioLogado");
        if (usuarioLogado == null || usuarioLogado.getPerfil() == null) {
            return false;
        }
        String nomePerfil = usuarioLogado.getPerfil().getNome();
        return nomePerfil != null && nomePerfil.trim().equalsIgnoreCase("ADMINISTRADOR");
    }

    // ==========================
    // ADICIONAR
    // ==========================
    private void adicionarUsuario(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
    	System.out.println("entrou no adicionar usuario");
        try {
            String nome   = request.getParameter("nome");
            String login  = request.getParameter("login");
            String email  = request.getParameter("email");
            String status = request.getParameter("status");
            String senha  = request.getParameter("senha");

            String senhaCriptografada = SenhaUtils.criptografar(senha);

            Perfil perfil = new Perfil();
            perfil.setId(Integer.parseInt(request.getParameter("perfil")));

            Usuario usuario = new Usuario(
                nome,
                login,
                email,
                status,
                perfil,
                senhaCriptografada
            );

            usuarioDAO.adicionarUsuario(usuario);
            request.getSession().setAttribute("mensagemSucesso", "Usuário cadastrado com sucesso!");

        } catch (SQLException e) {
            if (e.getErrorCode() == 1062) {
                String mensagem = e.getMessage();

                if (mensagem.contains("uk_usuario_email")) {
                    request.getSession().setAttribute("mensagemErro",
                        "Já existe um usuário cadastrado com este e-mail.");
                } else if (mensagem.contains("uk_usuario_login")) {
                    request.getSession().setAttribute("mensagemErro",
                        "Já existe um usuário cadastrado com este login.");
                } else {
                    request.getSession().setAttribute("mensagemErro",
                        "Registro duplicado no sistema.");
                }

                response.sendRedirect(request.getContextPath() + "/UsuarioController");
                return;
            }

            request.getSession().setAttribute("mensagemErro", "Erro ao cadastrar usuário.");
            throw e;

        } catch (Exception e) {
            request.getSession().setAttribute("mensagemErro", "Erro ao cadastrar usuário.");
            throw e;
        }

        response.sendRedirect(request.getContextPath() + "/UsuarioController");
    }

    // ==========================
    // EDITAR
    // ==========================
    private void editarUsuario(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        try {
            int    id     = Integer.parseInt(request.getParameter("id"));
            String nome   = request.getParameter("nome");
            String login  = request.getParameter("login");
            String email  = request.getParameter("email");
            String status = request.getParameter("status");
            int idperfil = Integer.parseInt(request.getParameter("idperfil")) ;
            String senha  = request.getParameter("senha");

            String senhaCriptografada;
            if (senha != null && !senha.isBlank()) {
                senhaCriptografada = SenhaUtils.criptografar(senha);
            } else {
                Usuario usuarioAtual = usuarioDAO.buscarPorId(id);
                senhaCriptografada = (usuarioAtual != null) ? usuarioAtual.getSenha() : "";
            }

            Perfil perfil = new Perfil();
            perfil.setId(idperfil);

            Usuario usuario = new Usuario(
                id,
                nome,
                login,
                email,
                status,
                perfil,
                senhaCriptografada
            );

            usuarioDAO.alterarUsuario(usuario);
            request.getSession().setAttribute("mensagemSucesso", "Usuário alterado com sucesso!");

        } catch (SQLException e) {
            if (e.getErrorCode() == 1062) {
                String mensagem = e.getMessage();

                if (mensagem.contains("uk_usuario_email")) {
                    request.getSession().setAttribute("mensagemErro",
                        "Já existe um usuário cadastrado com este e-mail.");
                } else if (mensagem.contains("uk_usuario_login")) {
                    request.getSession().setAttribute("mensagemErro",
                        "Já existe um usuário cadastrado com este login.");
                } else {
                    request.getSession().setAttribute("mensagemErro",
                        "Registro duplicado no sistema.");
                }

                response.sendRedirect(request.getContextPath() + "/UsuarioController");
                return;
            }

            request.getSession().setAttribute("mensagemErro", "Erro ao alterar usuário.");
            throw e;

        } catch (Exception e) {
            request.getSession().setAttribute("mensagemErro", "Erro ao alterar usuário.");
            throw e;
        }

        response.sendRedirect(request.getContextPath() + "/UsuarioController");
    }

    // ==========================
    // DELETAR
    // ==========================
    private void deletarUsuario(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        String idStr = request.getParameter("id");

        if (idStr != null && !idStr.isEmpty()) {
            try {
                int id = Integer.parseInt(idStr);
                usuarioDAO.excluirUsuario(id);
                request.getSession().setAttribute("mensagemSucesso", "Usuário excluído com sucesso!");

            } catch (java.sql.SQLIntegrityConstraintViolationException e) {
                request.getSession().setAttribute("mensagemErro",
                    "Não é possível excluir este usuário: existem registros vinculados a ele.");

            } catch (Exception e) {
                request.getSession().setAttribute("mensagemErro", "Erro inesperado ao tentar excluir o usuário.");
                e.printStackTrace();
            }
        }

        response.sendRedirect(request.getContextPath() + "/UsuarioController");
    }

    // ==========================
    // LISTAR
    // ==========================
    private void listarUsuarios(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        List<Usuario> listaUsuarios = usuarioDAO.listarUsuarios();
        List<Perfil>  listaPerfis   = perfilDAO.listarPerfis();
        
        for (Usuario u : listaUsuarios) {
            System.out.println("ID: " + u.getId());
            System.out.println("Nome: " + u.getNome());
            System.out.println("Login: " + u.getLogin());
            System.out.println("Email: " + u.getEmail());
            System.out.println("Status: " + u.getStatus());

            if (u.getPerfil() != null) {
                System.out.println("Perfil: " + u.getPerfil().getNome());
            }

            System.out.println("----------------------");
        }
        
        request.setAttribute("usuarios", listaUsuarios);
        request.setAttribute("perfis",   listaPerfis);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/pages/usuarios.jsp");
        dispatcher.forward(request, response);
    }
}