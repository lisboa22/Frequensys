package br.com.frequensys.controller;

import br.com.frequensys.dao.FuncionarioDAO;
import br.com.frequensys.dao.SetorDAO;
import br.com.frequensys.model.Funcionario;
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
import java.time.LocalDate;
import java.util.List;

/**
 * Controller responsável pelo gerenciamento das requisições relacionadas à entidade Funcionario.
 *
 * Atua como camada intermediária entre a camada de visualização (JSP) e a camada de persistência (DAO),
 * centralizando as operações de:
 * - Listagem de funcionários (com JOIN em setor)
 * - Adição de novos funcionários
 * - Edição de funcionários existentes
 * - Exclusão de funcionários
 *
 * Controle de acesso:
 * - Apenas usuários autenticados com perfil ADMINISTRADOR podem operar este controller.
 */
@WebServlet("/FuncionarioController")
public class FuncionarioController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private FuncionarioDAO funcionarioDAO;
    private SetorDAO       setorDAO;

    /**
     * Inicializa os DAOs ao carregar a Servlet.
     *
     * @throws ServletException caso ocorra erro ao inicializar os DAOs.
     */
    @Override
    public void init() throws ServletException {
        try {
            funcionarioDAO = new FuncionarioDAO(Conexao.getConnection());
            setorDAO       = new SetorDAO(Conexao.getConnection());
        } catch (Exception e) {
            throw new ServletException("Erro ao inicializar DAOs", e);
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
            session.setAttribute("mensagemErro", "Acesso negado. Apenas administradores podem gerenciar funcionários.");
            response.sendRedirect(request.getContextPath() + "/DashboardController");
            return;
        }

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        try {
            listarFuncionarios(request, response);
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
            response.sendRedirect(request.getContextPath() + "/DashboardController");
            return;
        }

        try {
            String action = request.getParameter("action");

            if (action == null) {
                listarFuncionarios(request, response);
                return;
            }

            switch (action) {
                case "adicionar":
                    adicionarFuncionario(request, response);
                    break;

                case "editar":
                    editarFuncionario(request, response);
                    break;

                case "deletar":
                    deletarFuncionario(request, response);
                    break;

                default:
                    listarFuncionarios(request, response);
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
     * Responsável por adicionar um novo funcionário ao sistema.
     *
     * Fluxo:
     * 1. Captura os parâmetros enviados pelo formulário.
     * 2. Converte dataAdmissao (String → LocalDate).
     * 3. Instancia objeto Funcionario com o Setor (FK) e persiste via DAO.
     * 4. Redireciona para a listagem com mensagem de sucesso ou erro.
     */
    private void adicionarFuncionario(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        try {
            String nome       = request.getParameter("nome");
            String cpf        = request.getParameter("cpf");
            String matricula  = request.getParameter("matricula");
            String email      = request.getParameter("email");
            String telefone   = request.getParameter("telefone");
            String status     = request.getParameter("status");
            String dataStr    = request.getParameter("dataAdmissao");
            int    idSetor    = Integer.parseInt(request.getParameter("idSetor"));
            String token   = request.getParameter("token");

            LocalDate dataAdmissao = (dataStr != null && !dataStr.isBlank())
                                     ? LocalDate.parse(dataStr) : null;

            Setor setor = new Setor();
            setor.setId(idSetor);

            Funcionario funcionario = new Funcionario(
                nome, cpf, matricula, email, telefone, dataAdmissao, status, setor, token
            );

            funcionarioDAO.adicionarFuncionario(funcionario);
            request.getSession().setAttribute("mensagemSucesso", "Funcionário cadastrado com sucesso!");

        } catch (SQLException e) {
            if (e.getErrorCode() == 1062) {
                String mensagem = e.getMessage();
                if (mensagem.contains("cpf")) {
                    request.getSession().setAttribute("mensagemErro",
                        "Já existe um funcionário cadastrado com este CPF.");
                } else if (mensagem.contains("matricula")) {
                    request.getSession().setAttribute("mensagemErro",
                        "Já existe um funcionário cadastrado com esta matrícula.");
                } else if (mensagem.contains("email")) {
                    request.getSession().setAttribute("mensagemErro",
                        "Já existe um funcionário cadastrado com este e-mail.");
                } else {
                    request.getSession().setAttribute("mensagemErro",
                        "Registro duplicado no sistema.");
                }
                response.sendRedirect(request.getContextPath() + "/FuncionarioController");
                return;
            }
            request.getSession().setAttribute("mensagemErro", "Erro ao cadastrar funcionário.");
            throw e;

        } catch (Exception e) {
            request.getSession().setAttribute("mensagemErro", "Erro ao cadastrar funcionário.");
            throw e;
        }

        // Padrão Post/Redirect/Get — evita reenvio de formulário
        response.sendRedirect(request.getContextPath() + "/FuncionarioController");
    }

    // ==========================
    // EDITAR
    // ==========================

    /**
     * Responsável por atualizar os dados de um funcionário existente.
     *
     * Fluxo:
     * 1. Recupera todos os campos do formulário.
     * 2. Converte dataAdmissao (String → LocalDate).
     * 3. Atualiza o registro via DAO.
     * 4. Redireciona para a listagem com mensagem de sucesso ou erro.
     */
    private void editarFuncionario(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        try {
            int    id = Integer.parseInt(request.getParameter("id"));
            String nome          = request.getParameter("nome");
            String cpf           = request.getParameter("cpf");
            String matricula     = request.getParameter("matricula");
            String email         = request.getParameter("email");
            String telefone      = request.getParameter("telefone");
            String status        = request.getParameter("status");
            String dataStr       = request.getParameter("dataAdmissao");
            int    idSetor       = Integer.parseInt(request.getParameter("idSetor"));
            String token      = request.getParameter("token");

            LocalDate dataAdmissao = (dataStr != null && !dataStr.isBlank())
                                     ? LocalDate.parse(dataStr) : null;

            Setor setor = new Setor();
            setor.setId(idSetor);

            Funcionario funcionario = new Funcionario(
                id, nome, cpf, matricula, email,
                telefone, dataAdmissao, status, setor, token
            );

            funcionarioDAO.alterarFuncionario(funcionario);
            request.getSession().setAttribute("mensagemSucesso", "Funcionário alterado com sucesso!");

        } catch (SQLException e) {
            if (e.getErrorCode() == 1062) {
                String mensagem = e.getMessage();
                if (mensagem.contains("cpf")) {
                    request.getSession().setAttribute("mensagemErro",
                        "Já existe um funcionário cadastrado com este CPF.");
                } else if (mensagem.contains("matricula")) {
                    request.getSession().setAttribute("mensagemErro",
                        "Já existe um funcionário cadastrado com esta matrícula.");
                } else if (mensagem.contains("email")) {
                    request.getSession().setAttribute("mensagemErro",
                        "Já existe um funcionário cadastrado com este e-mail.");
                } else {
                    request.getSession().setAttribute("mensagemErro",
                        "Registro duplicado no sistema.");
                }
                response.sendRedirect(request.getContextPath() + "/FuncionarioController");
                return;
            }
            request.getSession().setAttribute("mensagemErro", "Erro ao alterar funcionário.");
            throw e;

        } catch (Exception e) {
            request.getSession().setAttribute("mensagemErro", "Erro ao alterar funcionário.");
            throw e;
        }

        response.sendRedirect(request.getContextPath() + "/FuncionarioController");
    }

    // ==========================
    // DELETAR
    // ==========================

    /**
     * Responsável por excluir um funcionário do sistema.
     *
     * Regra de negócio crítica:
     * - Caso o funcionário possua registros vinculados (FK), a exclusão não é permitida
     *   e o usuário é informado com mensagem de erro amigável.
     */
    private void deletarFuncionario(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        String idStr = request.getParameter("id");

        if (idStr != null && !idStr.isEmpty()) {
            try {
                int id = Integer.parseInt(idStr);
                funcionarioDAO.excluirFuncionario(id);
                request.getSession().setAttribute("mensagemSucesso", "Funcionário excluído com sucesso!");

            } catch (java.sql.SQLIntegrityConstraintViolationException e) {
                request.getSession().setAttribute("mensagemErro",
                    "Não é possível excluir este funcionário: existem registros vinculados a ele.");

            } catch (Exception e) {
                request.getSession().setAttribute("mensagemErro", "Erro inesperado ao tentar excluir o funcionário.");
                e.printStackTrace();
            }
        }

        response.sendRedirect(request.getContextPath() + "/FuncionarioController");
    }

    // ==========================
    // LISTAR
    // ==========================

    /**
     * Recupera todos os funcionários e setores e encaminha para a camada de visualização.
     *
     * Atributos enviados para a JSP:
     * - "funcionarios" → List<Funcionario> com todos os registros
     * - "setores"      → List<Setor> para popular o select do formulário
     */
    private void listarFuncionarios(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        List<Funcionario> listaFuncionarios = funcionarioDAO.listarFuncionarios();
        List<Setor>       listaSetores      = setorDAO.listarSetores();

        request.setAttribute("funcionarios", listaFuncionarios);
        request.setAttribute("setores",      listaSetores);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/pages/funcionario.jsp");
        dispatcher.forward(request, response);
    }
}
