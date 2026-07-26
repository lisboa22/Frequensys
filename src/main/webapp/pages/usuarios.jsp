<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Usuários" scope="request" />

<!DOCTYPE html>
<html lang="pt-br" data-theme="${temaAtual}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gerenciamento de ${pageTitle} - FrequenSys</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/frequensys.css">
</head>
<body>

    <jsp:include page="/includes/sidebar.jsp" />

    <main class="main-content">
        <header class="page-header">
            <div class="header-title-group">
                <h2>${pageTitle}</h2>
            </div>
            <jsp:include page="/includes/user-menu.jsp" />
        </header>

        <div class="dashboard-container">
            <c:if test="${not empty sessionScope.mensagemSucesso}">
			    <div id="alerta-sucesso" class="alert alert-success">
			        
			        ${sessionScope.mensagemSucesso}
			        
			        <button onclick="fecharAlerta()" class="alert-close-btn">
			            <!--&times;-->
			        </button>
			        
			    </div>
			    <% session.removeAttribute("mensagemSucesso"); %>
			</c:if>

            <div class="table-container">
                <div class="table-header-row">
                    <div class="table-title">Usuários Cadastrados</div>
                    <div class="header-actions">
                    	<button class="btn-report" onclick="window.location.href='${pageContext.request.contextPath}/RelatorioUsuarioController'">
                            <i class="fa-solid fa-chart-bar"></i> Relatório
                        </button>
                        <button class="btn-primary" onclick="openModal()">
                            <i class="fa-solid fa-plus"></i> Novo Usuário
                        </button>
                    </div>
                </div>

                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Nome</th>
                            <th>Login</th>
                            <th>Email</th>
                            <th>Status</th>
                            <th class="text-right">Ações</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="u" items="${usuarios}">
                            <tr>
                                <td>${u.id}</td>
                                <td class="cell-strong">${u.nome}</td>
                                <td>${u.login}</td>
                                <td>${u.email}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${u.status == 'ATIVO'}">
                                            <span class="status-badge status-ativo">ATIVO</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-badge status-inativo">INATIVO</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="text-right">
                                    <!-- 🔥 SENHA REMOVIDA DAQUI -->
                                    <button class="btn-icon" onclick="openModalEditar('${u.id}','${u.nome}','${u.login}','${u.email}','${u.status}', '${u.perfil.id}')">
                                        <i class="fa-solid fa-pen"></i>
                                    </button>
                                    <button class="btn-icon delete" onclick="excluirUsuario(${u.id})">
                                        <i class="fa-solid fa-trash"></i>
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <div id="modalCadastro" class="modal-overlay">
        <div class="modal-box">
            <h3>Novo Usuário</h3>
            <form action="UsuarioController" method="post">
                <input type="hidden" name="action" value="adicionar">
                <div class="form-group">
                    <label>Nome</label>
                    <input type="text" name="nome" class="form-input" required>
                </div>
                <div class="form-group">
                    <label>Login</label>
                    <input type="text" name="login" class="form-input" required>
                </div>
                <div class="form-group">
                    <label>Email</label>
                    <input type="email" name="email" class="form-input" required>
                </div>
                <div class="form-group">
                    <label>Status</label>
                    <select name="status" class="form-input">
                        <option value="ATIVO">ATIVO</option>
                        <option value="INATIVO">INATIVO</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Perfil</label>
                    <select name="perfil" id="perfil" class="form-input" required>
				        <option value="">Selecione...</option>
				        <c:forEach var="p" items="${perfis}">
				            <option value="${p.id}">${p.nome}</option>
				        </c:forEach>
				    </select>
                </div>
                <div class="form-group">
                    <label>Senha</label>
                    <input type="password" name="senha" class="form-input" required>
                </div>
                <div class="modal-actions">
                    <button type="button" class="btn btn-outline" onclick="closeModal()">Cancelar</button>
                    <button type="submit" class="btn btn-primary">Salvar</button>
                </div>
            </form>
        </div>
    </div>

    <div id="modalEditar" class="modal-overlay">
        <div class="modal-box">
            <h3>Editar Usuário</h3>
            <form action="UsuarioController" method="post">
                <input type="hidden" name="action" value="editar">
                <input type="hidden" name="id" id="edit_id">

                <div class="form-group">
                    <label>Nome</label>
                    <input type="text" name="nome" id="edit_nome" class="form-input" required>
                </div>
                <div class="form-group">
                    <label>Login</label>
                    <input type="text" name="login" id="edit_login" class="form-input" required>
                </div>
                <div class="form-group">
                    <label>Email</label>
                    <input type="email" name="email" id="edit_email" class="form-input" required>
                </div>
                <div class="form-group">
                    <label>Status</label>
                    <select name="status" id="edit_status" class="form-input">
                        <option value="ATIVO">ATIVO</option>
                        <option value="INATIVO">INATIVO</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Perfil</label>
                    <select name="idperfil" id="edit_idperfil" class="form-input" required>
				        <option value="">Selecione...</option>
				        <c:forEach var="p" items="${perfis}">
				            <option value="${p.id}">${p.nome}</option>
				        </c:forEach>
				    </select>
                </div>
                

                <!-- 🔐 NOVA REGRA DE SENHA -->
                <div class="form-group">
                    <label>Nova Senha (opcional)</label>
                    <input type="password" name="senha" id="edit_senha" class="form-input" placeholder="Deixe em branco para não alterar">
                </div>

                <div class="modal-actions">
                    <button type="button" class="btn btn-outline" onclick="closeModalEditar()">Cancelar</button>
                    <button type="submit" class="btn btn-primary">Atualizar</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openModal() { document.getElementById('modalCadastro').classList.add('show'); }
        function closeModal() { document.getElementById('modalCadastro').classList.remove('show'); }
        
        // 🔥 SEM SENHA AQUI
        function openModalEditar(id, nome, login, email, status, idperfil) {
            document.getElementById('edit_id').value = id;
            document.getElementById('edit_nome').value = nome;
            document.getElementById('edit_login').value = login;
            document.getElementById('edit_email').value = email;
            document.getElementById('edit_status').value = status;
            document.getElementById('edit_idperfil').value = idperfil;

            // 🔐 GARANTE CAMPO LIMPO
            document.getElementById('edit_senha').value = '';

            document.getElementById('modalEditar').classList.add('show');
        }

        function closeModalEditar() { document.getElementById('modalEditar').classList.remove('show'); }

        function excluirUsuario(id) {
            if (confirm("Deseja excluir este usuário?")) {
                const form = document.createElement("form");
                form.method = "post";
                form.action = "UsuarioController";

                const action = document.createElement("input");
                action.type = "hidden"; action.name = "action"; action.value = "deletar";

                const idInput = document.createElement("input");
                idInput.type = "hidden"; idInput.name = "id"; idInput.value = id;

                form.appendChild(action); 
                form.appendChild(idInput);

                document.body.appendChild(form);
                form.submit();
            }
        }

        const dropdown = document.getElementById('userDropdown');
        if(dropdown) {
            dropdown.addEventListener('click', (e) => {
                e.stopPropagation();
                dropdown.classList.toggle('open');
            });
        }
        window.addEventListener('click', () => {
            if(dropdown) dropdown.classList.remove('open');
        });

        setTimeout(() => {
            const alerta = document.getElementById('alerta-sucesso');
            if (alerta) {
                alerta.style.transition = "opacity 0.5s ease";
                alerta.style.opacity = "0";
                setTimeout(() => {
                    alerta.style.display = 'none';
                }, 500);
            }
        }, 4000);
    </script>
</body>
</html>