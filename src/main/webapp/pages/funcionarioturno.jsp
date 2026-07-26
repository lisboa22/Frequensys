<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Funcionário Turno" scope="request" />

<!DOCTYPE html>
<html lang="pt-br" data-theme="${temaAtual}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle} - FrequenSys</title>

    <link rel="stylesheet"
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
          rel="stylesheet">

    <link rel="stylesheet"
          href="${pageContext.request.contextPath}/css/frequensys.css">
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

        <!-- Mensagem sucesso -->
        <c:if test="${not empty sessionScope.mensagemSucesso}">
            <div id="alerta-sucesso" class="alert alert-success">

                ${sessionScope.mensagemSucesso}

                <button onclick="fecharAlerta()" class="alert-close-btn">
                    &times;
                </button>
            </div>

            <% session.removeAttribute("mensagemSucesso"); %>
        </c:if>

        <!-- Mensagem erro -->
        <c:if test="${not empty sessionScope.mensagemErro}">
            <div id="alerta-erro" class="alert alert-error">

                ${sessionScope.mensagemErro}

                <button onclick="document.getElementById('alerta-erro').style.display='none'" class="alert-close-btn">
                    &times;
                </button>
            </div>

            <% session.removeAttribute("mensagemErro"); %>
        </c:if>

        <div class="table-container">

            <div class="table-header-row">
                <div class="table-title">
                    Vínculos cadastrados
                </div>

                <div class="header-actions">
                   	<button class="btn-report" onclick="window.location.href='${pageContext.request.contextPath}/RelatorioFuncionarioTurnoController'">
                           <i class="fa-solid fa-chart-bar"></i> Relatório
                       </button>
                    <button class="btn-primary" onclick="openModal()">
                        <i class="fa-solid fa-plus"></i>
                        Novo vínculo
                    </button>
                </div>
            </div>

            <table>
                <thead>
                <tr>
                    <th>ID</th>
                    <th>Funcionário</th>
                    <th>Matrícula</th>
                    <th>Turno</th>
                    <th>Hora Entrada</th>
                    <th>Hora Saída</th>
                    <th>Data Início</th>
                    <th>Data Fim</th>
                    <th class="text-right">Ações</th>
                </tr>
                </thead>

                <tbody>

                <c:forEach var="ft" items="${funcionarioTurnos}">

                    <tr>

                        <td>${ft.id}</td>

                        <td>${ft.funcionario.nome}</td>

                        <td>${ft.funcionario.matricula}</td>

                        <td>${ft.turno.nome}</td>

                        <td>${ft.turno.horaEntrada}</td>

                        <td>${ft.turno.horaSaida}</td>

                        <td>
                            <c:choose>
                                <c:when test="${not empty ft.dataInicio}">
                                    <fmt:parseDate value="${ft.dataInicio}"
                                                   pattern="yyyy-MM-dd"
                                                   var="dtIni"
                                                   type="date"/>

                                    <fmt:formatDate value="${dtIni}"
                                                    pattern="dd/MM/yyyy"/>
                                </c:when>

                                <c:otherwise>
                                    —
                                </c:otherwise>
                            </c:choose>
                        </td>

                        <td>
                            <c:choose>
                                <c:when test="${not empty ft.dataFim}">
                                    <fmt:parseDate value="${ft.dataFim}"
                                                   pattern="yyyy-MM-dd"
                                                   var="dtFim"
                                                   type="date"/>

                                    <fmt:formatDate value="${dtFim}"
                                                    pattern="dd/MM/yyyy"/>
                                </c:when>

                                <c:otherwise>
                                    —
                                </c:otherwise>
                            </c:choose>
                        </td>

                        <td class="text-right nowrap">

                            <!-- EDITAR -->
                            <button class="btn-icon"
                                    title="Editar"

                                    onclick="openModalEditar(
                                        '${ft.id}',
                                        '${ft.funcionario.id}',
                                        '${ft.turno.id}',
                                        '${ft.dataInicio}',
                                        '${ft.dataFim}'
                                    )">

                                <i class="fa-solid fa-pen"></i>
                            </button>

                            <!-- EXCLUIR -->
                            <button class="btn-icon delete"
                                    title="Excluir"
                                    onclick="excluirFuncionarioTurno(${ft.id})">

                                <i class="fa-solid fa-trash"></i>
                            </button>

                        </td>

                    </tr>

                </c:forEach>

                <c:if test="${empty funcionarioTurnos}">
                    <tr>
                        <td colspan="9" class="empty-row-message">

                            Nenhum vínculo encontrado.

                        </td>
                    </tr>
                </c:if>

                </tbody>
            </table>
        </div>
    </div>
</main>

