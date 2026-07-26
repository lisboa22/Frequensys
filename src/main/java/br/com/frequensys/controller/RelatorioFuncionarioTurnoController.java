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
import java.io.PrintWriter;
import java.time.LocalDate;
import java.time.Year;
import java.util.List;

/**
 * Controller responsável pelo Relatório de Funcionário x Turno.
 *
 * Segue o mesmo padrão arquitetural dos demais relatórios (RelatorioSetor,
 * RelatorioTurno, RelatorioFuncionario, RelatorioJustificativa):
 * - filter-card (form GET) → KPI row → chart-card (Chart.js) → export-card → detail-card
 *
 * Controle de acesso: apenas valida sessão ativa (isAdmin não é exigido aqui,
 * mantido apenas por consistência com os demais controllers, caso seja
 * necessário restringir no futuro).
 */
@WebServlet("/RelatorioFuncionarioTurnoController")
public class RelatorioFuncionarioTurnoController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private FuncionarioTurnoDAO funcionarioTurnoDAO;
    private FuncionarioDAO      funcionarioDAO;
    private TurnoDAO            turnoDAO;

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
            String action = request.getParameter("action");

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
     * Aplica os filtros recebidos, monta KPIs, dados do gráfico e a listagem
     * detalhada, encaminhando tudo para a JSP do relatório.
     */
    private void exibirRelatorio(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        String idFuncionarioParam = request.getParameter("idFuncionario");
        String idTurnoParam       = request.getParameter("idTurno");
        String status             = request.getParameter("status");
        String dataInicioParam    = request.getParameter("dataInicio");
        String dataFimParam       = request.getParameter("dataFim");
        String anoParam           = request.getParameter("ano");

        Integer idFuncionario = (idFuncionarioParam != null && !idFuncionarioParam.isBlank())
                ? Integer.valueOf(idFuncionarioParam) : null;
        Integer idTurno = (idTurnoParam != null && !idTurnoParam.isBlank())
                ? Integer.valueOf(idTurnoParam) : null;

        LocalDate dataInicio = (dataInicioParam != null && !dataInicioParam.isBlank())
                ? LocalDate.parse(dataInicioParam) : null;
        LocalDate dataFim = (dataFimParam != null && !dataFimParam.isBlank())
                ? LocalDate.parse(dataFimParam) : null;

        // ── Listagem filtrada ────────────────────────────────────────────
        List<FuncionarioTurno> lista = funcionarioTurnoDAO.listarFuncionarioTurnosFiltrados(
                idFuncionario, idTurno, status, dataInicio, dataFim);

        // ── KPIs (derivados da listagem já filtrada) ─────────────────────
        int totalVinculos    = lista.size();
        int totalAtivos      = 0;
        int totalEncerrados  = 0;
        java.util.Set<Integer> turnosEmUso = new java.util.HashSet<>();

        // Mapa idFuncionarioTurno → "ATIVO"/"ENCERRADO", usado pela JSP para exibir
        // o badge de status sem depender de comparação de datas via EL.
        java.util.Map<Integer, String> mapaStatusVinculo = new java.util.HashMap<>();

        LocalDate hoje = LocalDate.now();
        for (FuncionarioTurno ft : lista) {
            boolean ativo = ft.getDataFim() == null || !ft.getDataFim().isBefore(hoje);
            mapaStatusVinculo.put(ft.getId(), ativo ? "ATIVO" : "ENCERRADO");
            if (ativo) {
                totalAtivos++;
                turnosEmUso.add(ft.getTurno().getId());
            } else {
                totalEncerrados++;
            }
        }

        // ── Gráfico: vínculos iniciados por mês ──────────────────────────
        List<Integer> anosDisponiveis = funcionarioTurnoDAO.listarAnosDisponiveis();
        int anoSelecionado = (anoParam != null && !anoParam.isBlank())
                ? Integer.parseInt(anoParam)
                : (!anosDisponiveis.isEmpty() ? anosDisponiveis.get(0) : Year.now().getValue());

        int[] vinculosPorMes = funcionarioTurnoDAO.contarVinculosPorMes(anoSelecionado);

        // ── Combos de filtro ──────────────────────────────────────────────
        List<Funcionario> listaFuncionarios = funcionarioDAO.listarFuncionarios();
        List<Turno>       listaTurnos       = turnoDAO.listarTurnos();

        request.setAttribute("funcionarioTurnos", lista);
        request.setAttribute("funcionarios",      listaFuncionarios);
        request.setAttribute("turnos",            listaTurnos);
        request.setAttribute("mapaStatusVinculo", mapaStatusVinculo);

        request.setAttribute("totalVinculos",   totalVinculos);
        request.setAttribute("totalAtivos",     totalAtivos);
        request.setAttribute("totalEncerrados", totalEncerrados);
        request.setAttribute("totalTurnosEmUso", turnosEmUso.size());

        request.setAttribute("anosDisponiveis", anosDisponiveis);
        request.setAttribute("anoSelecionado",  anoSelecionado);
        request.setAttribute("vinculosPorMes",  vinculosPorMes);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/pages/relatoriofuncionarioturno.jsp");
        dispatcher.forward(request, response);
    }

    // ==========================
    // AJAX — DADOS DO GRÁFICO
    // ==========================

    /**
     * Retorna, em JSON, o array de 12 posições com a quantidade de vínculos
     * iniciados em cada mês do ano informado. Usado pelo seletor de ano do
     * gráfico via fetch(), sem recarregar a página.
     */
    private void dadosGrafico(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        response.setContentType("application/json; charset=UTF-8");

        int ano = Year.now().getValue();
        String anoParam = request.getParameter("ano");
        if (anoParam != null && !anoParam.isBlank()) {
            ano = Integer.parseInt(anoParam);
        }

        int[] dados = funcionarioTurnoDAO.contarVinculosPorMes(ano);

        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < dados.length; i++) {
            json.append(dados[i]);
            if (i < dados.length - 1) {
                json.append(",");
            }
        }
        json.append("]");

        try (PrintWriter out = response.getWriter()) {
            out.print(json.toString());
        }
    }
}
