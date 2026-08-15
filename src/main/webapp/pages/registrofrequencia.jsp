<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:set var="pageTitle" value="Registros de Manual" scope="request" />

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
        /* ── Ajustes locais desta página: tabela mais compacta para caber
             mais linhas sem estourar a tela ─────────────────────────────── */
        .table-container table th,
        .table-container table td {
            padding: 8px 10px;
            font-size: 0.82rem;
        }

        /* ── Paginação ─────────────────────────────────────────────────── */
        .pagination-bar {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-top: 16px;
            padding-top: 14px;
            border-top: 1px solid var(--border-color, rgba(255,255,255,0.07));
        }
        .pagination-info {
            font-size: 0.78rem;
            color: var(--text-muted, #94a3b8);
        }
        .pagination-controls {
            display: flex;
            align-items: center;
            gap: 4px;
        }
        .pagination-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 30px;
            height: 30px;
            padding: 0 8px;
            background: var(--input-bg, #151c2c);
            border: 1px solid var(--border-color, rgba(255,255,255,0.08));
            border-radius: 6px;
            color: var(--text-primary, #e2e8f0);
            font-size: 0.8rem;
            font-family: inherit;
            cursor: pointer;
            transition: background 0.2s, border-color 0.2s;
        }
        .pagination-btn:hover:not(:disabled) {
            background: rgba(255,255,255,0.06);
            border-color: rgba(255,255,255,0.18);
        }
        .pagination-btn.active {
            background: #6366f1;
            border-color: #6366f1;
            color: #fff;
        }
        .pagination-btn:disabled {
            opacity: 0.4;
            cursor: not-allowed;
        }
    </style>
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

            <%-- Mensagem de sucesso --%>
            <c:if test="${not empty sessionScope.mensagemSucesso}">
                <div id="alerta-sucesso" class="alert alert-success">
                    ${sessionScope.mensagemSucesso}
                    <button onclick="fecharAlerta()" class="alert-close-btn">&times;</button>
                </div>
                <% session.removeAttribute("mensagemSucesso"); %>
            </c:if>

            <%-- Mensagem de erro --%>
            <c:if test="${not empty sessionScope.mensagemErro}">
                <div id="alerta-erro" class="alert alert-error">
                    ${sessionScope.mensagemErro}
                    <button onclick="document.getElementById('alerta-erro').style.display='none'" class="alert-close-btn">&times;</button>
                </div>
                <% session.removeAttribute("mensagemErro"); %>
            </c:if>

            <div class="table-container">
                <div class="table-header-row">
                    <div class="table-title">Registros Cadastrados</div>
                    <div class="header-actions">
                        <button class="btn-report" onclick="window.location.href='${pageContext.request.contextPath}/RelatorioFrequenciaController'">
                            <i class="fa-solid fa-chart-bar"></i> Relatório
                        </button>
                        <button class="btn-primary" onclick="openModal()">
                            <i class="fa-solid fa-plus"></i> Novo Registro
                        </button>
                    </div>
                </div>

                <table id="tabelaRegistros">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Funcionário</th>
                            <th>Data / Hora</th>
                            <th>Turno</th>
                            <th>Tipo</th>
                            <th>Atraso</th>
                            <th>Saída Antec.</th>
                            <th>Carga Cumprida</th>
                            <th>Status</th>
                            <th>Observação</th>
                            <th class="text-right">Ações</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="r" items="${registros}">
                            <tr>
                                <td>${r.id}</td>

                                <%-- Funcionário --%>
                                <td class="cell-strong">
                                    <c:set var="nomeFuncionario" value="${r.idFuncionario}" />
                                    <c:forEach var="f" items="${funcionarios}">
                                        <c:if test="${f.id == r.idFuncionario}">
                                            <c:set var="nomeFuncionario" value="${f.nome}" />
                                        </c:if>
                                    </c:forEach>
                                    ${nomeFuncionario}
                                </td>

                                <%-- Data e Hora unificadas (padrão brasileiro dd/MM/yyyy HH:mm) --%>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty r.datahora}">
                                            ${fn:substring(r.datahora, 8, 10)}/${fn:substring(r.datahora, 5, 7)}/${fn:substring(r.datahora, 0, 4)}
                                            ${fn:substring(r.datahora, 11, 16)}
                                        </c:when>
                                        <c:otherwise>—</c:otherwise>
                                    </c:choose>
                                </td>

                                <%-- Turno --%>
                                <td>
                                    <c:set var="nomeTurno" value="${r.idTurno}" />
                                    <c:forEach var="t" items="${turnos}">
                                        <c:if test="${t.id == r.idTurno}">
                                            <c:set var="nomeTurno" value="${t.nome}" />
                                        </c:if>
                                    </c:forEach>
                                    ${nomeTurno}
                                </td>

                                <%-- Tipo --%>
                                <td>
                                    <c:choose>
                                        <c:when test="${r.tipo == 'ENTRADA'}">
                                            <span class="status-badge status-ativo">ENTRADA</span>
                                        </c:when>
                                        <c:when test="${r.tipo == 'SAIDA'}">
                                            <span class="status-badge status-indigo">SAÍDA</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-badge status-inativo">${r.tipo}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <%-- Atraso --%>
                                <td>
                                    <c:choose>
                                        <c:when test="${r.minutosatraso > 0}">
                                            <span class="text-atraso">${r.minutosatraso} min</span>
                                        </c:when>
                                        <c:otherwise>—</c:otherwise>
                                    </c:choose>
                                </td>

                                <%-- Saída antecipada --%>
                                <td>
                                    <c:choose>
                                        <c:when test="${r.minutossaidaantecipada > 0}">
                                            <span class="text-saida-antecipada">${r.minutossaidaantecipada} min</span>
                                        </c:when>
                                        <c:otherwise>—</c:otherwise>
                                    </c:choose>
                                </td>

                                <%-- Carga horária cumprida --%>
                                <td>${not empty r.cargahorariacumprida ? r.cargahorariacumprida : '—'}</td>

                                <%-- Status --%>
                                <td>
                                    <c:choose>
                                        <c:when test="${r.status == 'PRESENTE'}">
                                            <span class="status-badge status-ativo">PRESENTE</span>
                                        </c:when>
                                        <c:when test="${r.status == 'FALTA'}">
                                            <span class="status-badge status-danger">FALTA</span>
                                        </c:when>
                                        <c:when test="${r.status == 'ATRASO'}">
                                            <span class="status-badge status-warning">ATRASO</span>
                                        </c:when>
                                        <c:when test="${r.status == 'SAÍDA ANTECIPADA'}">
                                            <span class="status-badge status-orange">SAÍDA ANTECIPADA</span>
                                        </c:when>
                                        <c:when test="${r.status == 'FÉRIAS'}">
                                            <span class="status-badge status-indigo">FÉRIAS</span>
                                        </c:when>
                                        <c:when test="${r.status == 'JUSTIFICADA'}">
                                            <span class="status-badge status-blue">JUSTIFICADA</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-badge status-inativo">${r.status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <%-- Observação --%>
                                <td class="cell-observacao" title="${r.observacao}">
                                    ${not empty r.observacao ? r.observacao : '—'}
                                </td>

                                <%-- Ações --%>
                                <td class="text-right">
                                    <button class="btn-icon"
                                            onclick="openModalEditar(
                                                '${r.id}',
                                                '${r.idFuncionario}',
                                                '${r.datahora}',
                                                '${r.idTurno}',
                                                '${r.tipo}',
                                                '${r.status}',
                                                '${r.minutosatraso}',
                                                '${r.minutossaidaantecipada}',
                                                '${r.cargahorariacumprida}',
                                                '${r.observacao}'
                                            )">
                                        <i class="fa-solid fa-pen"></i>
                                    </button>
                                    <button class="btn-icon delete" onclick="excluirRegistro(${r.id})">
                                        <i class="fa-solid fa-trash"></i>
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty registros}">
                            <tr>
                                <td colspan="11" class="empty-row-message">
                                    Nenhum registro de frequência cadastrado.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>

                <div class="pagination-bar" id="paginationBar">
                    <span class="pagination-info" id="paginationInfo"></span>
                    <div class="pagination-controls" id="paginationControls"></div>
                </div>
            </div>
        </div>
    </main>

    <%-- ═══════════════════════════════════════════════════════════════════════
         MODAL: CADASTRAR
    ═══════════════════════════════════════════════════════════════════════ --%>
    <div id="modalCadastro" class="modal-overlay">
        <div class="modal-box">
            <h3>Novo Registro de Frequência</h3>
            <form action="RegistroFrequenciaController" method="post">
                <input type="hidden" name="action" value="adicionar">

                <%-- Funcionário --%>
                <div class="form-group">
                    <label>Funcionário</label>
                    <select name="idFuncionario" class="form-input" required>
                        <option value="">Selecione...</option>
                        <c:forEach var="f" items="${funcionarios}">
                            <option value="${f.id}">${f.nome}</option>
                        </c:forEach>
                    </select>
                </div>

                <%-- Data e Hora unificadas — datetime-local envia "yyyy-MM-ddTHH:mm" --%>
                <div class="form-group">
                    <label>Data / Hora</label>
                    <input type="datetime-local" name="datahora" id="cad_datahora"
                           class="form-input" required
                           onchange="calcularOcorrencias('cad')">
                </div>

                <%-- Turno — data-* usados pelo JS para cálculo de atraso/saída antecipada --%>
                <div class="form-group">
                    <label>Turno</label>
                    <select name="idTurno" id="cad_idTurno" class="form-input" required
                            onchange="calcularOcorrencias('cad')">
                        <option value="">Selecione...</option>
                        <c:forEach var="t" items="${turnos}">
                            <option value="${t.id}"
                                    data-entrada="${t.horaEntrada}"
                                    data-saida="${t.horaSaida}"
                                    data-tol-entrada="${t.toleranciaEntrada}"
                                    data-tol-saida="${t.toleranciaSaida}">
                                ${t.nome}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <%-- Tipo --%>
                <div class="form-group">
                    <label>Tipo</label>
                    <select name="tipo" id="cad_tipo" class="form-input" required
                            onchange="calcularOcorrencias('cad')">
                        <option value="ENTRADA">ENTRADA</option>
                        <option value="SAIDA">SAÍDA</option>
                    </select>
                </div>

                <%-- Status — preenchido automaticamente pelo JS --%>
                <div class="form-group">
                    <label>Status</label>
                    <select name="status" id="cad_status" class="form-input" required>
                        <option value="PRESENTE">PRESENTE</option>
                        <option value="FALTA">FALTA</option>
                        <option value="ATRASO">ATRASO</option>
                        <option value="SAÍDA ANTECIPADA">SAÍDA ANTECIPADA</option>
                        <option value="FÉRIAS">FÉRIAS</option>
                        <option value="JUSTIFICADA">JUSTIFICADA</option>
                    </select>
                </div>

                <%-- Minutos — calculados automaticamente e desabilitados --%>
                <div class="form-row">
                    <div class="form-group">
                        <label>Atraso (min)
                            <span id="cad_atraso_hint" class="field-hint field-hint-indigo"></span>
                        </label>
                        <input type="number" name="minutosatraso" id="cad_minutosatraso"
                               class="form-input input-readonly-calc" value="0" min="0" readonly>
                    </div>
                    <div class="form-group">
                        <label>Saída Antecipada (min)
                            <span id="cad_saida_hint" class="field-hint field-hint-warning"></span>
                        </label>
                        <input type="number" name="minutossaidaantecipada" id="cad_minutossaidaantecipada"
                               class="form-input input-readonly-calc" value="0" min="0" readonly>
                    </div>
                </div>

                <%-- Carga --%>
                <div class="form-group">
                    <label>Carga Horária Cumprida
                        <span id="cad_carga_hint" class="field-hint field-hint-success"></span>
                    </label>
                    <input type="text" name="cargahorariacumprida" id="cad_cargahorariacumprida"
                           class="form-input input-readonly-calc" placeholder="Calculado automaticamente" readonly>
                </div>

                <%-- Observação --%>
                <div class="form-group">
                    <label>Observação</label>
                    <textarea name="observacao" class="form-input" rows="2" placeholder="Opcional..."></textarea>
                </div>

                <div class="modal-actions">
                    <button type="button" class="btn btn-outline" onclick="closeModal()">Cancelar</button>
                    <button type="submit" class="btn btn-primary">Salvar</button>
                </div>
            </form>
        </div>
    </div>

    <%-- ═══════════════════════════════════════════════════════════════════════
         MODAL: EDITAR
    ═══════════════════════════════════════════════════════════════════════ --%>
    <div id="modalEditar" class="modal-overlay">
        <div class="modal-box">
            <h3>Editar Registro de Frequência</h3>
            <form action="RegistroFrequenciaController" method="post">
                <input type="hidden" name="action" value="editar">
                <input type="hidden" name="id"     id="edit_id">

                <div class="form-group">
                    <label>Funcionário</label>
                    <select name="idFuncionario" id="edit_idFuncionario" class="form-input" required>
                        <option value="">Selecione...</option>
                        <c:forEach var="f" items="${funcionarios}">
                            <option value="${f.id}">${f.nome}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label>Data / Hora</label>
                    <input type="datetime-local" name="datahora" id="edit_datahora"
                           class="form-input" required
                           onchange="calcularOcorrencias('edit')">
                </div>

                <div class="form-group">
                    <label>Turno</label>
                    <select name="idTurno" id="edit_idTurno" class="form-input" required
                            onchange="calcularOcorrencias('edit')">
                        <option value="">Selecione...</option>
                        <c:forEach var="t" items="${turnos}">
                            <option value="${t.id}"
                                    data-entrada="${t.horaEntrada}"
                                    data-saida="${t.horaSaida}"
                                    data-tol-entrada="${t.toleranciaEntrada}"
                                    data-tol-saida="${t.toleranciaSaida}">
                                ${t.nome}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label>Tipo</label>
                    <select name="tipo" id="edit_tipo" class="form-input" required
                            onchange="calcularOcorrencias('edit')">
                        <option value="ENTRADA">ENTRADA</option>
                        <option value="SAIDA">SAÍDA</option>
                    </select>
                </div>

                <div class="form-group">
                    <label>Status</label>
                    <select name="status" id="edit_status" class="form-input" required>
                        <option value="PRESENTE">PRESENTE</option>
                        <option value="FALTA">FALTA</option>
                        <option value="ATRASO">ATRASO</option>
                        <option value="SAÍDA ANTECIPADA">SAÍDA ANTECIPADA</option>
                        <option value="FÉRIAS">FÉRIAS</option>
                        <option value="JUSTIFICADA">JUSTIFICADA</option>
                    </select>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label>Atraso (min)
                            <span id="edit_atraso_hint" class="field-hint field-hint-indigo"></span>
                        </label>
                        <input type="number" name="minutosatraso" id="edit_minutosatraso"
                               class="form-input input-readonly-calc" min="0" readonly>
                    </div>
                    <div class="form-group">
                        <label>Saída Antecipada (min)
                            <span id="edit_saida_hint" class="field-hint field-hint-warning"></span>
                        </label>
                        <input type="number" name="minutossaidaantecipada" id="edit_minutossaidaantecipada"
                               class="form-input input-readonly-calc" min="0" readonly>
                    </div>
                </div>

                <div class="form-group">
                    <label>Carga Horária Cumprida
                        <span id="edit_carga_hint" class="field-hint field-hint-success"></span>
                    </label>
                    <input type="text" name="cargahorariacumprida" id="edit_cargahorariacumprida"
                           class="form-input input-readonly-calc" placeholder="Calculado automaticamente" readonly>
                </div>

                <div class="form-group">
                    <label>Observação</label>
                    <textarea name="observacao" id="edit_observacao" class="form-input" rows="2"></textarea>
                </div>

                <div class="modal-actions">
                    <button type="button" class="btn btn-outline" onclick="closeModalEditar()">Cancelar</button>
                    <button type="submit" class="btn btn-primary">Atualizar</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // ── Paginação da tabela de registros ─────────────────────────────
        // Apenas controla a exibição visual das linhas (paginação client-side);
        // não interfere nos botões de editar/excluir de cada linha.
        const LINHAS_POR_PAGINA = 10;
        let paginaAtualRegistros = 1;

        function inicializarPaginacaoRegistros() {
            const tabela = document.getElementById('tabelaRegistros');
            if (!tabela) return;

            const linhas = Array.prototype.filter.call(
                tabela.querySelectorAll('tbody tr'),
                tr => !tr.querySelector('.empty-row-message')
            );

            if (linhas.length <= LINHAS_POR_PAGINA) {
                const bar = document.getElementById('paginationBar');
                if (bar) bar.style.display = 'none';
                return;
            }

            renderizarPaginaRegistros(linhas, 1);
        }

        function renderizarPaginaRegistros(linhas, pagina) {
            const totalPaginasRegistros = Math.ceil(linhas.length / LINHAS_POR_PAGINA);
            paginaAtualRegistros = Math.min(Math.max(pagina, 1), totalPaginasRegistros);

            const inicio = (paginaAtualRegistros - 1) * LINHAS_POR_PAGINA;
            const fim = inicio + LINHAS_POR_PAGINA;

            linhas.forEach((tr, i) => {
                tr.style.display = (i >= inicio && i < fim) ? '' : 'none';
            });

            const totalRegistros = linhas.length;
            const infoEl = document.getElementById('paginationInfo');
            infoEl.textContent = 'Mostrando ' + (inicio + 1) + '–' + Math.min(fim, totalRegistros) +
                ' de ' + totalRegistros + ' registros';

            const controlesEl = document.getElementById('paginationControls');
            controlesEl.innerHTML = '';

            const btnAnterior = document.createElement('button');
            btnAnterior.type = 'button';
            btnAnterior.className = 'pagination-btn';
            btnAnterior.innerHTML = '<i class="fa-solid fa-chevron-left"></i>';
            btnAnterior.disabled = (paginaAtualRegistros === 1);
            btnAnterior.onclick = () => renderizarPaginaRegistros(linhas, paginaAtualRegistros - 1);
            controlesEl.appendChild(btnAnterior);

            for (let p = 1; p <= totalPaginasRegistros; p++) {
                const btnPagina = document.createElement('button');
                btnPagina.type = 'button';
                btnPagina.className = 'pagination-btn' + (p === paginaAtualRegistros ? ' active' : '');
                btnPagina.textContent = p;
                btnPagina.onclick = () => renderizarPaginaRegistros(linhas, p);
                controlesEl.appendChild(btnPagina);
            }

            const btnProximo = document.createElement('button');
            btnProximo.type = 'button';
            btnProximo.className = 'pagination-btn';
            btnProximo.innerHTML = '<i class="fa-solid fa-chevron-right"></i>';
            btnProximo.disabled = (paginaAtualRegistros === totalPaginasRegistros);
            btnProximo.onclick = () => renderizarPaginaRegistros(linhas, paginaAtualRegistros + 1);
            controlesEl.appendChild(btnProximo);
        }

        document.addEventListener('DOMContentLoaded', inicializarPaginacaoRegistros);

        // ── Modais ─────────────────────────────────────────────────────────────

        function openModal() {
            document.getElementById('modalCadastro').classList.add('show');
        }
        function closeModal() {
            document.getElementById('modalCadastro').classList.remove('show');
            limparCalculo('cad');
        }

        function openModalEditar(id, idFuncionario, datahora, idTurno, tipo,
                                  status, minutosatraso, minutossaidaantecipada,
                                  cargahorariacumprida, observacao) {

            document.getElementById('edit_id').value                       = id;
            document.getElementById('edit_idFuncionario').value            = idFuncionario;
            document.getElementById('edit_datahora').value                 = datahora !== 'null' ? datahora.substring(0, 16) : '';
            document.getElementById('edit_idTurno').value                  = idTurno;
            document.getElementById('edit_tipo').value                     = tipo;
            document.getElementById('edit_status').value                   = status;
            document.getElementById('edit_minutosatraso').value            = minutosatraso;
            document.getElementById('edit_minutossaidaantecipada').value   = minutossaidaantecipada;
            document.getElementById('edit_cargahorariacumprida').value     = cargahorariacumprida !== 'null' ? cargahorariacumprida : '';
            document.getElementById('edit_observacao').value               = observacao !== 'null' ? observacao : '';

            // Recalcula ao abrir com os valores já preenchidos
            calcularOcorrencias('edit');

            document.getElementById('modalEditar').classList.add('show');
        }
        function closeModalEditar() {
            document.getElementById('modalEditar').classList.remove('show');
        }

        // ══════════════════════════════════════════════════════════════════════
        // CÁLCULO AUTOMÁTICO DE ATRASO / SAÍDA ANTECIPADA
        // ══════════════════════════════════════════════════════════════════════

        /**
         * Converte string "HH:mm" ou "HH:mm:ss" em total de minutos.
         */
        function horaParaMinutos(horaStr) {
            if (!horaStr) return null;
            const partes = horaStr.split(':');
            if (partes.length < 2) return null;
            return parseInt(partes[0], 10) * 60 + parseInt(partes[1], 10);
        }

        /**
         * Formata minutos totais em "HH:mm".
         */
        function minutosParaHora(minutos) {
            const h = Math.floor(Math.abs(minutos) / 60);
            const m = Math.abs(minutos) % 60;
            return String(h).padStart(2, '0') + ':' + String(m).padStart(2, '0');
        }

        /**
         * Lê os campos do modal indicado por prefixo ('cad' ou 'edit'),
         * calcula atraso ou saída antecipada com base no turno selecionado
         * e preenche os inputs automaticamente.
         *
         * Regras (com tolerância):
         * ENTRADA: atraso = max(0, minRegistro - (minEntrada + toleranciaEntrada))
         *   - Status: ATRASO se > 0, senão PRESENTE.
         *
         * SAÍDA: saída antecipada = max(0, (minSaida - toleranciaSaida) - minRegistro)
         *   - Status: SAÍDA ANTECIPADA se > 0, senão PRESENTE.
         */
        function calcularOcorrencias(prefix) {
            const datetimeVal = document.getElementById(prefix + '_datahora').value;
            const turnoSelect = document.getElementById(prefix + '_idTurno');
            const tipoSelect  = document.getElementById(prefix + '_tipo');

            const inputAtraso  = document.getElementById(prefix + '_minutosatraso');
            const inputSaida   = document.getElementById(prefix + '_minutossaidaantecipada');
            const inputCarga   = document.getElementById(prefix + '_cargahorariacumprida');
            const statusSelect = document.getElementById(prefix + '_status');
            const atrasoHint   = document.getElementById(prefix + '_atraso_hint');
            const saidaHint    = document.getElementById(prefix + '_saida_hint');
            const cargaHint    = document.getElementById(prefix + '_carga_hint');

            if (atrasoHint) atrasoHint.textContent = '';
            if (saidaHint)  saidaHint.textContent  = '';
            if (cargaHint)  cargaHint.textContent  = '';

            if (!datetimeVal || !turnoSelect.value || !tipoSelect.value) return;

            const optTurno      = turnoSelect.options[turnoSelect.selectedIndex];
            const horaEntrada   = optTurno.getAttribute('data-entrada');
            const horaSaida     = optTurno.getAttribute('data-saida');
            const tolEntrada    = parseInt(optTurno.getAttribute('data-tol-entrada') || '0', 10);
            const tolSaida      = parseInt(optTurno.getAttribute('data-tol-saida')   || '0', 10);

            if (!horaEntrada || !horaSaida) return;

            const horaRegistro = datetimeVal.substring(11, 16);
            const minRegistro  = horaParaMinutos(horaRegistro);
            const minEntrada   = horaParaMinutos(horaEntrada);
            const minSaida     = horaParaMinutos(horaSaida);

            if (minRegistro === null || minEntrada === null || minSaida === null) return;

            const cargaTurno = minSaida - minEntrada; // carga máxima do turno
            const tipo = tipoSelect.value;

            if (tipo === 'ENTRADA') {
                inputSaida.value = 0;

                // Atraso real = tempo após (horaEntrada + tolerância)
                const limiteEntrada = minEntrada + tolEntrada;
                const atraso = Math.max(0, minRegistro - limiteEntrada);
                inputAtraso.value = atraso;

                if (atraso > 0) {
                    if (atrasoHint) atrasoHint.textContent = '— ' + minutosParaHora(atraso) + 'h';
                    statusSelect.value = 'ATRASO';
                } else {
                    statusSelect.value = 'PRESENTE';
                }

                // Carga cumprida = carga do turno descontando o atraso
                const cargaMinutos = Math.max(0, cargaTurno - atraso);
                if (inputCarga) {
                    inputCarga.value = minutosParaHora(cargaMinutos);
                    if (cargaHint) cargaHint.textContent = '— ' + minutosParaHora(cargaMinutos) + 'h';
                }

            } else if (tipo === 'SAIDA') {
                inputAtraso.value = 0;

                // Saída antecipada = tempo antes de (horaSaida - tolerância)
                const limiteSaida = minSaida - tolSaida;
                const saidaAntecipada = Math.max(0, limiteSaida - minRegistro);
                inputSaida.value = saidaAntecipada;

                if (saidaAntecipada > 0) {
                    if (saidaHint) saidaHint.textContent = '— ' + minutosParaHora(saidaAntecipada) + 'h';
                    statusSelect.value = 'SAÍDA ANTECIPADA';
                } else {
                    statusSelect.value = 'PRESENTE';
                }

                // Carga cumprida = tempo efetivo de minEntrada até minRegistro, limitado ao turno
                const cargaMinutos = Math.min(cargaTurno, Math.max(0, minRegistro - minEntrada));
                if (inputCarga) {
                    inputCarga.value = minutosParaHora(cargaMinutos);
                    if (cargaHint) cargaHint.textContent = '— ' + minutosParaHora(cargaMinutos) + 'h';
                }
            }
        }

        /**
         * Limpa os campos calculados ao fechar o modal de cadastro.
         */
        function limparCalculo(prefix) {
            const inputAtraso = document.getElementById(prefix + '_minutosatraso');
            const inputSaida  = document.getElementById(prefix + '_minutossaidaantecipada');
            const inputCarga  = document.getElementById(prefix + '_cargahorariacumprida');
            if (inputAtraso) inputAtraso.value = 0;
            if (inputSaida)  inputSaida.value  = 0;
            if (inputCarga)  inputCarga.value  = '';
            const atrasoHint = document.getElementById(prefix + '_atraso_hint');
            const saidaHint  = document.getElementById(prefix + '_saida_hint');
            const cargaHint  = document.getElementById(prefix + '_carga_hint');
            if (atrasoHint) atrasoHint.textContent = '';
            if (saidaHint)  saidaHint.textContent  = '';
            if (cargaHint)  cargaHint.textContent  = '';
        }

        // ── Excluir ────────────────────────────────────────────────────────────

        function excluirRegistro(id) {
            if (confirm("Deseja excluir este registro de frequência?")) {
                const form    = document.createElement("form");
                form.method   = "post";
                form.action   = "RegistroFrequenciaController";

                const action  = document.createElement("input");
                action.type   = "hidden"; action.name = "action"; action.value = "deletar";

                const idInput = document.createElement("input");
                idInput.type  = "hidden"; idInput.name = "id"; idInput.value = id;

                form.appendChild(action);
                form.appendChild(idInput);
                document.body.appendChild(form);
                form.submit();
            }
        }

        // ── Alertas ────────────────────────────────────────────────────────────

        function fecharAlerta() {
            const alerta = document.getElementById('alerta-sucesso');
            if (alerta) alerta.style.display = 'none';
        }

        setTimeout(() => {
            const alerta = document.getElementById('alerta-sucesso');
            if (alerta) {
                alerta.style.transition = "opacity 0.5s ease";
                alerta.style.opacity    = "0";
                setTimeout(() => alerta.style.display = 'none', 500);
            }
        }, 4000);

        // ── User dropdown ──────────────────────────────────────────────────────

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