package br.com.frequensys.controller;

import br.com.frequensys.dao.SetorDAO;
import br.com.frequensys.model.Setor;
import br.com.frequensys.model.Usuario;
import br.com.frequensys.utils.Conexao;

import java.io.IOException;
import java.sql.Connection;
import java.util.List;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Controller responsável pelo Relatório de Setores.
 *
 * Segue o mesmo padrão do RelatorioFrequenciaController: valida sessão,
 * aplica filtro vindo do formulário, calcula os indicadores exibidos nos
 * cards de KPI e encaminha para a JSP do relatório.
 *
 * Diferente do relatório de frequência, o de Setor não possui recorte
 * temporal (a entidade não tem data), por isso não há endpoint AJAX de
 * gráfico mês a mês — o gráfico exibido é estático (com descrição x sem
 * descrição), calculado junto com os demais KPIs.
 */
@WebServlet("/RelatorioSetorController")
public class RelatorioSetorController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private SetorDAO setorDAO;

    // =========================================================
    // INIT
    // =========================================================
    @Override
    public void init() throws ServletException {
        try {
            Connection con = Conexao.getConnection();
            setorDAO = new SetorDAO(con);
        } catch (Exception e) {
            throw new ServletException("Erro ao inicializar SetorDAO", e);
        }
    }

    // =========================================================
    // GET
    // =========================================================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // =====================================================
        // VALIDA SESSÃO
        // =====================================================
        if (session == null || session.getAttribute("usuarioLogado") == null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        // =====================================================
        // CONTROLE DE CACHE
        // =====================================================
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        try {
            carregarRelatorio(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute(
                "mensagemErro",
                "Erro ao carregar relatório de setores."
            );
            response.sendRedirect(
                request.getContextPath() + "/DashboardController"
            );
        }
    }

    // =========================================================
    // POST
    // =========================================================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        doGet(request, response);
    }

    // =========================================================
    // CARREGAR RELATÓRIO (Mapeamento dos Cards e Filtro)
    // =========================================================
    private void carregarRelatorio(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        // =====================================================
        // FILTRO DO FORMULÁRIO
        // =====================================================
        String nomeFiltro = request.getParameter("nome");

        // =====================================================
        // CONSULTA DE SETORES
        // =====================================================
        List<Setor> setores;

        if (nomeFiltro != null && !nomeFiltro.isBlank()) {
            setores = setorDAO.listarSetoresFiltrados(nomeFiltro);
        } else {
            setores = setorDAO.listarSetores();
        }

        // =====================================================
        // CÁLCULO DOS CARDS DE KPI
        // =====================================================
        int totalSetores  = 0;
        int comDescricao  = 0;
        int semDescricao  = 0;
        int maiorId       = -1;
        String ultimoCadastrado = "—";

        if (setores != null) {
            totalSetores = setores.size();

            for (Setor s : setores) {
                if (s.getDescricao() != null && !s.getDescricao().trim().isEmpty()) {
                    comDescricao++;
                } else {
                    semDescricao++;
                }

                if (s.getId() > maiorId) {
                    maiorId = s.getId();
                    ultimoCadastrado = s.getNome();
                }
            }
        }

        // =====================================================
        // INJEÇÃO DE ATRIBUTOS PARA O JSP
        // =====================================================
        request.setAttribute("setores", setores);
        request.setAttribute("totalSetores", totalSetores);
        request.setAttribute("comDescricao", comDescricao);
        request.setAttribute("semDescricao", semDescricao);
        request.setAttribute("ultimoCadastrado", ultimoCadastrado);

        // Preservação do estado do filtro na tela
        request.setAttribute("nomeFiltro", nomeFiltro);

        // =====================================================
        // FORWARD
        // =====================================================
        RequestDispatcher dispatcher = request.getRequestDispatcher("/pages/relatoriosetor.jsp");
        dispatcher.forward(request, response);
    }

    // =========================================================
    // CONTROLE DE ACESSO
    // =========================================================
    @SuppressWarnings("unused")
    private boolean isAdmin(HttpSession session) {
        Usuario usuarioLogado = (Usuario) session.getAttribute("usuarioLogado");
        if (usuarioLogado == null || usuarioLogado.getPerfil() == null) {
            return false;
        }
        String nomePerfil = usuarioLogado.getPerfil().getNome();
        return nomePerfil != null && nomePerfil.trim().equalsIgnoreCase("ADMINISTRADOR");
    }
}
