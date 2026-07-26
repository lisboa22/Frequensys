package br.com.frequensys.controller;

import br.com.frequensys.dao.SetorDAO;
import br.com.frequensys.model.Setor;
import br.com.frequensys.model.Usuario;
import br.com.frequensys.utils.Conexao;

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

/**
 * Controller responsável pelo gerenciamento das requisições relacionadas à entidade Setor.
 *
 * Atua como camada intermediária entre a camada de visualização (JSP) e a camada de persistência (DAO),
 * centralizando as operações de:
 * - Listagem de setores
 * - Adição de novos setores
 * - Edição de setores existentes
 * - Exclusão de setores
 *
 * Controle de acesso:
 * - Apenas usuários autenticados com perfil ADMINISTRADOR podem operar este controller.
 */
@WebServlet("/SetorController")
public class SetorController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private SetorDAO setorDAO;

    /**
     * Inicializa o DAO ao carregar a Servlet.
     *
     * @throws ServletException caso ocorra erro ao inicializar o DAO.
     */
    @Override
    public void init() throws ServletException {
        try {
            setorDAO = new SetorDAO(Conexao.getConnection());
        } catch (Exception e) {
            throw new ServletException("Erro ao inicializar SetorDAO", e);
        }
    }

    /**
     * Processa requisições HTTP GET.
     *
     * Verifica sessão ativa e perfil ADMINISTRADOR antes de prosseguir.
     * Desabilita cache para páginas autenticadas.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("usuarioLogado") == null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        if (!isAdmin(session)) {
            session.setAttribute("mensagemErro", "Acesso negado. Apenas administradores podem gerenciar setores.");
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        try {
            listarSetores(request, response);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    /**
     * Processa requisições HTTP POST, roteando para a ação correspondente
     * com base no parâmetro "action".
     *
     * Protegido contra acesso direto via POST por não-administradores.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("usuarioLogado") == null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        if (!isAdmin(session)) {
            session.setAttribute("mensagemErro", "Acesso negado.");
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        try {
            String action = request.getParameter("action");

            if (action == null) {
                listarSetores(request, response);
                return;
            }

            switch (action) {
                case "adicionar":
                    adicionarSetor(request, response);
                    break;

                case "editar":
                    editarSetor(request, response);
                    break;

                case "deletar":
                    deletarSetor(request, response);
                    break;

                default:
                    listarSetores(request, response);
                    break;
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ==========================
    // CONTROLE DE ACESSO
    // ==========================

    /**
     * Verifica se o usuário da sessão possui perfil ADMINISTRADOR.
     *
     * @param session sessão HTTP ativa
     * @return true se o perfil for ADMINISTRADOR, false caso contrário
     */
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

    /**
     * Responsável por adicionar um novo setor ao sistema.
     *
     * Fluxo:
     * 1. Captura os parâmetros enviados pelo formulário (nome, descricao).
     * 2. Instancia objeto Setor e persiste via SetorDAO.
     * 3. Redireciona para a listagem com mensagem de sucesso ou erro.
     */
    private void adicionarSetor(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        try {
            String nome      = request.getParameter("nome");
            String descricao = request.getParameter("descricao");

            Setor setor = new Setor(nome, descricao);

            setorDAO.adicionarSetor(setor);
            request.getSession().setAttribute("mensagemSucesso", "Setor cadastrado com sucesso!");

        } catch (SQLException e) {
            if (e.getErrorCode() == 1062) {
                // Violação de UNIQUE constraint (ex: nome duplicado)
                request.getSession().setAttribute("mensagemErro",
                    "Já existe um setor cadastrado com este nome.");
                response.sendRedirect(request.getContextPath() + "/SetorController");
                return;
            }
            request.getSession().setAttribute("mensagemErro", "Erro ao cadastrar setor.");
            throw e;

        } catch (Exception e) {
            request.getSession().setAttribute("mensagemErro", "Erro ao cadastrar setor.");
            throw e;
        }

        // Padrão Post/Redirect/Get — evita reenvio de formulário
        response.sendRedirect(request.getContextPath() + "/SetorController");
    }

    // ==========================
    // EDITAR
    // ==========================

    /**
     * Responsável por atualizar os dados de um setor existente.
     *
     * Fluxo:
     * 1. Recupera id, nome e descricao do formulário.
     * 2. Atualiza o registro via SetorDAO.
     * 3. Redireciona para a listagem com mensagem de sucesso ou erro.
     */
    private void editarSetor(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        try {
            int    id   = Integer.parseInt(request.getParameter("id"));
            String nome      = request.getParameter("nome");
            String descricao = request.getParameter("descricao");

            Setor setor = new Setor(id, nome, descricao);

            setorDAO.alterarSetor(setor);
            request.getSession().setAttribute("mensagemSucesso", "Setor alterado com sucesso!");

        } catch (SQLException e) {
            if (e.getErrorCode() == 1062) {
                request.getSession().setAttribute("mensagemErro",
                    "Já existe um setor cadastrado com este nome.");
                response.sendRedirect(request.getContextPath() + "/SetorController");
                return;
            }
            request.getSession().setAttribute("mensagemErro", "Erro ao alterar setor.");
            throw e;

        } catch (Exception e) {
            request.getSession().setAttribute("mensagemErro", "Erro ao alterar setor.");
            throw e;
        }

        response.sendRedirect(request.getContextPath() + "/SetorController");
    }

    // ==========================
    // DELETAR
    // ==========================

    /**
     * Responsável por excluir um setor do sistema.
     *
     * Regra de negócio crítica:
     * - Caso o setor possua registros vinculados (FK), a exclusão não é permitida
     *   e o usuário é informado com mensagem de erro amigável.
     */
    private void deletarSetor(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        String idStr = request.getParameter("id");

        if (idStr != null && !idStr.isEmpty()) {
            try {
                int id = Integer.parseInt(idStr);
                setorDAO.excluirSetor(id);
                request.getSession().setAttribute("mensagemSucesso", "Setor excluído com sucesso!");

            } catch (java.sql.SQLIntegrityConstraintViolationException e) {
                request.getSession().setAttribute("mensagemErro",
                    "Não é possível excluir este setor: existem registros vinculados a ele.");

            } catch (Exception e) {
                request.getSession().setAttribute("mensagemErro", "Erro inesperado ao tentar excluir o setor.");
                e.printStackTrace();
            }
        }

        response.sendRedirect(request.getContextPath() + "/SetorController");
    }

    // ==========================
    // LISTAR
    // ==========================

    /**
     * Recupera todos os setores e encaminha para a camada de visualização.
     *
     * Atributos enviados para a JSP:
     * - "setores" → List<Setor> com todos os registros
     */
    private void listarSetores(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        List<Setor> listaSetores = setorDAO.listarSetores();

        request.setAttribute("setores", listaSetores);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/pages/setor.jsp");
        dispatcher.forward(request, response);
    }
}
