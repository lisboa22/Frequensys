<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Relatório de Frequência" scope="request" />

<!DOCTYPE html>
<html lang="pt-br" data-theme="${temaAtual}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle} - FrequenSys</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/frequensys.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf-autotable/3.5.29/jspdf.plugin.autotable.min.js"></script>

    <style>
        /* ── Ajustes locais desta página: reduz altura do gráfico e da
             exportação para a tabela subir e a tela não ficar com scroll ── */
        .chart-card {
            padding: 14px 20px;
        }
        .chart-card-header {
            margin-bottom: 8px;
        }
        .chart-container-wrapper.chart-canvas-wrapper {
            height: 130px;
        }
        .export-card {
            padding: 14px 20px;
        }
        .export-card h3 {
            margin: 0 0 10px 0;
        }
        .export-btn {
            padding: 8px 14px;
            margin-bottom: 6px;
        }

        /* ── Tabela de detalhamento mais compacta, com rolagem interna ──── */
        .detail-card {
            padding: 14px 20px;
        }
        .detail-card-header {
            margin-bottom: 10px;
        }
        .table-scroll-wrapper {
            max-height: 160px;
            overflow-y: auto;
        }
        .detail-card table thead tr th {
            position: sticky;
            top: 0;
            background: var(--card-bg, #1e2535);
            z-index: 1;
            padding: 6px 8px;
        }
        .detail-card table tbody tr td {
            padding: 6px 8px;
        }
        .detail-card table {
            font-size: 0.75rem;
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
        @media print {
            .pagination-bar { display: none !important; }
            #tabelaRelatorio tbody tr { display: table-row !important; }
            .table-scroll-wrapper { max-height: none !important; overflow: visible !important; }
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

            <%-- ══════════════════════════════════════════════
                 FILTROS
            ══════════════════════════════════════════════ --%>
            <div class="filter-card">
                <form action="RelatorioFrequenciaController" method="get">
                    <div class="filter-grid">

                        <div class="filter-group">
                            <label>Data Início</label>
                            <input type="date" name="dataInicio"
                                   value="${param.dataInicio}">
                        </div>

                        <div class="filter-group">
                            <label>Data Fim</label>
                            <input type="date" name="dataFim"
                                   value="${param.dataFim}">
                        </div>

                        <div class="filter-group">
                            <label>Funcionário</label>
                            <select name="idFuncionario">
                                <option value="">Todos</option>
                                <c:forEach var="f" items="${funcionarios}">
                                    <option value="${f.id}"
                                        <c:if test="${param.idFuncionario == f.id}">selected</c:if>>
                                        ${f.nome}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="filter-group">
                            <label>Turno</label>
                            <select name="idTurno">
                                <option value="">Todos</option>
                                <c:forEach var="t" items="${turnos}">
                                    <option value="${t.id}"
                                        <c:if test="${param.idTurno == t.id}">selected</c:if>>
                                        ${t.nome}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="filter-group">
                            <label>Status</label>
                            <select name="status">
                                <option value="">Todos</option>
                                <option value="PRESENTE"         <c:if test="${param.status == 'PRESENTE'}">selected</c:if>>PRESENTE</option>
                                <option value="ATRASO"           <c:if test="${param.status == 'ATRASO'}">selected</c:if>>ATRASO</option>
                                <option value="FALTA"            <c:if test="${param.status == 'FALTA'}">selected</c:if>>FALTA</option>
                                <option value="SAÍDA ANTECIPADA" <c:if test="${param.status == 'SAÍDA ANTECIPADA'}">selected</c:if>>SAÍDA ANTECIPADA</option>
                                <option value="JUSTIFICADA"      <c:if test="${param.status == 'JUSTIFICADA'}">selected</c:if>>JUSTIFICADA</option>
                                <option value="FÉRIAS"           <c:if test="${param.status == 'FÉRIAS'}">selected</c:if>>FÉRIAS</option>
                            </select>
                        </div>

                        <div class="filter-group">
                            <label>Tipo</label>
                            <select name="tipo">
                                <option value="">Todos</option>
                                <option value="ENTRADA" <c:if test="${param.tipo == 'ENTRADA'}">selected</c:if>>ENTRADA</option>
                                <option value="SAIDA"   <c:if test="${param.tipo == 'SAIDA'}">selected</c:if>>SAÍDA</option>
                            </select>
                        </div>

                        <div class="filter-group filter-group-end">
                            <label>&nbsp;</label>
                            <button type="submit" class="btn-filter">
                                <i class="fa-solid fa-filter"></i> Filtrar
                            </button>
                        </div>

                    </div>
                </form>
            </div>

            <%-- ══════════════════════════════════════════════
                 KPIs
            ══════════════════════════════════════════════ --%>
            <div class="kpi-row">

                <div class="kpi-card green">
                    <span class="kpi-label">Presenças</span>
                    <span class="kpi-value">${totalPresente != null ? totalPresente : 0}</span>
                    <span class="kpi-sub">registros PRESENTE</span>
                </div>

                <div class="kpi-card red">
                    <span class="kpi-label">Faltas</span>
                    <span class="kpi-value">${totalFalta != null ? totalFalta : 0}</span>
                    <span class="kpi-sub">registros FALTA</span>
                </div>

                <div class="kpi-card yellow">
                    <span class="kpi-label">Atrasos</span>
                    <span class="kpi-value">${totalAtraso != null ? totalAtraso : 0}</span>
                    <span class="kpi-sub">registros ATRASO</span>
                </div>

                <div class="kpi-card blue">
                    <span class="kpi-label">Total Registros</span>
                    <span class="kpi-value">${totalRegistros != null ? totalRegistros : 0}</span>
                    <span class="kpi-sub">no período filtrado</span>
                </div>

            </div>

            <%-- ══════════════════════════════════════════════
                 GRÁFICO + EXPORTAR
            ══════════════════════════════════════════════ --%>
            <div class="report-grid">

                <%-- Gráfico de registros por mês --%>
                <div class="chart-card">
                    <div class="chart-card-header">
                        <h3>Registros por Mês</h3>
                        <select class="year-select" id="anoSelect" onchange="atualizarGrafico()">
                            <c:forEach var="ano" items="${anosDisponiveis}">
                                <option value="${ano}" <c:if test="${anoSelecionado == ano}">selected</c:if>>
                                    ${ano}
                                </option>
                            </c:forEach>
                            <c:if test="${empty anosDisponiveis}">
                                <option value="2026" selected>2026</option>
                            </c:if>
                        </select>
                    </div>
                    <%-- Wrapper adicionado para blindagem de crescimento de altura do Canvas --%>
                    <div class="chart-container-wrapper chart-canvas-wrapper">
                        <canvas id="chartCanvas"></canvas>
                    </div>
                </div>

                <%-- Exportar --%>
                <div class="export-card">
                    <h3>Exportar Dados</h3>

                    <button class="export-btn" onclick="exportarPDF()">
                        <i class="fa-solid fa-file-pdf icon-pdf"></i>
                        Baixar PDF
                    </button>

                    <button class="export-btn" onclick="exportarCSV()">
                        <i class="fa-solid fa-file-excel icon-excel"></i>
                        Baixar Excel (CSV)
                    </button>

                    <button class="export-btn" onclick="window.print()">
                        <i class="fa-solid fa-print icon-print"></i>
                        Imprimir Tela
                    </button>
                </div>

            </div>

            <%-- ══════════════════════════════════════════════
                 TABELA DE DETALHAMENTO
            ══════════════════════════════════════════════ --%>
            <div class="detail-card">
                <div class="detail-card-header">
                    <h3>Detalhamento</h3>
                    <p>Listagem Geral de Registros de Frequência</p>
                </div>

                <div class="table-scroll-wrapper">
                <table id="tabelaRelatorio">
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

                                <%-- Data / Hora --%>
                                <td>${r.datahora != null ? r.datahora : '—'}</td>

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
                                            <span class="badge badge-green">ENTRADA</span>
                                        </c:when>
                                        <c:when test="${r.tipo == 'SAIDA'}">
                                            <span class="badge badge-indigo">SAÍDA</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-gray">${r.tipo}</span>
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
                                            <span class="badge badge-green">PRESENTE</span>
                                        </c:when>
                                        <c:when test="${r.status == 'FALTA'}">
                                            <span class="badge badge-red">FALTA</span>
                                        </c:when>
                                        <c:when test="${r.status == 'ATRASO'}">
                                            <span class="badge badge-yellow">ATRASO</span>
                                        </c:when>
                                        <c:when test="${r.status == 'SAÍDA ANTECIPADA'}">
                                            <span class="badge badge-orange">SAÍDA ANTECIPADA</span>
                                        </c:when>
                                        <c:when test="${r.status == 'FÉRIAS'}">
                                            <span class="badge badge-indigo">FÉRIAS</span>
                                        </c:when>
                                        <c:when test="${r.status == 'JUSTIFICADA'}">
                                            <span class="badge badge-blue">JUSTIFICADA</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-gray">${r.status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <%-- Observação --%>
                                <td class="cell-observacao"
                                    title="${r.observacao}">
                                    ${not empty r.observacao ? r.observacao : '—'}
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty registros}">
                            <tr>
                                <td colspan="10">
                                    <div class="empty-state">
                                        <i class="fa-solid fa-chart-bar"></i>
                                        <p>Nenhum registro encontrado para os filtros selecionados.</p>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
                </div>

                <div class="pagination-bar" id="paginationBar">
                    <span class="pagination-info" id="paginationInfo"></span>
                    <div class="pagination-controls" id="paginationControls"></div>
                </div>
            </div>

        </div><%-- /dashboard-container --%>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>

    <script>
        // Declaramos o objeto do gráfico globalmente para controle unificado de instâncias
        let meuGrafico = null;
        const meses = ['Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'];

        /* ── Função unificada para inicializar ou atualizar o gráfico ─────────────────────── */
        function renderizarGrafico(dadosArray) {
            const ctx = document.getElementById('chartCanvas').getContext('2d');
            
            // Destrói o gráfico existente antes de recriar, eliminando o risco de loop infinito
            if (meuGrafico) {
                meuGrafico.destroy();
            }

            meuGrafico = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: meses,
                    datasets: [{
                        label: 'Registros',
                        data: dadosArray,
                        backgroundColor: 'rgba(99, 102, 241, 0.7)',
                        borderColor: '#6366f1',
                        borderWidth: 1,
                        borderRadius: 5,
                        borderSkipped: false,
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false, // Entrega o controle de dimensões de volta ao wrapper CSS
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            backgroundColor: '#1e2535',
                            borderColor: 'rgba(255,255,255,0.1)',
                            borderWidth: 1,
                            titleColor: '#e2e8f0',
                            bodyColor: '#94a3b8',
                            callbacks: {
                                label: ctx => ` ${ctx.parsed.y} registros`
                            }
                        }
                    },
                    scales: {
                        x: {
                            grid: { color: 'rgba(255,255,255,0.04)' },
                            ticks: { color: '#94a3b8', font: { size: 11 } }
                        },
                        y: {
                            beginAtZero: true,
                            grid: { color: 'rgba(255,255,255,0.06)' },
                            ticks: {
                                color: '#94a3b8',
                                font: { size: 11 },
                                stepSize: 1,
                                precision: 0
                            }
                        }
                    }
                }
            });
        }

        /* ── Chamada disparada ao alterar o seletor de ano ─────────────────────── */
        function atualizarGrafico() {
            const anoSelecionado = document.getElementById('anoSelect').value;

            // Ajustado para bater no endpoint correto do RelatorioFrequenciaController
            fetch(`${pageContext.request.contextPath}/RelatorioFrequenciaController?action=dadosGrafico&ano=${anoSelecionado}`)
                .then(response => response.json())
                .then(dados => {
                    renderizarGrafico(dados);
                })
                .catch(err => console.error("Erro ao carregar dados do gráfico:", err));
        }

        /* ── Carga inicial (Executada estritamente uma única vez) ─────────────────────── */
        document.addEventListener("DOMContentLoaded", () => {
            // Captura os dados que o JSTL já processou do request inicial do back-end
            const dadosIniciais = [
                <c:choose>
                    <c:when test="${not empty registrosPorMes}">
                        <c:forEach var="qtd" items="${registrosPorMes}" varStatus="s">
                            ${qtd}<c:if test="${!s.last}">,</c:if>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>0,0,0,0,0,0,0,0,0,0,0,0</c:otherwise>
                </c:choose>
            ];

            // Renderiza sem acionar gatilho de requisição cíclica
            renderizarGrafico(dadosIniciais);
            inicializarPaginacao();
        });

        /* ── Paginação da tabela de detalhamento ───────────────────────────
           Apenas controla a exibição visual das linhas (paginação client-side).
           exportarCSV()/exportarPDF() continuam lendo todas as <tr> do tbody,
           então a exportação não é afetada pela página atual. ─────────────── */
        const LINHAS_POR_PAGINA = 10;
        let paginaAtual = 1;

        function inicializarPaginacao() {
            const tabela = document.getElementById('tabelaRelatorio');
            if (!tabela) return;

            const linhas = Array.prototype.filter.call(
                tabela.querySelectorAll('tbody tr'),
                tr => !tr.querySelector('.empty-state')
            );

            if (linhas.length <= LINHAS_POR_PAGINA) {
                document.getElementById('paginationBar').style.display = 'none';
                return;
            }

            renderizarPagina(linhas, 1);
        }

        function renderizarPagina(linhas, pagina) {
            const totalPaginasTabela = Math.ceil(linhas.length / LINHAS_POR_PAGINA);
            paginaAtual = Math.min(Math.max(pagina, 1), totalPaginasTabela);

            const inicio = (paginaAtual - 1) * LINHAS_POR_PAGINA;
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
            btnAnterior.disabled = (paginaAtual === 1);
            btnAnterior.onclick = () => renderizarPagina(linhas, paginaAtual - 1);
            controlesEl.appendChild(btnAnterior);

            for (let p = 1; p <= totalPaginasTabela; p++) {
                const btnPagina = document.createElement('button');
                btnPagina.type = 'button';
                btnPagina.className = 'pagination-btn' + (p === paginaAtual ? ' active' : '');
                btnPagina.textContent = p;
                btnPagina.onclick = () => renderizarPagina(linhas, p);
                controlesEl.appendChild(btnPagina);
            }

            const btnProximo = document.createElement('button');
            btnProximo.type = 'button';
            btnProximo.className = 'pagination-btn';
            btnProximo.innerHTML = '<i class="fa-solid fa-chevron-right"></i>';
            btnProximo.disabled = (paginaAtual === totalPaginasTabela);
            btnProximo.onclick = () => renderizarPagina(linhas, paginaAtual + 1);
            controlesEl.appendChild(btnProximo);
        }

        /* ── Exportar CSV ───────────────────────────────────────────────── */
        function exportarCSV() {
            const tabela = document.getElementById('tabelaRelatorio');
            if (!tabela) return;

            const linhas = [];
            const cabecalhos = [];
            tabela.querySelectorAll('thead th').forEach(th => {
                cabecalhos.push('"' + th.innerText.trim() + '"');
            });
            linhas.push(cabecalhos.join(';'));

            tabela.querySelectorAll('tbody tr').forEach(tr => {
                const cols = [];
                tr.querySelectorAll('td').forEach(td => {
                    const texto = td.innerText.trim().replace(/"/g, '""');
                    cols.push('"' + texto + '"');
                });
                if (cols.length > 1) linhas.push(cols.join(';'));
            });

            const conteudo = '\uFEFF' + linhas.join('\n'); // BOM UTF-8 para Excel
            const blob = new Blob([conteudo], { type: 'text/csv;charset=utf-8;' });
            const url  = URL.createObjectURL(blob);
            const a    = document.createElement('a');
            a.href     = url;
            a.download = 'relatorio_frequencia.csv';
            a.click();
            URL.revokeObjectURL(url);
        }

        function exportarPDF() {
            const { jsPDF } = window.jspdf;
            const doc = new jsPDF({ orientation: 'landscape' });

            const gerarPDF = function () {

                // ── Logo: quadrado roxo com calendário desenhado em canvas ──
                const size = 56;
                const canvas = document.createElement('canvas');
                canvas.width  = size;
                canvas.height = size;
                const ctx = canvas.getContext('2d');

                // Fundo roxo com bordas arredondadas (sem roundRect)
                const r = 10;
                ctx.fillStyle = '#6366f1';
                ctx.beginPath();
                ctx.moveTo(r, 0);
                ctx.lineTo(size - r, 0);
                ctx.quadraticCurveTo(size, 0, size, r);
                ctx.lineTo(size, size - r);
                ctx.quadraticCurveTo(size, size, size - r, size);
                ctx.lineTo(r, size);
                ctx.quadraticCurveTo(0, size, 0, size - r);
                ctx.lineTo(0, r);
                ctx.quadraticCurveTo(0, 0, r, 0);
                ctx.closePath();
                ctx.fill();

                // Corpo branco do calendário
                const bx = 11, by = 14, bw = 34, bh = 28, br = 3;
                ctx.fillStyle = '#ffffff';
                ctx.beginPath();
                ctx.moveTo(bx + br, by);
                ctx.lineTo(bx + bw - br, by);
                ctx.quadraticCurveTo(bx + bw, by, bx + bw, by + br);
                ctx.lineTo(bx + bw, by + bh - br);
                ctx.quadraticCurveTo(bx + bw, by + bh, bx + bw - br, by + bh);
                ctx.lineTo(bx + br, by + bh);
                ctx.quadraticCurveTo(bx, by + bh, bx, by + bh - br);
                ctx.lineTo(bx, by + br);
                ctx.quadraticCurveTo(bx, by, bx + br, by);
                ctx.closePath();
                ctx.fill();

                // Cabeçalho escuro do calendário
                ctx.fillStyle = '#4f46e5';
                ctx.beginPath();
                ctx.moveTo(bx + br, by);
                ctx.lineTo(bx + bw - br, by);
                ctx.quadraticCurveTo(bx + bw, by, bx + bw, by + br);
                ctx.lineTo(bx + bw, by + 10);
                ctx.lineTo(bx, by + 10);
                ctx.lineTo(bx, by + br);
                ctx.quadraticCurveTo(bx, by, bx + br, by);
                ctx.closePath();
                ctx.fill();

                // Argolas (2 retângulos brancos no topo)
                ctx.fillStyle = '#ffffff';
                // argola esquerda
                ctx.beginPath();
                ctx.moveTo(19, 10); ctx.lineTo(22, 10);
                ctx.quadraticCurveTo(23, 10, 23, 11);
                ctx.lineTo(23, 16);
                ctx.quadraticCurveTo(23, 17, 22, 17);
                ctx.lineTo(19, 17);
                ctx.quadraticCurveTo(18, 17, 18, 16);
                ctx.lineTo(18, 11);
                ctx.quadraticCurveTo(18, 10, 19, 10);
                ctx.closePath();
                ctx.fill();
                // argola direita
                ctx.beginPath();
                ctx.moveTo(34, 10); ctx.lineTo(37, 10);
                ctx.quadraticCurveTo(38, 10, 38, 11);
                ctx.lineTo(38, 16);
                ctx.quadraticCurveTo(38, 17, 37, 17);
                ctx.lineTo(34, 17);
                ctx.quadraticCurveTo(33, 17, 33, 16);
                ctx.lineTo(33, 11);
                ctx.quadraticCurveTo(33, 10, 34, 10);
                ctx.closePath();
                ctx.fill();

                // Pontinhos da grade (6 pontos, 2 linhas x 3 colunas)
                ctx.fillStyle = '#4f46e5';
                const pontos = [
                    [18, 31], [28, 31], [38, 31],
                    [18, 38], [28, 38], [38, 38]
                ];
                pontos.forEach(([px, py]) => {
                    ctx.beginPath();
                    ctx.arc(px, py, 2.2, 0, Math.PI * 2);
                    ctx.fill();
                });

                // Insere logo no PDF
                try {
                    doc.addImage(canvas.toDataURL('image/png'), 'PNG', 14, 7, 10, 10);
                } catch (e) {
                    console.warn('Logo não adicionado:', e);
                }

                // ── Cabeçalho de texto ────────────────────────────────────────
                doc.setFontSize(16);
                doc.setTextColor(30, 37, 53);
                doc.text('Relatório de Frequência - FrequenSys', 27, 13);

                doc.setFontSize(9);
                doc.setTextColor(148, 163, 184);
                doc.text('Gerado em: ' + new Date().toLocaleString('pt-BR'), 27, 19);
                doc.setTextColor(0);

                // ── Coleta dados da tabela ────────────────────────────────────
                const tabela = document.getElementById('tabelaRelatorio');

                const cabecalhos = [];
                tabela.querySelectorAll('thead th').forEach(th => {
                    cabecalhos.push(th.innerText.trim());
                });

                const linhas = [];
                tabela.querySelectorAll('tbody tr').forEach(tr => {
                    const cols = [];
                    tr.querySelectorAll('td').forEach(td => {
                        cols.push(td.innerText.trim());
                    });
                    if (cols.length > 1) linhas.push(cols);
                });

                // ── Tabela ────────────────────────────────────────────────────
                doc.autoTable({
                    head: [cabecalhos],
                    body: linhas,
                    startY: 24,
                    theme: 'grid',
                    headStyles: {
                        fillColor: [99, 102, 241],
                        textColor: 255,
                        fontStyle: 'bold',
                        fontSize: 7,
                        cellPadding: 4
                    },
                    bodyStyles: {
                        fontSize: 7,
                        textColor: 40,
                        cellPadding: 3
                    },
                    alternateRowStyles: {
                        fillColor: [245, 247, 250]
                    },
                    styles: {
                        overflow: 'linebreak',
                        lineColor: [220, 225, 235],
                        lineWidth: 0.2
                    },
                    columnStyles: {
                        0: { cellWidth: 10 },
                        2: { cellWidth: 38 },
                        5: { cellWidth: 18 },
                        6: { cellWidth: 22 },
                        7: { cellWidth: 28 }
                    }
                });

                // ── Rodapé com número de página ───────────────────────────────
                const totalPaginas = doc.internal.getNumberOfPages();
                for (let i = 1; i <= totalPaginas; i++) {
                    doc.setPage(i);
                    doc.setFontSize(7);
                    doc.setTextColor(180);
                    doc.text(
                        `Página ${i} de ${totalPaginas}`,
                        doc.internal.pageSize.getWidth() - 14,
                        doc.internal.pageSize.getHeight() - 8,
                        { align: 'right' }
                    );
                }

                doc.save('relatorio_frequencia.pdf');
            };

            // Garante que fontes estejam prontas antes de gerar
            if (document.fonts && document.fonts.ready) {
                document.fonts.ready.then(gerarPDF);
            } else {
                gerarPDF();
            }
        }

        /* ── User dropdown ──────────────────────────────────────────────── */
        const dropdown = document.getElementById('userDropdown');
        if (dropdown) {
            dropdown.addEventListener('click', e => {
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