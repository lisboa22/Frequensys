package br.com.frequensys.controller;

import br.com.frequensys.dao.PreferenciaDAO;
import br.com.frequensys.filter.TemaFilter;
import br.com.frequensys.model.Preferencia;
import br.com.frequensys.utils.Conexao;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import java.io.IOException;

/**
 * Controller responsável pelos parâmetros gerais do sistema
 * (tolerâncias de entrada/saída e intervalo obrigatório).
 */
@WebServlet("/PreferenciaController")
public class PreferenciaController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private PreferenciaDAO preferenciaDAO;

    @Override
    public void init() throws ServletException {
        try {
            preferenciaDAO = new PreferenciaDAO(Conexao.getConnection());
        } catch (Exception e) {
            throw new ServletException("Erro ao inicializar PreferenciaDAO", e);
        }
    }

    // ==========================
    // GET
    // ==========================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("usuarioLogado") == null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        try {
            carregarPreferencia(request, response);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ==========================
    // POST
    // ==========================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        try {
            // Requisição independente disparada pelos botões Claro/Escuro
            // (AJAX), que não deve afetar nem depender dos demais campos
            // do formulário de preferências.
            if (request.getParameter("apenasTema") != null) {
                salvarTema(request, response);
            } else {
                salvarPreferencia(request, response);
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ==========================
    // SALVAR TEMA (AJAX)
    // ==========================
    private void salvarTema(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        response.setContentType("text/plain; charset=UTF-8");

        try {
            boolean modoEscuro = Boolean.parseBoolean(request.getParameter("modoEscuro"));
            preferenciaDAO.alterarModoEscuro(modoEscuro);

            // invalida o cache do TemaFilter para que a próxima requisição
            // de qualquer página já reflita o novo tema
            getServletContext().removeAttribute(TemaFilter.ATRIBUTO_APP_TEMA);

            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write("OK");
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("ERRO");
            throw e;
        }
    }

    // ==========================
    // SALVAR
    // ==========================
    private void salvarPreferencia(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        try {
            int toleranciaEntrada = Integer.parseInt(request.getParameter("toleranciaEntrada"));
            int toleranciaSaida   = Integer.parseInt(request.getParameter("toleranciaSaida"));
            int intervalo         = Integer.parseInt(request.getParameter("intervalo"));
            boolean modoEscuro    = Boolean.parseBoolean(request.getParameter("modoEscuro"));

            Preferencia preferencia = new Preferencia(toleranciaEntrada, toleranciaSaida, intervalo, modoEscuro);

            preferenciaDAO.salvarPreferencia(preferencia);

            // invalida o cache do TemaFilter para que a próxima requisição
            // de qualquer página já reflita o novo tema
            getServletContext().removeAttribute(TemaFilter.ATRIBUTO_APP_TEMA);

            request.getSession().setAttribute("mensagemSucesso",
                    "Preferências salvas com sucesso!");
        } catch (Exception e) {
            request.getSession().setAttribute("mensagemErro",
                    "Erro ao salvar preferências.");
            throw e;
        }

        response.sendRedirect(request.getContextPath() + "/PreferenciaController");
    }

    // ==========================
    // CARREGAR
    // ==========================
    private void carregarPreferencia(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        Preferencia preferencia = preferenciaDAO.buscarPreferencia();

        // Se ainda não existe configuração salva no banco, usa valores
        // padrão apenas para exibição (nada é gravado até o usuário salvar).
        if (preferencia == null) {
            preferencia = new Preferencia(15, 10, 60, true);
        }

        request.setAttribute("preferencia", preferencia);

        RequestDispatcher dispatcher =
                request.getRequestDispatcher("/pages/preferencias.jsp");

        dispatcher.forward(request, response);
    }
}
