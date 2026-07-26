package br.com.frequensys.controller;

import br.com.frequensys.dao.TurnoDAO;
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
import java.time.LocalTime;
import java.util.List;

/**
 * Controller responsável pelo gerenciamento das requisições relacionadas à entidade Turno.
 *
 * Atua como camada intermediária entre a camada de visualização (JSP) e a camada de persistência (DAO),
 * centralizando as operações de:
 * - Listagem de turnos
 * - Adição de novos turnos
 * - Edição de turnos existentes
 * - Exclusão de turnos
 *
 * Controle de acesso:
 * - Apenas usuários autenticados com perfil ADMINISTRADOR podem operar este controller.
 */
@WebServlet("/TurnoController")
public class TurnoController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private TurnoDAO turnoDAO;

    /**
     * Inicializa o DAO ao carregar a Servlet.
     *
     * @throws ServletException caso ocorra erro ao inicializar o DAO.
     */
    @Override
    public void init() throws ServletException {
        try {
            turnoDAO = new TurnoDAO(Conexao.getConnection());
        } catch (Exception e) {
            throw new ServletException("Erro ao inicializar TurnoDAO", e);
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
            session.setAttribute("mensagemErro", "Acesso negado. Apenas administradores podem gerenciar turnos.");
            response.sendRedirect(request.getContextPath() + "/DashboardController");
            return;
        }

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        try {
            listarTurnos(request, response);
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
                listarTurnos(request, response);
                return;
            }

            switch (action) {
                case "adicionar":
                    adicionarTurno(request, response);
                    break;

                case "editar":
                    editarTurno(request, response);
                    break;

                case "deletar":
                    deletarTurno(request, response);
                    break;

                default:
                    listarTurnos(request, response);
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
     * Responsável por adicionar um novo turno ao sistema.
     *
     * Fluxo:
     * 1. Captura os parâmetros enviados pelo formulário.
     * 2. Converte horaEntrada e horaSaida (String HH:mm → LocalTime).
     * 3. Instancia objeto Turno e persiste via TurnoDAO.
     * 4. Redireciona para a listagem com mensagem de sucesso ou erro.
     */
    private void adicionarTurno(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        try {
            String nome               = request.getParameter("nome");
            String horaEntradaStr     = request.getParameter("horaEntrada");
            String horaSaidaStr       = request.getParameter("horaSaida");
            int    toleranciaEntrada   = Integer.parseInt(request.getParameter("toleranciaEntrada"));
            int    toleranciaSaida    = Integer.parseInt(request.getParameter("toleranciaSaida"));
            int    cargaHorariaDiaria = Integer.parseInt(request.getParameter("cargaHorariaDiaria"));
            String status             = request.getParameter("status");

            // Converte String "HH:mm" para LocalTime
            LocalTime horaEntrada = (horaEntradaStr != null && !horaEntradaStr.isBlank())
                                    ? LocalTime.parse(horaEntradaStr) : null;
            LocalTime horaSaida   = (horaSaidaStr   != null && !horaSaidaStr.isBlank())
                                    ? LocalTime.parse(horaSaidaStr)   : null;

            Turno turno = new Turno(
                nome, horaEntrada, horaSaida,
                toleranciaEntrada, toleranciaSaida, cargaHorariaDiaria, status
            );

            turnoDAO.adicionarTurno(turno);
            request.getSession().setAttribute("mensagemSucesso", "Turno cadastrado com sucesso!");

        } catch (SQLException e) {
            if (e.getErrorCode() == 1062) {
                request.getSession().setAttribute("mensagemErro",
                    "Já existe um turno cadastrado com este nome.");
                response.sendRedirect(request.getContextPath() + "/TurnoController");
                return;
            }
            request.getSession().setAttribute("mensagemErro", "Erro ao cadastrar turno.");
            throw e;

        } catch (Exception e) {
            request.getSession().setAttribute("mensagemErro", "Erro ao cadastrar turno.");
            throw e;
        }

        // Padrão Post/Redirect/Get — evita reenvio de formulário
        response.sendRedirect(request.getContextPath() + "/TurnoController");
    }

    // ==========================
    // EDITAR
    // ==========================

    /**
     * Responsável por atualizar os dados de um turno existente.
     *
     * Fluxo:
     * 1. Recupera todos os campos do formulário.
     * 2. Converte horaEntrada e horaSaida (String HH:mm → LocalTime).
     * 3. Atualiza o registro via TurnoDAO.
     * 4. Redireciona para a listagem com mensagem de sucesso ou erro.
     */
    private void editarTurno(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        try {
            int    id            = Integer.parseInt(request.getParameter("id"));
            String nome               = request.getParameter("nome");
            String horaEntradaStr     = request.getParameter("horaEntrada");
            String horaSaidaStr       = request.getParameter("horaSaida");
            int    toleranciaEntrada   = Integer.parseInt(request.getParameter("toleranciaEntrada"));
            int    toleranciaSaida    = Integer.parseInt(request.getParameter("toleranciaSaida"));
            int    cargaHorariaDiaria = Integer.parseInt(request.getParameter("cargaHorariaDiaria"));
            String status             = request.getParameter("status");

            LocalTime horaEntrada = (horaEntradaStr != null && !horaEntradaStr.isBlank())
                                    ? LocalTime.parse(horaEntradaStr) : null;
            LocalTime horaSaida   = (horaSaidaStr   != null && !horaSaidaStr.isBlank())
                                    ? LocalTime.parse(horaSaidaStr)   : null;

            Turno turno = new Turno(
                id, nome, horaEntrada, horaSaida,
                toleranciaEntrada, toleranciaSaida, cargaHorariaDiaria, status
            );

            turnoDAO.alterarTurno(turno);
            request.getSession().setAttribute("mensagemSucesso", "Turno alterado com sucesso!");

        } catch (SQLException e) {
            if (e.getErrorCode() == 1062) {
                request.getSession().setAttribute("mensagemErro",
                    "Já existe um turno cadastrado com este nome.");
                response.sendRedirect(request.getContextPath() + "/TurnoController");
                return;
            }
            request.getSession().setAttribute("mensagemErro", "Erro ao alterar turno.");
            throw e;

        } catch (Exception e) {
            request.getSession().setAttribute("mensagemErro", "Erro ao alterar turno.");
            throw e;
        }

        response.sendRedirect(request.getContextPath() + "/TurnoController");
    }

    // ==========================
    // DELETAR
    // ==========================

    /**
     * Responsável por excluir um turno do sistema.
     *
     * Regra de negócio crítica:
     * - Caso o turno possua registros vinculados (FK), a exclusão não é permitida
     *   e o usuário é informado com mensagem de erro amigável.
     */
    private void deletarTurno(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        String idStr = request.getParameter("id");

        if (idStr != null && !idStr.isEmpty()) {
            try {
                int id = Integer.parseInt(idStr);
                turnoDAO.excluirTurno(id);
                request.getSession().setAttribute("mensagemSucesso", "Turno excluído com sucesso!");

            } catch (java.sql.SQLIntegrityConstraintViolationException e) {
                request.getSession().setAttribute("mensagemErro",
                    "Não é possível excluir este turno: existem registros vinculados a ele.");

            } catch (Exception e) {
                request.getSession().setAttribute("mensagemErro", "Erro inesperado ao tentar excluir o turno.");
                e.printStackTrace();
            }
        }

        response.sendRedirect(request.getContextPath() + "/TurnoController");
    }

    // ==========================
    // LISTAR
    // ==========================

    /**
     * Recupera todos os turnos e encaminha para a camada de visualização.
     *
     * Atributos enviados para a JSP:
     * - "turnos" → List<Turno> com todos os registros
     */
    private void listarTurnos(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        List<Turno> listaTurnos = turnoDAO.listarTurnos();

        request.setAttribute("turnos", listaTurnos);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/pages/turno.jsp");
        dispatcher.forward(request, response);
    }
}