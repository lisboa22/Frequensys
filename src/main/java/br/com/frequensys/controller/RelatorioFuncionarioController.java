package br.com.frequensys.controller;

import br.com.frequensys.dao.FuncionarioDAO;
import br.com.frequensys.dao.SetorDAO;
import br.com.frequensys.model.Funcionario;
import br.com.frequensys.model.Setor;
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
 * Controller responsável pelo Relatório de Funcionários.
 *
 * Segue o mesmo padrão adotado nos demais relatórios (Setor, Turno, Frequência):
 * - Verifica apenas se há sessão ativa (sem exigir isAdmin(), assim como os outros relatórios).
 * - Aplica filtros dinâmicos vindos da querystring (GET) e encaminha para a JSP.
 * - Expõe um endpoint AJAX (action=dadosGrafico) que devolve, em JSON, as admissões
 *   por mês de um ano específico — usado pelo seletor de ano do gráfico sem reload de página.
 */
@WebServlet("/RelatorioFuncionarioController")
public class RelatorioFuncionarioController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private FuncionarioDAO funcionarioDAO;
    private SetorDAO       setorDAO;

    @Override
    public void init() throws ServletException {
        try {
            funcionarioDAO = new FuncionarioDAO(Conexao.getConnection());
            setorDAO       = new SetorDAO(Conexao.getConnection());
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
     * e monta os dados iniciais do gráfico de admissões por mês.
     *
     * Atributos enviados para a JSP:
     * - "funcionarios"       → List<Funcionario> filtrada
     * - "setores"            → List<Setor> para popular o select do formulário
     * - "totalFuncionarios"  → total de funcionários no filtro atual
     * - "totalAtivos"        → total com status ATIVO
     * - "totalInativos"      → total com status INATIVO
     * - "totalAdmissoesAno"  → soma das admissões no ano selecionado do gráfico
     * - "admissoesPorMes"    → int[12] usado na renderização inicial do Chart.js
     * - "anosDisponiveis"    → anos com admissões, para o seletor de ano
     * - "anoSelecionado"     → ano atualmente selecionado no gráfico
     */
    private void exibirRelatorio(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        String nome       = request.getParameter("nome");
        String idSetorStr = request.getParameter("idSetor");
        String status     = request.getParameter("status");
        String dataInicio = request.getParameter("dataInicio");
        String dataFim    = request.getParameter("dataFim");

        Integer idSetor = (idSetorStr != null && !idSetorStr.isBlank())
                         ? Integer.parseInt(idSetorStr) : null;

        List<Funcionario> funcionarios = funcionarioDAO.listarFuncionariosFiltrados(
            nome, idSetor, status, dataInicio, dataFim
        );

        // ── KPIs calculados a partir da lista já filtrada ──────────────────
        int totalFuncionarios = funcionarios.size();
        int totalAtivos       = 0;
        int totalInativos     = 0;

        for (Funcionario f : funcionarios) {
            if ("ATIVO".equalsIgnoreCase(f.getStatus())) {
                totalAtivos++;
            } else if ("INATIVO".equalsIgnoreCase(f.getStatus())) {
                totalInativos++;
            }
        }

        // ── Ano selecionado para o gráfico de admissões ────────────────────
        String anoParam = request.getParameter("ano");
        int anoSelecionado = (anoParam != null && !anoParam.isBlank())
                            ? Integer.parseInt(anoParam) : LocalDate.now().getYear();

        int[] admissoesPorMes = funcionarioDAO.contarAdmissoesPorMes(anoSelecionado);

        int totalAdmissoesAno = 0;
        for (int qtd : admissoesPorMes) {
            totalAdmissoesAno += qtd;
        }

        List<Integer> anosDisponiveis = funcionarioDAO.listarAnosAdmissao();
        List<Setor>   setores         = setorDAO.listarSetores();

        request.setAttribute("funcionarios",      funcionarios);
        request.setAttribute("setores",            setores);
        request.setAttribute("totalFuncionarios",  totalFuncionarios);
        request.setAttribute("totalAtivos",        totalAtivos);
        request.setAttribute("totalInativos",      totalInativos);
        request.setAttribute("totalAdmissoesAno",  totalAdmissoesAno);
        request.setAttribute("admissoesPorMes",    admissoesPorMes);
        request.setAttribute("anosDisponiveis",    anosDisponiveis);
        request.setAttribute("anoSelecionado",     anoSelecionado);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/pages/relatorioFuncionario.jsp");
        dispatcher.forward(request, response);
    }

    // ==========================
    // AJAX — DADOS DO GRÁFICO
    // ==========================

    /**
     * Endpoint AJAX chamado ao trocar o ano no seletor do gráfico.
     * Retorna um JSON com 12 posições (admissões por mês), sem recarregar a página.
     */
    private void dadosGrafico(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        String anoParam = request.getParameter("ano");
        int ano = (anoParam != null && !anoParam.isBlank())
                 ? Integer.parseInt(anoParam) : LocalDate.now().getYear();

        int[] admissoesPorMes = funcionarioDAO.contarAdmissoesPorMes(ano);

        response.setContentType("application/json; charset=UTF-8");

        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < admissoesPorMes.length; i++) {
            json.append(admissoesPorMes[i]);
            if (i < admissoesPorMes.length - 1) {
                json.append(",");
            }
        }
        json.append("]");

        PrintWriter out = response.getWriter();
        out.write(json.toString());
        out.flush();
    }
}
