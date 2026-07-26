package br.com.frequensys.controller;

import br.com.frequensys.dao.FuncionarioDAO;
import br.com.frequensys.dao.FuncionarioTurnoDAO;
import br.com.frequensys.dao.TurnoDAO;
import br.com.frequensys.model.Funcionario;
import br.com.frequensys.model.FuncionarioTurno;
import br.com.frequensys.model.Turno;
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
 * Controller responsável pelo gerenciamento das requisições relacionadas à entidade FuncionarioTurno.
 *
 * Atua como camada intermediária entre a camada de visualização (JSP) e a camada de persistência (DAO),
 * centralizando as operações de:
 * - Listagem de vínculos funcionário/turno
 * - Adição de novos vínculos
 * - Edição de vínculos existentes
 * - Exclusão de vínculos
 *
 * Controle de acesso:
 * - Apenas usuários autenticados com perfil ADMINISTRADOR podem operar este controller.
 */
@WebServlet("/FuncionarioTurnoController")
public class FuncionarioTurnoController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private FuncionarioTurnoDAO funcionarioTurnoDAO;
    private FuncionarioDAO      funcionarioDAO;
    private TurnoDAO            turnoDAO;

    /**
     * Inicializa os DAOs ao carregar a Servlet.
     *
     * @throws ServletException caso ocorra erro ao inicializar os DAOs.
     */
    @Override
    public void init() throws ServletException {
        try {
            funcionarioTurnoDAO = new FuncionarioTurnoDAO(Conexao.getConnection());
            funcionarioDAO      = new FuncionarioDAO(Conexao.getConnection());
            turnoDAO            = new TurnoDAO(Conexao.getConnection());
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
            session.setAttribute("mensagemErro", "Acesso negado. Apenas administradores podem gerenciar vínculos de turno.");
            response.sendRedirect(request.getContextPath() + "/DashboardController");
            return;
        }

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        try {
            listarFuncionarioTurnos(request, response);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    /**
     * Processa requisições HTTP POST, roteando para a ação correspondente
     * com base no parâmetro "action".
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
                listarFuncionarioTurnos(request, response);
                return;
            }

            switch (action) {
                case "adicionar":
                    adicionarFuncionarioTurno(request, response);
                    break;

                case "editar":
                    editarFuncionarioTurno(request, response);
                    break;

                case "deletar":
                    deletarFuncionarioTurno(request, response);
                    break;

                default:
                    listarFuncionarioTurnos(request, response);
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

    /**
     * Responsável por adicionar um novo vínculo funcionário/turno.
     *
     * Fluxo:
     * 1. Captura idFuncionario, idTurno, dataInicio e dataFim do formulário.
     * 2. Converte as datas (String → LocalDate).
     * 3. Persiste via FuncionarioTurnoDAO.
     * 4. Redireciona com mensagem de sucesso ou erro.
     */
    private void adicionarFuncionarioTurno(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        try {
            int    idFuncionario = Integer.parseInt(request.getParameter("idFuncionario"));
            int    idTurno       = Integer.parseInt(request.getParameter("idTurno"));
            String dataInicioStr = request.getParameter("dataInicio");
            String dataFimStr    = request.getParameter("dataFim");

            LocalDate dataInicio = (dataInicioStr != null && !dataInicioStr.isBlank())
                                   ? LocalDate.parse(dataInicioStr) : null;
            LocalDate dataFim    = (dataFimStr    != null && !dataFimStr.isBlank())
                                   ? LocalDate.parse(dataFimStr)    : null;

            Funcionario funcionario = new Funcionario();
            funcionario.setId(idFuncionario);

            Turno turno = new Turno();
            turno.setId(idTurno);

            FuncionarioTurno ft = new FuncionarioTurno(funcionario, turno, dataInicio, dataFim);

            funcionarioTurnoDAO.adicionarFuncionarioTurno(ft);
            request.getSession().setAttribute("mensagemSucesso", "Vínculo cadastrado com sucesso!");

        } catch (Exception e) {
            request.getSession().setAttribute("mensagemErro", "Erro ao cadastrar vínculo.");
            throw e;
        }

        response.sendRedirect(request.getContextPath() + "/FuncionarioTurnoController");
    }

    // ==========================
    // EDITAR
    // ==========================

    /**
     * Responsável por atualizar um vínculo existente.
     *
     * Fluxo:
     * 1. Recupera idFuncionarioTurno, idFuncionario, idTurno, dataInicio e dataFim.
     * 2. Converte as datas (String → LocalDate).
     * 3. Atualiza via FuncionarioTurnoDAO.
     */
    private void editarFuncionarioTurno(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        try {
            int    idFuncionarioTurno = Integer.parseInt(request.getParameter("idFuncionarioTurno"));
            int    idFuncionario      = Integer.parseInt(request.getParameter("idFuncionario"));
            int    idTurno            = Integer.parseInt(request.getParameter("idTurno"));
            String dataInicioStr      = request.getParameter("dataInicio");
            String dataFimStr         = request.getParameter("dataFim");

            LocalDate dataInicio = (dataInicioStr != null && !dataInicioStr.isBlank())
                                   ? LocalDate.parse(dataInicioStr) : null;
            LocalDate dataFim    = (dataFimStr    != null && !dataFimStr.isBlank())
                                   ? LocalDate.parse(dataFimStr)    : null;

            Funcionario funcionario = new Funcionario();
            funcionario.setId(idFuncionario);

            Turno turno = new Turno();
            turno.setId(idTurno);

            FuncionarioTurno ft = new FuncionarioTurno(
                idFuncionarioTurno, funcionario, turno, dataInicio, dataFim
            );

            funcionarioTurnoDAO.alterarFuncionarioTurno(ft);
            request.getSession().setAttribute("mensagemSucesso", "Vínculo alterado com sucesso!");

        } catch (Exception e) {
            request.getSession().setAttribute("mensagemErro", "Erro ao alterar vínculo.");
            throw e;
        }

        response.sendRedirect(request.getContextPath() + "/FuncionarioTurnoController");
    }

    // ==========================
    // DELETAR
    // ==========================

    /**
     * Responsável por excluir um vínculo do sistema.
     */
    private void deletarFuncionarioTurno(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        String idStr = request.getParameter("idFuncionarioTurno");

        if (idStr != null && !idStr.isEmpty()) {
            try {
                int idFuncionarioTurno = Integer.parseInt(idStr);
                funcionarioTurnoDAO.excluirFuncionarioTurno(idFuncionarioTurno);
                request.getSession().setAttribute("mensagemSucesso", "Vínculo excluído com sucesso!");

            } catch (java.sql.SQLIntegrityConstraintViolationException e) {
                request.getSession().setAttribute("mensagemErro",
                    "Não é possível excluir este vínculo: existem registros dependentes.");

            } catch (Exception e) {
                request.getSession().setAttribute("mensagemErro", "Erro inesperado ao tentar excluir o vínculo.");
                e.printStackTrace();
            }
        }

        response.sendRedirect(request.getContextPath() + "/FuncionarioTurnoController");
    }

    // ==========================
    // LISTAR
    // ==========================

    /**
     * Recupera todos os vínculos, funcionários e turnos e encaminha para a JSP.
     *
     * Atributos enviados para a JSP:
     * - "funcionarioTurnos" → List<FuncionarioTurno>
     * - "funcionarios"      → List<Funcionario> para o select
     * - "turnos"            → List<Turno> para o select
     */
    private void listarFuncionarioTurnos(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        List<FuncionarioTurno> listaFuncionarioTurnos = funcionarioTurnoDAO.listarFuncionarioTurnos();
        List<Funcionario>      listaFuncionarios       = funcionarioDAO.listarFuncionarios();
        List<Turno>            listaTurnos             = turnoDAO.listarTurnos();

        request.setAttribute("funcionarioTurnos", listaFuncionarioTurnos);
        request.setAttribute("funcionarios",      listaFuncionarios);
        request.setAttribute("turnos",            listaTurnos);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/pages/funcionarioturno.jsp");
        dispatcher.forward(request, response);
    }
}

