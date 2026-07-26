package br.com.frequensys.controller;

import br.com.frequensys.dao.FuncionarioDAO;
import br.com.frequensys.dao.JustificativaDAO;
import br.com.frequensys.model.Funcionario;
import br.com.frequensys.model.Justificativa;
import br.com.frequensys.utils.Conexao;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDate;
import java.util.List;

/**
 * Controller responsável pelo Relatório de Justificativas.
 *
 * Segue o mesmo padrão adotado nos demais relatórios (Setor, Turno, Frequência, Funcionário):
 * - Verifica apenas se há sessão ativa (sem exigir isAdmin()).
 * - Aplica filtros dinâmicos vindos da querystring (GET) e encaminha para a JSP.
 * - Expõe um endpoint AJAX (action=dadosGrafico) que devolve, em JSON, as justificativas
 *   abertas por mês (com base em dataInicio) de um ano específico.
 */
@WebServlet("/RelatorioJustificativaController")
public class RelatorioJustificativaController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private JustificativaDAO justificativaDAO;
    private FuncionarioDAO   funcionarioDAO;

    @Override
    public void init() throws ServletException {
        try {
            justificativaDAO = new JustificativaDAO(Conexao.getConnection());
            funcionarioDAO   = new FuncionarioDAO(Conexao.getConnection());
        } catch (Exception e) {
            throw new ServletException("Erro ao inicializar DAOs", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Evita que o navegador restaure uma versão "congelada" desta página
        // via cache local ou bfcache ao usar os botões voltar/avançar.
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("usuarioLogado") == null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("dadosGrafico".equals(action)) {
                dadosGrafico(request, response);
                return;
            }

            exibirRelatorio(request, response);

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ==========================
    // EXIBIR RELATÓRIO
    // ==========================

    /**
     * Aplica os filtros recebidos, calcula os KPIs a partir da lista já filtrada
     * e monta os dados iniciais do gráfico de justificativas por mês.
     *
     * Atributos enviados para a JSP:
     * - "justificativas"        → List<Justificativa> filtrada
     * - "funcionarios"          → List<Funcionario> para popular o select do formulário
     * - "totalJustificativas"   → total no filtro atual
     * - "totalPendentes"        → total com status PENDENTE
     * - "totalAprovadas"        → total com status APROVADO
     * - "totalReprovadas"       → total com status REPROVADO
     * - "justificativasPorMes"  → int[12] usado na renderização inicial do Chart.js
     * - "anosDisponiveis"       → anos com justificativas, para o seletor de ano
     * - "anoSelecionado"        → ano atualmente selecionado no gráfico
     */
    private void exibirRelatorio(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        String idFuncionarioStr = request.getParameter("idFuncionario");
        String tipo              = request.getParameter("tipo");
        String status            = request.getParameter("status");
        String dataInicio        = request.getParameter("dataInicio");
        String dataFim           = request.getParameter("dataFim");

        Integer idFuncionario = (idFuncionarioStr != null && !idFuncionarioStr.isBlank())
                               ? Integer.parseInt(idFuncionarioStr) : null;

        List<Justificativa> justificativas = justificativaDAO.listarJustificativasFiltradas(
            idFuncionario, tipo, status, dataInicio, dataFim
        );

        // ── KPIs calculados a partir da lista já filtrada ──────────────────
        int totalJustificativas = justificativas.size();
        int totalPendentes      = 0;
        int totalAprovadas      = 0;
        int totalReprovadas     = 0;

        for (Justificativa j : justificativas) {
            if ("PENDENTE".equalsIgnoreCase(j.getStatus())) {
                totalPendentes++;
            } else if ("APROVADO".equalsIgnoreCase(j.getStatus())) {
                totalAprovadas++;
            } else if ("REPROVADO".equalsIgnoreCase(j.getStatus())) {
                totalReprovadas++;
            }
        }

        // ── Ano selecionado para o gráfico de justificativas ───────────────
        String anoParam = request.getParameter("ano");
        int anoSelecionado = (anoParam != null && !anoParam.isBlank())
                            ? Integer.parseInt(anoParam) : LocalDate.now().getYear();

        int[] justificativasPorMes = justificativaDAO.contarJustificativasPorMes(anoSelecionado);
        List<Integer> anosDisponiveis = justificativaDAO.listarAnosJustificativa();

        List<Funcionario> funcionarios = funcionarioDAO.listarFuncionarios();

        request.setAttribute("justificativas",       justificativas);
        request.setAttribute("funcionarios",          funcionarios);
        request.setAttribute("totalJustificativas",   totalJustificativas);
        request.setAttribute("totalPendentes",        totalPendentes);
        request.setAttribute("totalAprovadas",        totalAprovadas);
        request.setAttribute("totalReprovadas",       totalReprovadas);
        request.setAttribute("justificativasPorMes",  justificativasPorMes);
        request.setAttribute("anosDisponiveis",       anosDisponiveis);
        request.setAttribute("anoSelecionado",        anoSelecionado);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/pages/relatorioJustificativa.jsp");
        dispatcher.forward(request, response);
    }

    // ==========================
    // AJAX — DADOS DO GRÁFICO
    // ==========================

    /**
     * Endpoint AJAX chamado ao trocar o ano no seletor do gráfico.
     * Retorna um JSON com 12 posições (justificativas por mês), sem recarregar a página.
     */
    private void dadosGrafico(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        String anoParam = request.getParameter("ano");
        int ano = (anoParam != null && !anoParam.isBlank())
                 ? Integer.parseInt(anoParam) : LocalDate.now().getYear();

        int[] justificativasPorMes = justificativaDAO.contarJustificativasPorMes(ano);

        response.setContentType("application/json; charset=UTF-8");

        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < justificativasPorMes.length; i++) {
            json.append(justificativasPorMes[i]);
            if (i < justificativasPorMes.length - 1) {
                json.append(",");
            }
        }
        json.append("]");

        PrintWriter out = response.getWriter();
        out.write(json.toString());
        out.flush();
    }
}