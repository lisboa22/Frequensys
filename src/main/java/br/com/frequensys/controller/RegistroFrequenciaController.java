package br.com.frequensys.controller;

import br.com.frequensys.dao.RegistroFrequenciaDAO;
import br.com.frequensys.dao.FuncionarioDAO;
import br.com.frequensys.dao.TurnoDAO;
import br.com.frequensys.model.RegistroFrequencia;
import br.com.frequensys.model.Usuario;
import br.com.frequensys.utils.Conexao;

import java.io.IOException;
import java.sql.Connection;
import java.time.LocalDateTime;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/RegistroFrequenciaController")
public class RegistroFrequenciaController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private RegistroFrequenciaDAO registroDAO;
    private FuncionarioDAO        funcionarioDAO;
    private TurnoDAO              turnoDAO;

    // ==========================
    // INIT — instancia DAOs uma vez com conexão fixa
    // ==========================
    @Override
    public void init() throws ServletException {
        try {
            Connection con  = Conexao.getConnection();
            registroDAO    = new RegistroFrequenciaDAO(con);
            funcionarioDAO = new FuncionarioDAO(con);
            turnoDAO       = new TurnoDAO(con);
        } catch (Exception e) {
            throw new ServletException("Erro ao inicializar DAOs", e);
        }
    }

    // ==========================
    // GET — lista registros + popula combos
    // ==========================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("usuarioLogado") == null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        if (!isAdmin(session)) {
            session.setAttribute("mensagemErro", "Acesso negado. Apenas administradores podem gerenciar registros de frequência.");
            response.sendRedirect(request.getContextPath() + "/DashboardController");
            return;
        }

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        try {
            listarRegistros(request, response);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ==========================
    // POST — roteador de ações
    // ==========================
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
                listarRegistros(request, response);
                return;
            }

            switch (action) {
                case "adicionar":
                    adicionarRegistro(request, response);
                    break;
                case "editar":
                    editarRegistro(request, response);
                    break;
                case "deletar":
                    deletarRegistro(request, response);
                    break;
                default:
                    listarRegistros(request, response);
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
    private void adicionarRegistro(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        try {
            RegistroFrequencia r = montar(request);
            registroDAO.adicionarRegistro(r);
            request.getSession().setAttribute("mensagemSucesso", "Registro de frequência cadastrado com sucesso!");
        } catch (Exception e) {
            request.getSession().setAttribute("mensagemErro", "Erro ao cadastrar registro de frequência.");
            throw e;
        }
        response.sendRedirect(request.getContextPath() + "/RegistroFrequenciaController");
    }

    // ==========================
    // EDITAR
    // ==========================
    private void editarRegistro(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        try {
            RegistroFrequencia r = montar(request);
            r.setId(Integer.parseInt(request.getParameter("id")));
            registroDAO.alterarRegistro(r);
            request.getSession().setAttribute("mensagemSucesso", "Registro de frequência atualizado com sucesso!");
        } catch (Exception e) {
            request.getSession().setAttribute("mensagemErro", "Erro ao alterar registro de frequência.");
            throw e;
        }
        response.sendRedirect(request.getContextPath() + "/RegistroFrequenciaController");
    }

    // ==========================
    // DELETAR
    // ==========================
    private void deletarRegistro(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            try {
                int id = Integer.parseInt(idStr);
                registroDAO.excluirRegistro(id);
                request.getSession().setAttribute("mensagemSucesso", "Registro de frequência excluído com sucesso!");
            } catch (java.sql.SQLIntegrityConstraintViolationException e) {
                request.getSession().setAttribute("mensagemErro",
                    "Não é possível excluir este registro: existem dados vinculados a ele.");
            } catch (Exception e) {
                request.getSession().setAttribute("mensagemErro", "Erro inesperado ao tentar excluir o registro.");
                e.printStackTrace();
            }
        }
        response.sendRedirect(request.getContextPath() + "/RegistroFrequenciaController");
    }

    // ==========================
    // LISTAR
    // ==========================
    private void listarRegistros(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        request.setAttribute("registros",    registroDAO.listarRegistros());
        request.setAttribute("funcionarios", funcionarioDAO.listarFuncionarios());
        request.setAttribute("turnos",       turnoDAO.listarTurnos());

        RequestDispatcher dispatcher = request.getRequestDispatcher("/pages/registrofrequencia.jsp");
        dispatcher.forward(request, response);
    }

    // ==========================
    // HELPER — monta objeto a partir do formulário
    // ==========================
    private RegistroFrequencia montar(HttpServletRequest req) {
        RegistroFrequencia r = new RegistroFrequencia();

        r.setIdFuncionario(Integer.parseInt(req.getParameter("idFuncionario")));
        r.setIdTurno(Integer.parseInt(req.getParameter("idTurno")));
        r.setTipo(req.getParameter("tipo"));
        r.setStatus(req.getParameter("status"));

        // datahora: campo datetime-local do HTML envia no formato "yyyy-MM-ddTHH:mm"
        String datahora = req.getParameter("datahora");
        r.setDatahora(datahora != null && !datahora.isBlank() ? LocalDateTime.parse(datahora) : null);

        String atraso = req.getParameter("minutosatraso");
        r.setMinutosatraso(atraso != null && !atraso.isBlank() ? Integer.parseInt(atraso) : 0);

        String saidaAnt = req.getParameter("minutossaidaantecipada");
        r.setMinutossaidaantecipada(saidaAnt != null && !saidaAnt.isBlank() ? Integer.parseInt(saidaAnt) : 0);

        r.setCargahorariacumprida(req.getParameter("cargahorariacumprida"));
        r.setObservacao(req.getParameter("observacao"));

        return r;
    }
}
