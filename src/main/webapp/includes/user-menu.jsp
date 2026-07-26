<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>


    
    <div class="user-dropdown" id="userDropdown">
        <i class="fa-solid fa-circle-user user-pill-icon"></i>
        <span class="user-pill-name">${sessionScope.usuarioLogado.nome.toUpperCase()}</span>
        <i class="fa-solid fa-chevron-down dropdown-chevron"></i>
        <div class="dropdown-menu">
        
        	<c:if test="${empty sessionScope.usuarioLogado}">
				<div class="dropdown-item" onclick="toggleModal()"><i class="fa-solid fa-right-to-bracket"></i> Login</div>
			</c:if>
            <c:if test="${not empty sessionScope.usuarioLogado}">
				<a href="${pageContext.request.contextPath}/LogoutController" class="dropdown-item logout-item"><i class="fa-solid fa-right-from-bracket"></i> Sair</a>
			</c:if>
            
        </div>
    </div>

        