<!-- MODAL CADASTRO -->
<div id="modalCadastro" class="modal-overlay">

    <div class="modal-box">

        <h3>Novo vínculo</h3>

        <form action="FuncionarioTurnoController" method="post">

            <input type="hidden" name="action" value="adicionar">

            <div class="form-group">
                <label>Funcionário</label>

                <select name="idFuncionario"
                        class="form-input"
                        required>

                    <option value="">Selecione...</option>

                    <c:forEach var="f" items="${funcionarios}">
                        <option value="${f.id}">
                            ${f.nome} — ${f.matricula}
                        </option>
                    </c:forEach>

                </select>
            </div>

            <div class="form-group">
                <label>Turno</label>

                <select name="idTurno"
                        class="form-input"
                        required>

                    <option value="">Selecione...</option>

                    <c:forEach var="t" items="${turnos}">
                        <option value="${t.id}">
                            ${t.nome}
                        </option>
                    </c:forEach>

                </select>
            </div>

            <div class="form-pair">

                <div class="form-group">
                    <label>Data Início</label>

                    <input type="date"
                           name="dataInicio"
                           class="form-input"
                           required>
                </div>

                <div class="form-group">
                    <label>Data Fim</label>

                    <input type="date"
                           name="dataFim"
                           class="form-input">
                </div>

            </div>

            <div class="modal-actions">

                <button type="button"
                        class="btn btn-outline"
                        onclick="closeModal()">

                    Cancelar
                </button>

                <button type="submit"
                        class="btn btn-primary">

                    Salvar
                </button>

            </div>

        </form>

    </div>

</div>

<!-- MODAL EDITAR -->
<div id="modalEditar" class="modal-overlay">

    <div class="modal-box">

        <h3>Editar vínculo</h3>

        <form action="FuncionarioTurnoController" method="post">

            <input type="hidden" name="action" value="editar">

            <input type="hidden"
                   name="idFuncionarioTurno"
                   id="edit_idFuncionarioTurno">

            <div class="form-group">
                <label>Funcionário</label>

                <select name="idFuncionario"
                        id="edit_idFuncionario"
                        class="form-input"
                        required>

                    <option value="">Selecione...</option>

                    <c:forEach var="f" items="${funcionarios}">
                        <option value="${f.id}">
                            ${f.nome} — ${f.matricula}
                        </option>
                    </c:forEach>

                </select>
            </div>

            <div class="form-group">
                <label>Turno</label>

                <select name="idTurno"
                        id="edit_idTurno"
                        class="form-input"
                        required>

                    <option value="">Selecione...</option>

                    <c:forEach var="t" items="${turnos}">
                        <option value="${t.id}">
                            ${t.nome}
                        </option>
                    </c:forEach>

                </select>
            </div>

            <div class="form-pair">

                <div class="form-group">
                    <label>Data Início</label>

                    <input type="date"
                           name="dataInicio"
                           id="edit_dataInicio"
                           class="form-input"
                           required>
                </div>

                <div class="form-group">
                    <label>Data Fim</label>

                    <input type="date"
                           name="dataFim"
                           id="edit_dataFim"
                           class="form-input">
                </div>

            </div>

            <div class="modal-actions">

                <button type="button"
                        class="btn btn-outline"
                        onclick="closeModalEditar()">

                    Cancelar
                </button>

                <button type="submit"
                        class="btn btn-primary">

                    Atualizar
                </button>

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

    function openModalEditar(
        id,
        idFuncionario,
        idTurno,
        dataInicio,
        dataFim
    ) {

        document.getElementById('edit_idFuncionarioTurno').value = id;
        document.getElementById('edit_idFuncionario').value = idFuncionario;
        document.getElementById('edit_idTurno').value = idTurno;
        document.getElementById('edit_dataInicio').value = dataInicio;
        document.getElementById('edit_dataFim').value = dataFim;

        document.getElementById('modalEditar').classList.add('show');
    }

    function closeModalEditar() {
        document.getElementById('modalEditar').classList.remove('show');
    }

    function excluirFuncionarioTurno(id) {

        if (confirm("Deseja excluir este vínculo?")) {

            const form = document.createElement("form");

            form.method = "post";
            form.action = "FuncionarioTurnoController";

            const action = document.createElement("input");
            action.type = "hidden";
            action.name = "action";
            action.value = "deletar";

            const inputId = document.createElement("input");
            inputId.type = "hidden";
            inputId.name = "idFuncionarioTurno";
            inputId.value = id;

            form.appendChild(action);
            form.appendChild(inputId);

            document.body.appendChild(form);

            form.submit();
        }
    }

    function fecharAlerta() {
        const el = document.getElementById('alerta-sucesso');

        if (el) {
            el.style.display = 'none';
        }
    }

</script>

</body>
</html>