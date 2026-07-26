package br.com.frequensys.controller;

import br.com.frequensys.dao.TurnoDAO;
import br.com.frequensys.model.Turno;
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
 * Controller responsável pelo Relatório de Turnos.
 *
 * Segue o mesmo padrão do RelatorioFrequenciaController / RelatorioSetorController:
 * valida sessão, aplica filtros vindos do formulário, calcula os indicadores
 * exibidos nos cards de KPI e encaminha para a JSP do relatório.
 *
 * Diferente do relatório de frequência, o de Turno não possui recorte temporal
 * por mês/ano (a entidade não tem data de ocorrência), por isso não há endpoint
 * AJAX de gráfico — os dados do gráfico (carga horária por turno) são calculados
 * junto com os demais KPIs e enviados prontos (em formato JSON) para a JSP.
 */
@WebServlet("/RelatorioTurnoController")
public class RelatorioTurnoController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private TurnoDAO turnoDAO;

    // =========================================================
    // INIT
    // =========================================================
    @Override
    public void init() throws ServletException {
        try {
            Connection con = Conexao.getConnection();
            turnoDAO = new TurnoDAO(con);
        } catch (Exception e) {
            throw new ServletException("Erro ao inicializar TurnoDAO", e);
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
                "Erro ao carregar relatório de turnos."
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
    // CARREGAR RELATÓRIO (Mapeamento dos Cards, Gráfico e Filtros)
    // =========================================================
    private void carregarRelatorio(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        // =====================================================
        // FILTROS DO FORMULÁRIO
        // =====================================================
        String nomeFiltro   = request.getParameter("nome");
        String statusFiltro = request.getParameter("status");

        // =====================================================
        // CONSULTA DE TURNOS
        // =====================================================
        List<Turno> turnos;

        boolean temFiltro = (nomeFiltro != null && !nomeFiltro.isBlank())
                          || (statusFiltro != null && !statusFiltro.isBlank());

        if (temFiltro) {
            turnos = turnoDAO.listarTurnosFiltrados(nomeFiltro, statusFiltro);
        } else {
            turnos = turnoDAO.listarTurnos();
        }

        // =====================================================
        // CÁLCULO DOS CARDS DE KPI + DADOS DO GRÁFICO
        // =====================================================
        int totalTurnos = 0;
        int ativos      = 0;
        int inativos    = 0;
        long somaCargaHorariaMinutos = 0;

        StringBuilder labelsJson = new StringBuilder("[");
        StringBuilder dataJson   = new StringBuilder("[");

        if (turnos != null) {
            totalTurnos = turnos.size();

            for (int i = 0; i < turnos.size(); i++) {
                Turno t = turnos.get(i);

                if ("ATIVO".equalsIgnoreCase(t.getStatus())) {
                    ativos++;
                } else {
                    inativos++;
                }

                somaCargaHorariaMinutos += t.getCargaHorariaDiaria();

                String nomeEscapado = t.getNome() != null
                                     ? t.getNome().replace("\"", "'")
                                     : "";
                double horas = t.getCargaHorariaDiaria() / 60.0;

                labelsJson.append("\"").append(nomeEscapado).append("\"");
                dataJson.append(horas);

                if (i < turnos.size() - 1) {
                    labelsJson.append(",");
                    dataJson.append(",");
                }
            }
        }
        labelsJson.append("]");
        dataJson.append("]");

        int cargaMediaMinutos = totalTurnos > 0
                               ? (int) (somaCargaHorariaMinutos / totalTurnos)
                               : 0;
        String cargaMediaFormatada = (cargaMediaMinutos / 60) + "h " + (cargaMediaMinutos % 60) + "min";

        // =====================================================
        // INJEÇÃO DE ATRIBUTOS PARA O JSP
        // =====================================================
        request.setAttribute("turnos", turnos);
        request.setAttribute("totalTurnos", totalTurnos);
        request.setAttribute("ativos", ativos);
        request.setAttribute("inativos", inativos);
        request.setAttribute("cargaMediaFormatada", cargaMediaFormatada);
        request.setAttribute("chartLabelsJson", labelsJson.toString());
        request.setAttribute("chartDataJson", dataJson.toString());

        // Preservação do estado dos filtros na tela
        request.setAttribute("nomeFiltro", nomeFiltro);
        request.setAttribute("statusFiltro", statusFiltro);

        // =====================================================
        // FORWARD
        // =====================================================
        RequestDispatcher dispatcher = request.getRequestDispatcher("/pages/relatorioTurno.jsp");
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
