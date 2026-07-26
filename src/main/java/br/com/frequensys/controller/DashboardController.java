package br.com.frequensys.controller;

import br.com.frequensys.dao.DashboardDAO;
import br.com.frequensys.utils.Conexao;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Controller responsável por carregar e disponibilizar todos os dados
 * analíticos para o Dashboard do FrequenSys.
 *
 * Fluxo:
 * 1. Verifica sessão ativa — redireciona para login se não autenticado.
 * 2. Instancia DashboardDAO com conexão fresca.
 * 3. Executa todas as queries analíticas.
 * 4. Popula atributos do request.
 * 5. Encaminha para /pages/dashboard.jsp.
 *
 * Atributos enviados ao JSP:
 * - totalAtivos          : int
 * - presencasHoje        : int
 * - ausentesHoje         : int
 * - justPendentes        : int
 * - atrasosNoMes         : int
 * - percentualPresenca   : double
 * - ultimasMarcacoes     : List<Map<String,String>>
 * - justPendentesLista   : List<Map<String,String>>
 * - rankingAssiduidade   : List<Map<String,String>>
 * - alertasBaixa         : List<Map<String,String>>
 * - registrosPorDia      : Map<String,Integer>   (labels e valores p/ gráfico)
 * - ocorrenciasPorTipo   : Map<String,Integer>   (para gráfico rosca)
 * - presencaPorSetor     : List<Map<String,String>>
 */
@WebServlet("/DashboardController")
public class DashboardController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        carregarDashboard(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        carregarDashboard(request, response);
    }

    private void carregarDashboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ── Controle de sessão ────────────────────────────────────────────────
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuarioLogado") == null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        // ── Cache-control ─────────────────────────────────────────────────────
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        try {
            DashboardDAO dao = new DashboardDAO(Conexao.getConnection());

            // ── KPIs — cards superiores ───────────────────────────────────────
            request.setAttribute("totalAtivos",        dao.totalFuncionariosAtivos());
            request.setAttribute("presencasHoje",      dao.presencasHoje());
            request.setAttribute("ausentesHoje",       dao.ausentesHoje());
            request.setAttribute("justPendentes",      dao.justificativasPendentes());
            request.setAttribute("atrasosNoMes",       dao.atrasosNoMes());
            request.setAttribute("percentualPresenca", dao.percentualPresencaMes());

            // ── Tabelas ───────────────────────────────────────────────────────
            request.setAttribute("ultimasMarcacoes",   dao.ultimasMarcacoesHoje());
            request.setAttribute("justPendentesLista", dao.justificativasPendentesRecentes());

            // ── Ranking e Alertas ─────────────────────────────────────────────
            request.setAttribute("rankingAssiduidade", dao.rankingAssiduidade());
            request.setAttribute("alertasBaixa",       dao.alertasBaixaFrequencia());

            // ── Dados para gráficos ───────────────────────────────────────────
            request.setAttribute("registrosPorDia",    dao.registrosPorDia());
            request.setAttribute("ocorrenciasPorTipo", dao.ocorrenciasPorTipo());
            request.setAttribute("presencaPorSetor",   dao.presencaPorSetor());

            // ── pageTitle para sidebar ────────────────────────────────────────
            request.setAttribute("pageTitle", "Dashboard");

            RequestDispatcher dispatcher =
                    request.getRequestDispatcher("/pages/dashboard.jsp");
            dispatcher.forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("mensagemErro",
                    "Erro ao carregar o dashboard: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/");
        }
    }
}