<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Turnos" scope="request" />

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
                    <button onclick="fecharAlerta()" style="position: absolute; top: 5px; right: 10px; background: transparent; border: none; font-size: 18px; cursor: pointer;">&times;</button>
                </div>
                <% session.removeAttribute("mensagemSucesso"); %>
            </c:if>

            <%-- Mensagem de erro --%>
            <c:if test="${not empty sessionScope.mensagemErro}">
                <div id="alerta-erro" style="position: relative; background: rgba(239, 68, 68, 0.1); color: #ef4444; padding: 15px; border-radius: 8px; margin-bottom: 20px; border: 1px solid rgba(239, 68, 68, 0.2);">
                    ${sessionScope.mensagemErro}
                    <button onclick="document.getElementById('alerta-erro').style.display='none'" style="position: absolute; top: 5px; right: 10px; background: transparent; border: none; font-size: 18px; cursor: pointer;">&times;</button>
                </div>
                <% session.removeAttribute("mensagemErro"); %>
            </c:if>

            <div class="table-container">
                <div class="table-header-row">
                    <div class="table-title">Turnos Cadastrados</div>
                    <div class="header-actions" style="display: flex; flex-direction: row; align-items: center; gap: 10px;">
                    	<button class="btn-report" onclick="window.location.href='${pageContext.request.contextPath}/RelatorioTurnoController'">
                            <i class="fa-solid fa-chart-bar"></i> Relatório
                        </button>
                        <button class="btn-primary" onclick="openModal()">
                            <i class="fa-solid fa-plus"></i> Novo Turno
                        </button>
                    </div>
                </div>

                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Nome do Turno</th>
                            <th>Entrada</th>
                            <th>Saída</th>
                            <th>Tol. Atraso</th>
                            <th>Tol. Saída</th>
                            <th>Carga Diária</th>
                            <th>Status</th>
                            <th style="text-align: right;">Ações</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="t" items="${turnos}">
                            <tr>
                                <td>${t.id}</td>
                                <td style="font-weight: 500;">${t.nome}</td>
                                <td>${t.horaEntrada}</td>
                                <td>${t.horaSaida}</td>
                                <td>${t.toleranciaEntrada} min</td>
                                <td>${t.toleranciaSaida} min</td>
                                <td>
                                    <fmt:formatNumber value="${t.cargaHorariaDiaria / 60}" maxFractionDigits="1" />h 
                                    (${t.cargaHorariaDiaria} min)
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${t.status == 'ATIVO'}">
                                            <span style="color: #10b981; background: rgba(16, 185, 129, 0.1); padding: 4px 8px; border-radius: 4px; font-size: 0.8rem;">ATIVO</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color: #94a3b8; background: rgba(148, 163, 184, 0.1); padding: 4px 8px; border-radius: 4px; font-size: 0.8rem;">INATIVO</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="text-align: right;">
                                    <button class="btn-icon"
                                            onclick="openModalEditar(
                                                '${t.id}',
                                                '${t.nome}',
                                                '${t.horaEntrada}',
                                                '${t.horaSaida}',
                                                '${t.toleranciaEntrada}',
                                                '${t.toleranciaSaida}',
                                                '${t.cargaHorariaDiaria}',
                                                '${t.status}'
                                            )">
                                        <i class="fa-solid fa-pen"></i>
                                    </button>
                                    <button class="btn-icon delete" onclick="excluirTurno(${t.id})">
                                        <i class="fa-solid fa-trash"></i>
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty turnos}">
                            <tr>
                                <td colspan="9" style="text-align: center; color: #94a3b8; padding: 30px;">
                                    Nenhum turno cadastrado.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <%-- MODAL: CADASTRAR --%>
    <div id="modalCadastro" class="modal-overlay">
        <div class="modal-box">
            <h3>Novo Turno</h3>
            <form action="TurnoController" method="post">
                <input type="hidden" name="action" value="adicionar">

                <div class="form-group">
                    <label>Nome do Turno</label>
                    <input type="text" name="nome" class="form-input" oninput="this.value = this.value.toUpperCase()" required placeholder="Ex: Comercial 44h">
                </div>
                <div style="display: flex; gap: 10px;">
                    <div class="form-group" style="flex: 1;">
                        <label>Hora Entrada</label>
                        <input type="time" name="horaEntrada" class="form-input" required>
                    </div>
                    <div class="form-group" style="flex: 1;">
                        <label>Hora Saída</label>
                        <input type="time" name="horaSaida" class="form-input" required>
                    </div>
                </div>
                <div style="display: flex; gap: 10px;">
                    <div class="form-group" style="flex: 1;">
                        <label>Tol. Atraso (min)</label>
                        <input type="number" name="toleranciaEntrada" class="form-input" value="0">
                    </div>
                    <div class="form-group" style="flex: 1;">
                        <label>Tol. Saída (min)</label>
                        <input type="number" name="toleranciaSaida" class="form-input" value="0">
                    </div>
                </div>
                <div class="form-group">
                    <label>Carga Horária Diária (minutos)</label>
                    <input type="number" name="cargaHorariaDiaria" class="form-input" required placeholder="Ex: 480 para 8 horas">
                </div>
                <div class="form-group">
                    <label>Status</label>
                    <select name="status" class="form-input">
                        <option value="ATIVO">ATIVO</option>
                        <option value="INATIVO">INATIVO</option>
                    </select>
                </div>

                <div style="margin-top: 20px; display: flex; gap: 10px; justify-content: flex-end;">
                    <button type="button" class="btn btn-outline" onclick="closeModal()">Cancelar</button>
                    <button type="submit" class="btn btn-primary">Salvar</button>
                </div>
            </form>
        </div>
    </div>

    <%-- MODAL: EDITAR --%>
    <div id="modalEditar" class="modal-overlay">
        <div class="modal-box">
            <h3>Editar Turno</h3>
            <form action="TurnoController" method="post">
                <input type="hidden" name="action"  value="editar">
                <input type="hidden" name="id" id="edit_id">

                <div class="form-group">
                    <label>Nome do Turno</label>
                    <input type="text" name="nome" id="edit_nome" class="form-input" oninput="this.value = this.value.toUpperCase()" required>
                </div>
                <div style="display: flex; gap: 10px;">
                    <div class="form-group" style="flex: 1;">
                        <label>Hora Entrada</label>
                        <input type="time" name="horaEntrada" id="edit_horaEntrada" class="form-input" required>
                    </div>
                    <div class="form-group" style="flex: 1;">
                        <label>Hora Saída</label>
                        <input type="time" name="horaSaida" id="edit_horaSaida" class="form-input" required>
                    </div>
                </div>
                <div style="display: flex; gap: 10px;">
                    <div class="form-group" style="flex: 1;">
                        <label>Tol. Atraso (min)</label>
                        <input type="number" name="toleranciaEntrada" id="edit_toleranciaEntrada" class="form-input">
                    </div>
                    <div class="form-group" style="flex: 1;">
                        <label>Tol. Saída (min)</label>
                        <input type="number" name="toleranciaSaida" id="edit_toleranciaSaida" class="form-input">
                    </div>
                </div>
                <div class="form-group">
                    <label>Carga Horária Diária (minutos)</label>
                    <input type="number" name="cargaHorariaDiaria" id="edit_cargaHorariaDiaria" class="form-input" required>
                </div>
                <div class="form-group">
                    <label>Status</label>
                    <select name="status" id="edit_status" class="form-input">
                        <option value="ATIVO">ATIVO</option>
                        <option value="INATIVO">INATIVO</option>
                    </select>
                </div>

                <div style="margin-top: 20px; display: flex; gap: 10px; justify-content: flex-end;">
                    <button type="button" class="btn btn-outline" onclick="closeModalEditar()">Cancelar</button>
                    <button type="submit" class="btn btn-primary">Atualizar</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function openModal() {
            document.getElementById('modalCadastro').classList.add('show');
        }

        function closeModal() {
            document.getElementById('modalCadastro').classList.remove('show');
        }

        function openModalEditar(id, nome, entrada, saida, tolAtraso, tolSaida, carga, status) {
            document.getElementById('edit_id').value = id;
            document.getElementById('edit_nome').value = nome;
            document.getElementById('edit_horaEntrada').value = entrada;
            document.getElementById('edit_horaSaida').value = saida;
            document.getElementById('edit_toleranciaEntrada').value = tolAtraso;
            document.getElementById('edit_toleranciaSaida').value = tolSaida;
            document.getElementById('edit_cargaHorariaDiaria').value = carga;
            document.getElementById('edit_status').value = status;

            document.getElementById('modalEditar').classList.add('show');
        }

        function closeModalEditar() {
            document.getElementById('modalEditar').classList.remove('show');
        }

        function excluirTurno(id) {
            if (confirm("Deseja excluir este turno?")) {
                const form = document.createElement("form");
                form.method = "post";
                form.action = "TurnoController";

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

        function fecharAlerta() {
            const alerta = document.getElementById('alerta-sucesso');
            if (alerta) alerta.style.display = 'none';
        }

        setTimeout(() => {
            const alerta = document.getElementById('alerta-sucesso');
            if (alerta) {
                alerta.style.transition = "opacity 0.5s ease";
                alerta.style.opacity = "0";
                setTimeout(() => alerta.style.display = 'none', 500);
            }
        }, 4000);

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
    </script>
</body>
</html>