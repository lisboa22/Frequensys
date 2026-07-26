<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%--
    =====================================================================
    COMPONENTE JSP: SIDEBAR DE NAVEGAÇÃO DO SISTEMA PATRIMWEB
    =====================================================================

    PROPÓSITO:
    Este arquivo JSP representa o componente visual da barra lateral
    (sidebar) do sistema PatrimWeb. Ele é responsável por disponibilizar
    a navegação principal entre os módulos do sistema.

    RESPONSABILIDADES:
    - Exibir identidade visual do sistema (logo + nome).
    - Disponibilizar links de navegação para os principais controllers.
    - Destacar dinamicamente o módulo atualmente ativo.
    - Permitir interação responsiva em dispositivos móveis através
      do overlay e da função JavaScript toggleSidebar().

    REGRAS DE NEGÓCIO IMPLEMENTADAS:
    - O item ativo do menu é definido dinamicamente pela variável
      "pageTitle", enviada pelo controller responsável pela página.
    - A navegação utiliza o contextPath da aplicação para garantir
      funcionamento correto independentemente do ambiente de deploy.

    INTERAÇÃO COM BACK-END:
    - Utiliza Expression Language (EL) para acessar:
        • pageContext.request.contextPath
        • variável pageTitle definida no request.
    - Cada link aponta para um Controller Servlet responsável
      pelo carregamento do respectivo módulo.

    PONTOS CRÍTICOS:
    - A variável "pageTitle" deve ser definida corretamente pelos
      controllers, caso contrário o destaque visual do menu não
      funcionará.
    - O ID "sidebar" é utilizado por scripts JavaScript para controle
      de abertura/fechamento em dispositivos móveis.
    - O overlay depende da função JavaScript toggleSidebar(),
      definida em scripts comuns da aplicação.

    OBSERVAÇÃO:
    Este componente não possui acesso direto a banco de dados.
    Atua apenas como camada de apresentação (View).
--%>

<aside class="sidebar">
        <div class="brand-area">
            <div class="logo-square"><i class="fa-solid fa-calendar" style="color: white; font-size: 1.2rem;"></i></div>
            <div class="brand-name">FrequenSys</div>
        </div>
        <nav class="nav-menu">
            <a href="${pageContext.request.contextPath}/" class="nav-item ${pageTitle == 'Registrar Frequência' ? 'active' : ''}"><i class="fa-solid fa-user-check"></i> Registrar Frequência</a>
            
            <c:set var="perfil" value="${sessionScope.usuarioLogado.perfil.nome}" />
            <c:if test="${not empty sessionScope.usuarioLogado
			          and not empty sessionScope.usuarioLogado.perfil
			          and perfil != null
			          and perfil.toUpperCase() eq 'ADMINISTRADOR'
			          or  perfil.toUpperCase() eq 'OPERADOR'}">
			    <a href="${pageContext.request.contextPath}/DashboardController" class="nav-item ${pageTitle == 'Painel' ? 'active' : ''}"><i class="fa-solid fa-house"></i> Painel</a>
			    <a href="${pageContext.request.contextPath}/SetorController" class="nav-item ${pageTitle == 'Setores' ? 'active' : ''}"><i class="fa-solid fa-sitemap"></i> Setor</a>
	            <a href="${pageContext.request.contextPath}/TurnoController" class="nav-item ${pageTitle == 'Turnos' ? 'active' : ''}"><i class="fa-solid fa-clock"></i> Turno</a>
	            <a href="${pageContext.request.contextPath}/FuncionarioController" class="nav-item ${pageTitle == 'Funcionários' ? 'active' : ''}"><i class="fa-solid fa-user-tie"></i> Funcionário</a>
	            <a href="${pageContext.request.contextPath}/JustificativaController" class="nav-item ${pageTitle == 'Justificativas' ? 'active' : ''}"><i class="fa-solid fa-clipboard-check"></i> Justificativa</a>
	            <a href="${pageContext.request.contextPath}/FuncionarioTurnoController" class="nav-item ${pageTitle == 'Funcionário Turno' ? 'active' : ''}"><i class="fa-solid fa-user-clock"></i> Funcionário Turno</a>
	            <a href="${pageContext.request.contextPath}/RegistroFrequenciaController" class="nav-item ${pageTitle == 'Registros de Frequência' ? 'active' : ''}"><i class="fa-solid fa-user-clock"></i> Registro Manual</a>
			</c:if>
			  
        	<c:if test="${not empty sessionScope.usuarioLogado
			          and not empty sessionScope.usuarioLogado.perfil
			          and perfil != null
			          and perfil.toUpperCase() eq 'ADMINISTRADOR'}">
			    <!--<a href="${pageContext.request.contextPath}/PerfilController" class="nav-item ${pageTitle == 'Perfil' ? 'active' : ''}"><i class="fa-solid fa-shield-halved"></i> Perfil</a>-->
			    <a href="${pageContext.request.contextPath}/UsuarioController" class="nav-item ${pageTitle == 'Usuários' ? 'active' : ''}"><i class="fa-solid fa-users"></i> Usuários</a>
			    <a href="${pageContext.request.contextPath}/PreferenciaController" class="nav-item ${pageTitle == 'Preferências' ? 'active' : ''}"><i class="fa-solid fa-gear"></i> Preferências</a>
			</c:if>
            
        </nav>
        <div style="padding: 20px; color: #475569; font-size: 0.75rem; text-align: center;">v 1.0.0</div>
    </aside>

<%--
    Overlay utilizado em dispositivos móveis.

    FUNÇÃO:
    - Escurecer o restante da tela quando a sidebar estiver aberta.
    - Permitir fechamento da sidebar ao clicar fora dela.

    INTERAÇÃO:
    - Dispara a função JavaScript toggleSidebar(), responsável
      por alternar o estado visual da sidebar.

    PONTO CRÍTICO:
    - O ID deve permanecer consistente com o utilizado nos scripts
      JavaScript para garantir o funcionamento correto.
--%>
<div class="mobile-overlay" id="overlay" onclick="toggleSidebar()"></div>
