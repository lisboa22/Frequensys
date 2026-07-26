package br.com.frequensys.controller;

import br.com.frequensys.dao.PerfilDAO;
import br.com.frequensys.dao.UsuarioDAO;
import br.com.frequensys.model.Perfil;
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
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Controller responsável pelo Relatório de Usuários.
 *
 * Segue o mesmo padrão arquitetural dos demais relatórios (RelatorioSetor,
 * RelatorioTurno, RelatorioFuncionario, RelatorioJustificativa,
 * RelatorioFuncionarioTurno):
 * - filter-card (form GET) → KPI row → chart-card → export-card → detail-card
 *
 * Como Usuario não possui um campo de data (ex.: dataCadastro) para compor
 * uma série temporal, o gráfico deste relatório é um doughnut de distribuição
 * por Perfil — mesmo padrão adotado em RelatorioSetor para entidades sem
 * série temporal natural.
 *
 * Controle de acesso: apenas valida sessão ativa (isAdmin não é exigido aqui,
 * mantido apenas por consistência com os demais controllers de relatório).
 */
@WebServlet("/RelatorioUsuarioController")
public class RelatorioUsuarioController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private UsuarioDAO usuarioDAO;
    private PerfilDAO  perfilDAO;

    @Override
    public void init() throws ServletException {
        try {
            usuarioDAO = new UsuarioDAO(Conexao.getConnection());
            perfilDAO  = new PerfilDAO(Conexao.getConnection());
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
            exibirRelatorio(request, response);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ==========================
    // EXIBIR RELATÓRIO
    // ==========================

    /**
     * Aplica os filtros recebidos, monta KPIs, dados do gráfico (doughnut por
     * perfil) e a listagem detalhada, encaminhando tudo para a JSP do relatório.
     */
    private void exibirRelatorio(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        String nome           = request.getParameter("nome");
        String idPerfilParam  = request.getParameter("idPerfil");
        String status         = request.getParameter("status");

        Integer idPerfil = (idPerfilParam != null && !idPerfilParam.isBlank())
                ? Integer.valueOf(idPerfilParam) : null;

        // ── Listagem filtrada ────────────────────────────────────────────
        List<Usuario> lista = usuarioDAO.listarUsuariosFiltrados(nome, idPerfil, status);

        // ── KPIs e dados do gráfico (derivados da listagem já filtrada) ──
        int totalUsuarios      = lista.size();
        int totalAtivos        = 0;
        int totalInativos      = 0;
        int totalAdministradores = 0;

        // Mapa idUsuario → iniciais (ex.: "João Silva" → "JS"), usado pela JSP
        // para exibir o avatar sem precisar de lógica de string na página.
        Map<Integer, String> mapaIniciais = new LinkedHashMap<>();

        // Distribuição de usuários por perfil, para o gráfico doughnut.
        Map<String, Integer> distribuicaoPorPerfil = new LinkedHashMap<>();

        for (Usuario u : lista) {
            boolean ativo = u.getStatus() != null && u.getStatus().trim().equalsIgnoreCase("ATIVO");
            if (ativo) {
                totalAtivos++;
            } else {
                totalInativos++;
            }

            if (u.getPerfil() != null && u.getPerfil().getNome() != null
                    && u.getPerfil().getNome().trim().equalsIgnoreCase("ADMINISTRADOR")) {
                totalAdministradores++;
            }

            mapaIniciais.put(u.getId(), gerarIniciais(u.getNome()));

            String nomePerfil = (u.getPerfil() != null && u.getPerfil().getNome() != null)
                    ? u.getPerfil().getNome() : "Sem Perfil";
            distribuicaoPorPerfil.merge(nomePerfil, 1, Integer::sum);
        }

        // ── Combos de filtro ──────────────────────────────────────────────
        List<Perfil> listaPerfis = perfilDAO.listarPerfis();

        request.setAttribute("usuarios", lista);
        request.setAttribute("perfis",   listaPerfis);
        request.setAttribute("mapaIniciais", mapaIniciais);

        request.setAttribute("totalUsuarios",       totalUsuarios);
        request.setAttribute("totalAtivos",          totalAtivos);
        request.setAttribute("totalInativos",        totalInativos);
        request.setAttribute("totalAdministradores", totalAdministradores);

        request.setAttribute("perfisLabels", new java.util.ArrayList<>(distribuicaoPorPerfil.keySet()));
        request.setAttribute("perfisValores", new java.util.ArrayList<>(distribuicaoPorPerfil.values()));

        RequestDispatcher dispatcher = request.getRequestDispatcher("/pages/relatoriousuarios.jsp");
        dispatcher.forward(request, response);
    }

    // ==========================
    // HELPER — iniciais para avatar
    // ==========================

    /**
     * Gera as iniciais de um nome completo (ex.: "João da Silva" → "JS"),
     * usando a primeira letra do primeiro e do último token. Caso o nome
     * tenha apenas uma palavra, retorna suas duas primeiras letras.
     */
    private String gerarIniciais(String nomeCompleto) {
        if (nomeCompleto == null || nomeCompleto.isBlank()) {
            return "?";
        }

        String[] partes = nomeCompleto.trim().split("\\s+");

        if (partes.length == 1) {
            return partes[0].length() >= 2
                    ? partes[0].substring(0, 2).toUpperCase()
                    : partes[0].substring(0, 1).toUpperCase();
        }

        String primeira = partes[0].substring(0, 1).toUpperCase();
        String ultima   = partes[partes.length - 1].substring(0, 1).toUpperCase();
        return primeira + ultima;
    }
}
