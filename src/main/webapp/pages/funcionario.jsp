<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Funcionários" scope="request" />

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
            <div style="display: flex; align-items: center; gap: 15px;">
                <h2>${pageTitle}</h2>
            </div>
            <jsp:include page="/includes/user-menu.jsp" />
        </header>

        <div class="dashboard-container">

            <%-- Mensagem de sucesso --%>
            <c:if test="${not empty sessionScope.mensagemSucesso}">
                <div id="alerta-sucesso" style="position: relative; background: rgba(16, 185, 129, 0.1); color: #10b981; padding: 15px; border-radius: 8px; margin-bottom: 20px; border: 1px solid rgba(16, 185, 129, 0.2);">
                    ${sessionScope.mensagemSucesso}
                    <button onclick="fecharAlerta()"
                            style="position: absolute; top: 5px; right: 10px; background: transparent; border: none; font-size: 18px; cursor: pointer;">
                        
                    </button>
                </div>
                <% session.removeAttribute("mensagemSucesso"); %>
            </c:if>

            <%-- Mensagem de erro --%>
            <c:if test="${not empty sessionScope.mensagemErro}">
                <div id="alerta-erro" style="position: relative; background: rgba(239, 68, 68, 0.1); color: #ef4444; padding: 15px; border-radius: 8px; margin-bottom: 20px; border: 1px solid rgba(239, 68, 68, 0.2);">
                    ${sessionScope.mensagemErro}
                    <button onclick="document.getElementById('alerta-erro').style.display='none'"
                            style="position: absolute; top: 5px; right: 10px; background: transparent; border: none; font-size: 18px; cursor: pointer;">
                        
                    </button>
                </div>
                <% session.removeAttribute("mensagemErro"); %>
            </c:if>

            <div class="table-container">
                <div class="table-header-row">
                    <div class="table-title">Funcionários Cadastrados</div>
                    <div class="header-actions" style="display: flex; flex-direction: row; align-items: center; gap: 10px;">
                    	<button class="btn-report" onclick="window.location.href='${pageContext.request.contextPath}/RelatorioFuncionarioController'">
                            <i class="fa-solid fa-chart-bar"></i> Relatório
                        </button>
                        <button class="btn-primary" onclick="openModal()">
                            <i class="fa-solid fa-plus"></i> Novo Funcionário
                        </button>
                    </div>
                </div>

                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Nome</th>
                            <th>CPF</th>
                            <th>Matrícula</th>
                            <th>Email</th>
                            <th>Telefone</th>
                            <th>Admissão</th>
                            <th>Setor</th>
                            <th>Status</th>
                            <th>Token</th>
                            <th style="text-align: right;">Ações</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="f" items="${funcionarios}">
                            <tr>
                                <td>${f.id}</td>
                                <td style="font-weight: 500;">${f.nome}</td>
                                <td>${f.cpf}</td>
                                <td>${f.matricula}</td>
                                <td>${f.email}</td>
                                <td>${f.telefone}</td>
                                <td>
                                    <fmt:parseDate value="${f.dataAdmissao}" pattern="yyyy-MM-dd" var="dataFormatada" type="date" />
                                    <fmt:formatDate value="${dataFormatada}" pattern="dd/MM/yyyy" />
                                </td>
                                <td>${f.setor.nome}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${f.status == 'ATIVO'}">
                                            <span style="color: #10b981; background: rgba(16, 185, 129, 0.1); padding: 4px 8px; border-radius: 4px; font-size: 0.8rem;">ATIVO</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color: #94a3b8; background: rgba(148, 163, 184, 0.1); padding: 4px 8px; border-radius: 4px; font-size: 0.8rem;">INATIVO</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${f.token}</td>
                                <td style="text-align: right;">
                                    <button class="btn-icon"
                                            onclick="openModalEditar(
                                                '${f.id}',
                                                '${f.nome}',
                                                '${f.cpf}',
                                                '${f.matricula}',
                                                '${f.email}',
                                                '${f.telefone}',
                                                '${f.dataAdmissao}',
                                                '${f.status}',
                                                '${f.setor.id}',
                                                '${f.token}'
                                            )">
                                        <i class="fa-solid fa-pen"></i>
                                    </button>
                                    <button class="btn-icon delete" onclick="excluirFuncionario(${f.id})">
                                        <i class="fa-solid fa-trash"></i>
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty funcionarios}">
                            <tr>
                                <td colspan="10" style="text-align: center; color: #94a3b8; padding: 30px;">
                                    Nenhum funcionário cadastrado.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <%-- ================================== --%>
    <%-- MODAL: CADASTRAR NOVO FUNCIONÁRIO  --%>
    <%-- ================================== --%>
    <div id="modalCadastro" class="modal-overlay">
        <div class="modal-box">
            <h3>Novo Funcionário</h3>
            <form action="FuncionarioController" method="post">
                <input type="hidden" name="action" value="adicionar">

                <div class="form-group">
                    <label>Nome</label>
                    <input type="text" name="nome" class="form-input" required placeholder="Nome completo">
                </div>
                <div class="form-group">
                    <label>CPF</label>
                    <input type="text" name="cpf" id="cpf" class="form-input" required placeholder="000.000.000-00" maxlength="14">
                </div>
                <div class="form-group">
                    <label>Matrícula</label>
                    <input type="text" name="matricula" class="form-input" required placeholder="Ex: MAT-0001">
                </div>
                <div class="form-group">
                    <label>Email</label>
                    <input type="email" name="email" class="form-input" placeholder="email@exemplo.com">
                </div>
                <div class="form-group">
                    <label>Telefone</label>
                    <input type="text" name="telefone" id="telefone" class="form-input" placeholder="(00) 00000-0000" maxlength="15">
                </div>
                <div class="form-group">
                    <label>Data de Admissão</label>
                    <input type="date" name="dataAdmissao" class="form-input">
                </div>
                <div class="form-group">
                    <label>Setor</label>
                    <select name="idSetor" class="form-input" required>
                        <option value="">Selecione...</option>
                        <c:forEach var="s" items="${setores}">
                            <option value="${s.id}">${s.nome}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="form-group">
                    <label>Status</label>
                    <select name="status" class="form-input">
                        <option value="ATIVO">ATIVO</option>
                        <option value="INATIVO">INATIVO</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Token</label>
                    <input type="text" name="token" class="form-input" required placeholder="Ex: 8564">
                </div>

                <div style="margin-top: 20px; display: flex; gap: 10px; justify-content: flex-end;">
                    <button type="button" class="btn btn-outline" onclick="closeModal()">Cancelar</button>
                    <button type="submit" class="btn btn-primary">Salvar</button>
                </div>
            </form>
        </div>
    </div>

    <%-- ================================== --%>
    <%-- MODAL: EDITAR FUNCIONÁRIO          --%>
    <%-- ================================== --%>
    <div id="modalEditar" class="modal-overlay">
        <div class="modal-box">
            <h3>Editar Funcionário</h3>
            <form action="FuncionarioController" method="post">
                <input type="hidden" name="action"        value="editar">
                <input type="hidden" name="id" id="edit_id">

                <div class="form-group">
                    <label>Nome</label>
                    <input type="text" name="nome" id="edit_nome" class="form-input" required>
                </div>
                <div class="form-group">
                    <label>CPF</label>
                    <input type="text" name="cpf" id="edit_cpf" class="form-input" required maxlength="14">
                </div>
                <div class="form-group">
                    <label>Matrícula</label>
                    <input type="text" name="matricula" id="edit_matricula" class="form-input" required>
                </div>
                <div class="form-group">
                    <label>Email</label>
                    <input type="email" name="email" id="edit_email" class="form-input">
                </div>
                <div class="form-group">
                    <label>Telefone</label>
                    <input type="text" name="telefone" id="edit_telefone" class="form-input" maxlength="15">
                </div>
                <div class="form-group">
                    <label>Data de Admissão</label>
                    <input type="date" name="dataAdmissao" id="edit_dataAdmissao" class="form-input">
                </div>
                <div class="form-group">
                    <label>Setor</label>
                    <select name="idSetor" id="edit_idSetor" class="form-input" required>
                        <option value="">Selecione...</option>
                        <c:forEach var="s" items="${setores}">
                            <option value="${s.id}">${s.nome}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="form-group">
                    <label>Status</label>
                    <select name="status" id="edit_status" class="form-input">
                        <option value="ATIVO">ATIVO</option>
                        <option value="INATIVO">INATIVO</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Token</label>
                    <input type="text" name="token" id="edit_token" class="form-input" required placeholder="Ex: 8564">
                </div>

                <div style="margin-top: 20px; display: flex; gap: 10px; justify-content: flex-end;">
                    <button type="button" class="btn btn-outline" onclick="closeModalEditar()">Cancelar</button>
                    <button type="submit" class="btn btn-primary">Atualizar</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // ---- Modais ----
        function openModal() {
            document.getElementById('modalCadastro').classList.add('show');
        }

        function closeModal() {
            document.getElementById('modalCadastro').classList.remove('show');
        }

        function openModalEditar(id, nome, cpf, matricula, email, telefone, dataAdmissao, status, idSetor, token) {
            document.getElementById('edit_id').value = id;
            document.getElementById('edit_nome').value          = nome;
            document.getElementById('edit_cpf').value           = cpf;
            document.getElementById('edit_matricula').value     = matricula;
            document.getElementById('edit_email').value         = email;
            document.getElementById('edit_telefone').value      = telefone;
            document.getElementById('edit_dataAdmissao').value  = dataAdmissao; // formato yyyy-MM-dd compatível com input[type=date]
            document.getElementById('edit_status').value        = status;
            document.getElementById('edit_idSetor').value       = idSetor;
            document.getElementById('edit_token').value      	= token;

            document.getElementById('modalEditar').classList.add('show');
        }

        function closeModalEditar() {
            document.getElementById('modalEditar').classList.remove('show');
        }

        // ---- Excluir ----
        function excluirFuncionario(id) {
            if (confirm("Deseja excluir este funcionário?")) {
                const form = document.createElement("form");
                form.method = "post";
                form.action = "FuncionarioController";

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

        // ---- Fechar alerta de sucesso ----
        function fecharAlerta() {
            const alerta = document.getElementById('alerta-sucesso');
            if (alerta) alerta.style.display = 'none';
        }

        // Auto-fechar alerta de sucesso após 4 segundos
        setTimeout(() => {
            const alerta = document.getElementById('alerta-sucesso');
            if (alerta) {
                alerta.style.transition = "opacity 0.5s ease";
                alerta.style.opacity = "0";
                setTimeout(() => alerta.style.display = 'none', 500);
            }
        }, 4000);

        // ---- Dropdown do menu de usuário ----
        const dropdown = document.getElementById('userDropdown');
        if (dropdown) {
            dropdown.addEventListener('click', (e) => {
                e.stopPropagation();
                dropdown.classList.toggle('open');
            });
        }
        window.addEventListener('click', () => {
            if (dropdown) dropdown.classList.remove('open');
        });
        
        //Mascara de CPF e Telefone.
        const inputCPF = document.getElementById('cpf');
        const inputTelefone = document.getElementById('telefone');
        

        /*
            Máscara dinâmica de CPF.
            Regra de apresentação: força padrão XXX.XXX.XXX-XX.
        */
        inputCPF.addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, "");
            value = value.replace(/(\d{3})(\d)/, "$1.$2");
            value = value.replace(/(\d{3})(\d)/, "$1.$2");
            value = value.replace(/(\d{3})(\d{1,2})$/, "$1-$2");
            e.target.value = value;
        });

        /*
            Máscara dinâmica de telefone.
            Padroniza entrada antes do envio ao backend.
        */
        inputTelefone.addEventListener('input', function(e) {
            let value = e.target.value.replace(/\D/g, "");
            value = value.replace(/^(\d{2})(\d)/g, "($1) $2");
            value = value.replace(/(\d)(\d{4})$/, "$1-$2");
            e.target.value = value;
        });
        
            
            const inputCPFEdt = document.getElementById('edit_cpf');
            const inputTelefoneEdt = document.getElementById('edit_telefone');
        
        /*
        Máscara dinâmica de CPF.
        Regra de apresentação: força padrão XXX.XXX.XXX-XX.
    */
    inputCPFEdt.addEventListener('input', function(e) {
        let value = e.target.value.replace(/\D/g, "");
        value = value.replace(/(\d{3})(\d)/, "$1.$2");
        value = value.replace(/(\d{3})(\d)/, "$1.$2");
        value = value.replace(/(\d{3})(\d{1,2})$/, "$1-$2");
        e.target.value = value;
    });

    /*
        Máscara dinâmica de telefone.
        Padroniza entrada antes do envio ao backend.
    */
    inputTelefoneEdt.addEventListener('input', function(e) {
        let value = e.target.value.replace(/\D/g, "");
        value = value.replace(/^(\d{2})(\d)/g, "($1) $2");
        value = value.replace(/(\d)(\d{4})$/, "$1-$2");
        e.target.value = value;
    });
        
    </script>
</body>
</html>
