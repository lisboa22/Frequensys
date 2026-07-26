package br.com.frequensys.controller;

import br.com.frequensys.dao.FuncionarioDAO;
import br.com.frequensys.dao.RegistroFrequenciaDAO;
import br.com.frequensys.dao.TurnoDAO;
import br.com.frequensys.model.Usuario;
import br.com.frequensys.model.RegistroFrequencia;
import br.com.frequensys.utils.Conexao;

import java.io.IOException;
import java.sql.Connection;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.ArrayList;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/RelatorioFrequenciaController")
public class RelatorioFrequenciaController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private RegistroFrequenciaDAO registroDAO;
    private FuncionarioDAO funcionarioDAO;
    private TurnoDAO turnoDAO;

    // =========================================================
    // INIT
    // =========================================================
    @Override
    public void init() throws ServletException {
        try {
            Connection con = Conexao.getConnection();
            registroDAO = new RegistroFrequenciaDAO(con);
            funcionarioDAO = new FuncionarioDAO(con);
            turnoDAO = new TurnoDAO(con);
        } catch (Exception e) {
            throw new ServletException("Erro ao inicializar DAOs", e);
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

        // =====================================================
        // REQUISIÇÃO AJAX DO GRÁFICO (Mês a Mês)
        // =====================================================
        String action = request.getParameter("action");
        if ("dadosGrafico".equals(action)) {
            processarDadosGraficoAjax(request, response);
            return;
        }

        try {
            carregarRelatorio(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute(
                "mensagemErro",
                "Erro ao carregar relatório."
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
    // CARREGAR RELATÓRIO (Mapeamento dos Cards e Filtros)
    // =========================================================
    @SuppressWarnings("unchecked")
    private void carregarRelatorio(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        // =====================================================
        // FILTROS DO FORMULÁRIO
        // =====================================================
        String idFuncionarioStr = request.getParameter("idFuncionario");
        String dataInicioStr = request.getParameter("dataInicio");
        String dataFimStr = request.getParameter("dataFim");
        String idTurnoStr = request.getParameter("idTurno");
        String statusFiltro = request.getParameter("status");
        String tipoFiltro = request.getParameter("tipo");

        Integer idFuncionario = null;
        if (idFuncionarioStr != null && !idFuncionarioStr.isBlank()) {
            idFuncionario = Integer.parseInt(idFuncionarioStr);
        }

        // =====================================================
        // PROCESSAMENTO DE DATAS
        // =====================================================
        LocalDateTime dataInicio = null;
        LocalDateTime dataFim = null;

        if (dataInicioStr != null && !dataInicioStr.isBlank()) {
            dataInicio = LocalDate.parse(dataInicioStr).atStartOfDay();
        }

        if (dataFimStr != null && !dataFimStr.isBlank()) {
            dataFim = LocalDate.parse(dataFimStr).atTime(LocalTime.MAX);
        }

        // =====================================================
        // CARREGAMENTO DAS LISTAS AUXILIARES DO BANCO
        // =====================================================
        request.setAttribute("funcionarios", funcionarioDAO.listarFuncionarios());
        request.setAttribute("turnos", turnoDAO.listarTurnos());

        // =====================================================
        // CONSULTA DE REGISTROS BASE
        // =====================================================
        List<RegistroFrequencia> todosRegistros;

        if (idFuncionario != null && dataInicio != null && dataFim != null) {
            todosRegistros = (List<RegistroFrequencia>) registroDAO.listarPorFuncionarioEPeriodo(
                    idFuncionario, dataInicio, dataFim
            );
        } else if (idFuncionario != null) {
            todosRegistros = (List<RegistroFrequencia>) registroDAO.listarPorFuncionario(idFuncionario);
        } else {
            todosRegistros = (List<RegistroFrequencia>) registroDAO.listarRegistros();
        }

        // =====================================================
        // FILTRAGEM EM MEMÓRIA & CÁLCULO DOS CARDS / GRAFICO
        // =====================================================
        List<RegistroFrequencia> registrosFiltrados = new ArrayList<>();
        
        int totalPresente = 0;
        int totalFalta = 0;
        int totalAtraso = 0;
        int totalRegistros = 0;
        
        int[] contagemMeses = new int[12];
        String anoSelecionadoStr = request.getParameter("ano");
        int anoFiltroGrafico = (anoSelecionadoStr != null) ? Integer.parseInt(anoSelecionadoStr) : 2026;

        if (todosRegistros != null) {
            for (RegistroFrequencia r : todosRegistros) {
                
                // Aplicar filtros adicionais que não vão direto pelo método do DAO básico
                if (idTurnoStr != null && !idTurnoStr.isBlank() && r.getIdTurno() != Integer.parseInt(idTurnoStr)) {
                    continue;
                }
                if (statusFiltro != null && !statusFiltro.isBlank() && !statusFiltro.equalsIgnoreCase(r.getStatus())) {
                    continue;
                }
                if (tipoFiltro != null && !tipoFiltro.isBlank() && !tipoFiltro.equalsIgnoreCase(r.getTipo())) {
                    continue;
                }

                // Se passou nos filtros, adiciona na lista exibida na tabela
                registrosFiltrados.add(r);
                totalRegistros++;

                // Contagem para os blocos de KPI superiores
                if ("PRESENTE".equalsIgnoreCase(r.getStatus())) {
                    totalPresente++;
                } else if ("FALTA".equalsIgnoreCase(r.getStatus())) {
                    totalFalta++;
                } else if ("ATRASO".equalsIgnoreCase(r.getStatus())) {
                    totalAtraso++;
                }

                // Alimentação do Gráfico do ano corrente carregado na tela inicial
                if (r.getDatahora() != null && r.getDatahora().getYear() == anoFiltroGrafico) {
                    int mes = r.getDatahora().getMonthValue(); // 1 a 12
                    contagemMeses[mes - 1]++;
                }
            }
        }

        // =====================================================
        // INJEÇÃO DE ATRIBUTOS PARA O JSP
        // =====================================================
        request.setAttribute("registros", registrosFiltrados);
        request.setAttribute("totalPresente", totalPresente);
        request.setAttribute("totalFalta", totalFalta);
        request.setAttribute("totalAtraso", totalAtraso);
        request.setAttribute("totalRegistros", totalRegistros);
        request.setAttribute("registrosPorMes", contagemMeses);

        // Listas fixas de apoio para o componente select do gráfico
        request.setAttribute("anosDisponiveis", List.of(2025, 2026, 2027));
        request.setAttribute("anoSelecionado", anoFiltroGrafico);

        // Preservação do estado dos inputs na tela
        request.setAttribute("idFuncionarioSelecionado", idFuncionario);
        request.setAttribute("dataInicio", dataInicioStr);
        request.setAttribute("dataFim", dataFimStr);

        // =====================================================
        // FORWARD
        // =====================================================
        RequestDispatcher dispatcher = request.getRequestDispatcher("/pages/relatoriofrequencia.jsp");
        dispatcher.forward(request, response);
    }

    // =========================================================
    // PROCESSAR DADOS DO GRÁFICO (AJAX)
    // =========================================================
    @SuppressWarnings("unchecked")
    private void processarDadosGraficoAjax(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String anoStr = request.getParameter("ano");
        int anoAlvo = (anoStr != null) ? Integer.parseInt(anoStr) : 2026;
        
        int[] mesesArray = new int[12];

        try {
            // Busca os registros para compor os dados do ano requisitado via AJAX
            List<RegistroFrequencia> lista = (List<RegistroFrequencia>) registroDAO.listarRegistros();
            if (lista != null) {
                for (RegistroFrequencia r : lista) {
                    if (r.getDatahora() != null && r.getDatahora().getYear() == anoAlvo) {
                        int mes = r.getDatahora().getMonthValue();
                        mesesArray[mes - 1]++;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Converte o array Java estruturalmente para um formato JSON Puro [x,x,x...]
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < mesesArray.length; i++) {
            json.append(mesesArray[i]);
            if (i < mesesArray.length - 1) {
                json.append(",");
            }
        }
        json.append("]");

        response.getWriter().write(json.toString());
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