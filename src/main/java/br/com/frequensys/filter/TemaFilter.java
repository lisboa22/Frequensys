package br.com.frequensys.filter;

import br.com.frequensys.dao.PreferenciaDAO;
import br.com.frequensys.model.Preferencia;
import br.com.frequensys.utils.Conexao;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;

import java.io.IOException;

/**
 * Filtro responsável por disponibilizar o tema atual (claro/escuro) para
 * todas as páginas JSP do sistema, através do atributo de request "temaAtual"
 * ("dark" ou "light").
 *
 * O valor é lido da tabela "preferencia" (configuração única e global do
 * sistema, controlada em PreferenciaController/preferencias.jsp) e mantido
 * em cache na aplicação (ServletContext), para evitar uma consulta ao banco
 * a cada requisição. O cache é invalidado sempre que o tema é alterado
 * (ver PreferenciaController.salvarTema / salvarPreferencia).
 *
 * Mapeamento sugerido no web.xml (ou anotação @WebFilter abaixo, se o
 * projeto usa Servlet 3.0+ com escaneamento automático):
 *
 * <filter>
 *     <filter-name>TemaFilter</filter-name>
 *     <filter-class>br.com.frequensys.filter.TemaFilter</filter-class>
 * </filter>
 * <filter-mapping>
 *     <filter-name>TemaFilter</filter-name>
 *     <url-pattern>/*</url-pattern>
 * </filter-mapping>
 */
@WebFilter("/*")
public class TemaFilter implements Filter {

    public static final String ATRIBUTO_APP_TEMA = "temaGlobalCache";

    private PreferenciaDAO preferenciaDAO;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        try {
            preferenciaDAO = new PreferenciaDAO(Conexao.getConnection());
        } catch (Exception e) {
            throw new ServletException("Erro ao inicializar PreferenciaDAO no TemaFilter", e);
        }
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        ServletContext contexto = httpRequest.getServletContext();

        String tema = (String) contexto.getAttribute(ATRIBUTO_APP_TEMA);

        // Cache em nível de aplicação: só consulta o banco se ainda não
        // houver valor calculado (populado na primeira requisição, ou
        // reiniciado manualmente pelo controller ao salvar uma alteração).
        if (tema == null) {
            tema = carregarTemaDoBanco();
            contexto.setAttribute(ATRIBUTO_APP_TEMA, tema);
        }

        httpRequest.setAttribute("temaAtual", tema);

        chain.doFilter(request, response);
    }

    private String carregarTemaDoBanco() {
        try {
            Preferencia preferencia = preferenciaDAO.buscarPreferencia();
            boolean modoEscuro = (preferencia == null) || preferencia.getModoEscuro();
            return modoEscuro ? "dark" : "light";
        } catch (Exception e) {
            // Se algo falhar na leitura, cai no tema escuro (padrão atual do sistema)
            // em vez de quebrar a página inteira.
            return "dark";
        }
    }

    @Override
    public void destroy() {
        // nada a liberar
    }
}
