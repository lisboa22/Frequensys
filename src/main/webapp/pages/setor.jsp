<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Setores" scope="request" />

<!DOCTYPE html>
<html lang="pt-br" data-theme="${temaAtual}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gerenciamento de ${pageTitle} - FrequenSys</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/frequensys.css">

    <style>
        /* ══════════════════════════════════════════════════════════
           SETORES — ajustes locais desta tela (mesmo padrão do Painel):
           usa as variáveis de tema de frequensys.css, espaçamento na
           escala 4/8/12/16/24/32/48px e responsividade da tabela.
           ══════════════════════════════════════════════════════════ */

        .page-header-title { display: flex; align-items: center; gap: 16px; }

        /* ── Alertas de sucesso / erro ── */
        .alert-box {
            position: relative;
            padding: 16px 48px 16px 16px;
            border-radius: 8px;
            margin-bottom: 24px;
            font-size: 0.9rem;
        }
        .alert-success {
            background: rgba(16,185,129,.1);
            color: #10b981;
            border: 1px solid rgba(16,185,129,.2);
        }
        .alert-error {
            background: rgba(239,68,68,.1);
            color: #ef4444;
            border: 1px solid rgba(239,68,68,.2);
        }
        .alert-close {
            position: absolute; top: 8px; right: 12px;
            background: transparent; border: none;
            font-size: 18px; line-height: 1; cursor: pointer;
            color: inherit; padding: 4px;
        }

        /* ── Ações do cabeçalho da tabela ── */
        .header-actions { display: flex; flex-direction: row; align-items: center; gap: 12px; }

        /* ── Rodapé dos formulários dos modais ── */
        .modal-form-actions {
            margin-top: 24px; display: flex; gap: 12px; justify-content: flex-end;
        }

        /* ── Tabela responsiva ── */
        .table-scroll { width: 100%; overflow-x: auto; }
        .table-scroll table { min-width: 480px; }
        .empty-row { text-align: center; color: var(--text-muted); padding: 32px !important; }

        @media (max-width: 600px) {
            .table-container { padding: 16px; }
            .table-header-row { flex-direction: column; align-items: flex-start; gap: 12px; }
            .header-actions { width: 100%; }
            .header-actions .btn-report, .header-actions .btn-primary { flex: 1; justify-content: center; }
        }
    </style>
</head>
<body>

    <jsp:include page="/includes/sidebar.jsp" />

    <main class="main-content">
        <header class="page-header">
            <div class="page-header-title">
                <h2>${pageTitle}</h2>
            </div>
            <jsp:include page="/includes/user-menu.jsp" />
        </header>

        <div class="dashboard-container">

            <%-- Mensagem de sucesso --%>
            <c:if test="${not empty sessionScope.mensagemSucesso}">
                <div id="alerta-sucesso" class="alert-box alert-success">
                    ${sessionScope.mensagemSucesso}
                    <button onclick="fecharAlerta()" class="alert-close">&times;</button>
                </div>
                <% session.removeAttribute("mensagemSucesso"); %>
            </c:if>

            <%-- Mensagem de erro --%>
            <c:if test="${not empty sessionScope.mensagemErro}">
                <div id="alerta-erro" class="alert-box alert-error">
                    ${sessionScope.mensagemErro}
                    <button onclick="document.getElementById('alerta-erro').style.display='none'" class="alert-close">&times;</button>
                </div>
                <% session.removeAttribute("mensagemErro"); %>
            </c:if>

            <div class="table-container">
                <div class="table-header-row">
                    <div class="table-title">Setores Cadastrados</div>
                    <div class="header-actions">
                    	<button class="btn-report" onclick="window.location.href='${pageContext.request.contextPath}/RelatorioSetorController'">
                            <i class="fa-solid fa-chart-bar"></i> Relatório
                        </button>
                        <button class="btn-primary" onclick="openModal()">
                            <i class="fa-solid fa-plus"></i> Novo Setor
                        </button>
                    </div>
                </div>

                <div class="table-scroll">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Nome</th>
                            <th>Descrição</th>
                            <th style="text-align: right;">Ações</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="s" items="${setores}">
                            <tr>
                                <td>${s.id}</td>
                                <td style="font-weight: 500;">${s.nome}</td>
                                <td>${s.descricao}</td>
                                <td style="text-align: right;">
                                    <button class="btn-icon"
                                            onclick="openModalEditar('${s.id}', '${s.nome}', '${s.descricao}')">
                                        <i class="fa-solid fa-pen"></i>
                                    </button>
                                    <button class="btn-icon delete" onclick="excluirSetor(${s.id})">
                                        <i class="fa-solid fa-trash"></i>
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty setores}">
                            <tr>
                                <td colspan="4" class="empty-row">
                                    Nenhum setor cadastrado.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
                </div>
            </div>
        </div>
    </main>

    <%-- ================================ --%>
    <%-- MODAL: CADASTRAR NOVO SETOR      --%>
    <%-- ================================ --%>
    <div id="modalCadastro" class="modal-overlay">
        <div class="modal-box">
            <h3>Novo Setor</h3>
            <form action="SetorController" method="post">
                <input type="hidden" name="action" value="adicionar">

                <div class="form-group">
                    <label>Nome</label>
                    <input type="text" name="nome" class="form-input" required placeholder="Nome do setor" oninput="this.value = this.value.toUpperCase()" required>
                </div>

                <div class="form-group">
                    <label>Descrição</label>
                    <textarea name="descricao" class="form-input" rows="3"
                              placeholder="Descrição do setor (opcional)"></textarea>
                </div>

                <div class="modal-form-actions">
                    <button type="button" class="btn btn-outline" onclick="closeModal()">Cancelar</button>
                    <button type="submit" class="btn btn-primary">Salvar</button>
                </div>
            </form>
        </div>
    </div>

    <%-- ================================ --%>
    <%-- MODAL: EDITAR SETOR              --%>
    <%-- ================================ --%>
    <div id="modalEditar" class="modal-overlay">
        <div class="modal-box">
            <h3>Editar Setor</h3>
            <form action="SetorController" method="post">
                <input type="hidden" name="action"  value="editar">
                <input type="hidden" name="id" id="edit_id">

                <div class="form-group">
                    <label>Nome</label>
                    <input type="text" name="nome" id="edit_nome" class="form-input" oninput="this.value = this.value.toUpperCase()" required>
                </div>

                <div class="form-group">
                    <label>Descrição</label>
                    <textarea name="descricao" id="edit_descricao" class="form-input" rows="3"></textarea>
                </div>

                <div class="modal-form-actions">
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

        function openModalEditar(id, nome, descricao) {
            document.getElementById('edit_id').value   = id;
            document.getElementById('edit_nome').value      = nome;
            document.getElementById('edit_descricao').value = descricao;
            document.getElementById('modalEditar').classList.add('show');
        }

        function closeModalEditar() {
            document.getElementById('modalEditar').classList.remove('show');
        }

        // ---- Excluir ----
        function excluirSetor(id) {
            if (confirm("Deseja excluir este setor?")) {
                const form = document.createElement("form");
                form.method = "post";
                form.action = "SetorController";

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
    </script>
</body>
</html>
