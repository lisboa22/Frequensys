<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Relatório de Funcionários" scope="request" />

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
        /* ── Filtros ───────────────────────────────────────────────────── */
        .filter-card {
            background: var(--card-bg, #1e2535);
            border: 1px solid var(--border-color, rgba(255,255,255,0.07));
            border-radius: 12px;
            padding: 20px 24px;
            margin-bottom: 24px;
        }
        .filter-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 14px;
            align-items: flex-end;
        }
        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .filter-group label {
            font-size: 0.72rem;
            font-weight: 600;
            letter-spacing: 0.07em;
            text-transform: uppercase;
            color: var(--text-muted, #94a3b8);
        }
        .filter-group input,
        .filter-group select {
            background: var(--input-bg, #151c2c);
            border: 1px solid var(--border-color, rgba(255,255,255,0.1));
            border-radius: 8px;
            color: #8c8c8c;
            padding: 9px 12px;
            font-size: 0.875rem;
            font-family: inherit;
            outline: none;
            transition: border-color 0.2s;
        }
        .filter-group input:focus,
        .filter-group select:focus {
            border-color: #6366f1;
        }
        .filter-group input[type="date"]::-webkit-calendar-picker-indicator {
            filter: invert(0.6);
            cursor: pointer;
        }
        .btn-filter {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 9px 20px;
            background: #6366f1;
            color: #fff;
            border: none;
            border-radius: 8px;
            font-size: 0.875rem;
            font-weight: 600;
            font-family: inherit;
            cursor: pointer;
            transition: background 0.2s, transform 0.1s;
            height: 38px;
            white-space: nowrap;
        }
        .btn-filter:hover { background: #4f46e5; }
        .btn-filter:active { transform: scale(0.97); }

        /* ── Grid principal ────────────────────────────────────────────── */
        .report-grid {
            display: grid;
            grid-template-columns: 1fr 300px;
            gap: 20px;
            margin-bottom: 24px;
        }
        @media (max-width: 900px) {
            .report-grid { grid-template-columns: 1fr; }
        }

        /* ── Cards de KPI ──────────────────────────────────────────────── */
        .kpi-row {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 14px;
            margin-bottom: 20px;
        }
        @media (max-width: 900px) {
            .kpi-row { grid-template-columns: repeat(2, 1fr); }
        }
        .kpi-card {
            background: var(--card-bg, #1e2535);
            border: 1px solid var(--border-color, rgba(255,255,255,0.07));
            border-radius: 12px;
            padding: 18px 20px;
            display: flex;
            flex-direction: column;
            gap: 6px;
        }
        .kpi-card .kpi-label {
            font-size: 0.7rem;
            font-weight: 600;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            color: var(--text-muted, #94a3b8);
        }
        .kpi-card .kpi-value {
            font-size: 1.6rem;
            font-weight: 700;
            color: var(--text-primary, #e2e8f0);
            line-height: 1;
        }
        .kpi-card .kpi-sub {
            font-size: 0.75rem;
            color: var(--text-muted, #94a3b8);
        }
        .kpi-card.green  { border-left: 3px solid #10b981; }
        .kpi-card.red    { border-left: 3px solid #ef4444; }
        .kpi-card.yellow { border-left: 3px solid #f59e0b; }
        .kpi-card.blue   { border-left: 3px solid #6366f1; }
        .kpi-card.green  .kpi-value { color: #10b981; }
        .kpi-card.red    .kpi-value { color: #ef4444; }
        .kpi-card.yellow .kpi-value { color: #f59e0b; }
        .kpi-card.blue   .kpi-value { color: #6366f1; }

        /* ── Chart card ────────────────────────────────────────────────── */
        .chart-card {
            background: var(--card-bg, #1e2535);
            border: 1px solid var(--border-color, rgba(255,255,255,0.07));
            border-radius: 12px;
            padding: 14px 20px;
        }
        .chart-card-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 8px;
        }
        .chart-card-header h3 {
            font-size: 0.95rem;
            font-weight: 600;
           
            margin: 0;
        }
        .year-select {
            background: var(--input-bg, #151c2c);
            border: 1px solid var(--border-color, rgba(255,255,255,0.1));
            border-radius: 6px;
            
            padding: 5px 10px;
            font-size: 0.8rem;
            font-family: inherit;
            cursor: pointer;
        }

        /* ── Exportar card ─────────────────────────────────────────────── */
        .export-card {
            background: var(--card-bg, #1e2535);
            border: 1px solid var(--border-color, rgba(255,255,255,0.07));
            border-radius: 12px;
            padding: 14px 20px;
        }
        .export-card h3 {
            font-size: 0.95rem;
            font-weight: 600;
            color: var(--text-primary, #e2e8f0);
            margin: 0 0 10px 0;
        }
        .export-btn {
            display: flex;
            align-items: center;
            gap: 12px;
            width: 100%;
            padding: 8px 14px;
            background: var(--input-bg, #151c2c);
            border: 1px solid var(--border-color, rgba(255,255,255,0.08));
            border-radius: 8px;
            
            font-size: 0.875rem;
            font-family: inherit;
            cursor: pointer;
            transition: background 0.2s, border-color 0.2s;
            margin-bottom: 6px;
            text-align: left;
        }
        .export-btn:last-child { margin-bottom: 0; }
        .export-btn:hover {
            background: rgba(255,255,255,0.06);
            border-color: rgba(255,255,255,0.18);
        }
        .export-btn .icon-pdf   { color: #ef4444; font-size: 1rem; }
        .export-btn .icon-excel { color: #10b981; font-size: 1rem; }
        .export-btn .icon-print { color: #94a3b8; font-size: 1rem; }

        /* ── Tabela de detalhamento ─────────────────────────────────────── */
        .detail-card {
            background: var(--card-bg, #1e2535);
            border: 1px solid var(--border-color, rgba(255,255,255,0.07));
            border-radius: 12px;
            padding: 20px 24px;
        }
        .detail-card-header {
            margin-bottom: 16px;
        }
        .detail-card-header h3 {
            font-size: 0.95rem;
            font-weight: 600;
            color: var(--text-primary, #e2e8f0);
            margin: 0 0 2px 0;
        }
        .detail-card-header p {
            font-size: 0.78rem;
            color: var(--text-muted, #94a3b8);
            margin: 0;
        }

        .detail-card table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.875rem;
        }
        .detail-card table thead tr th {
            font-size: 0.7rem;
            font-weight: 600;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            color: var(--text-muted, #94a3b8);
            padding: 10px 12px;
            border-bottom: 1px solid var(--border-color, rgba(255,255,255,0.07));
            white-space: nowrap;
        }
        .detail-card table tbody tr td {
            padding: 12px 12px;
            border-bottom: 1px solid var(--border-color, rgba(255,255,255,0.05));
            
            vertical-align: middle;
        }
        .detail-card table tbody tr:last-child td {
            border-bottom: none;
        }
        .detail-card table tbody tr:hover td {
            background: rgba(255,255,255,0.03);
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

        .badge {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 0.75rem;
            font-weight: 600;
        }
        .badge-green   { color:#10b981; background:rgba(16,185,129,0.12); }
        .badge-red     { color:#ef4444; background:rgba(239,68,68,0.12); }
        .badge-gray    { color:#94a3b8; background:rgba(148,163,184,0.12); }

        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: var(--text-muted, #94a3b8);
        }
        .empty-state i {
            font-size: 2.5rem;
            margin-bottom: 12px;
            opacity: 0.4;
        }
        .empty-state p {
            font-size: 0.875rem;
            margin: 0;
        }
    </style>
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

            <%-- ══════════════════════════════════════════════
                 FILTROS
            ══════════════════════════════════════════════ --%>
            <div class="filter-card">
                <form action="RelatorioFuncionarioController" method="get">
                    <div class="filter-grid">

                        <div class="filter-group">
                            <label>Nome</label>
                            <input type="text" name="nome" placeholder="Buscar por nome..."
                                   value="${param.nome}">
                        </div>

                        <div class="filter-group">
                            <label>Setor</label>
                            <select name="idSetor">
                                <option value="">Todos</option>
                                <c:forEach var="s" items="${setores}">
                                    <option value="${s.id}"
                                        <c:if test="${param.idSetor == s.id}">selected</c:if>>
                                        ${s.nome}
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="filter-group">
                            <label>Status</label>
                            <select name="status">
                                <option value="">Todos</option>
                                <option value="ATIVO"   <c:if test="${param.status == 'ATIVO'}">selected</c:if>>ATIVO</option>
                                <option value="INATIVO" <c:if test="${param.status == 'INATIVO'}">selected</c:if>>INATIVO</option>
                            </select>
                        </div>

                        <div class="filter-group">
                            <label>Admissão - Início</label>
                            <input type="date" name="dataInicio"
                                   value="${param.dataInicio}">
                        </div>

                        <div class="filter-group">
                            <label>Admissão - Fim</label>
                            <input type="date" name="dataFim"
                                   value="${param.dataFim}">
                        </div>

                        <div class="filter-group" style="justify-content: flex-end;">
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

                <div class="kpi-card blue">
                    <span class="kpi-label">Total de Funcionários</span>
                    <span class="kpi-value">${totalFuncionarios != null ? totalFuncionarios : 0}</span>
                    <span class="kpi-sub">no filtro atual</span>
                </div>

                <div class="kpi-card green">
                    <span class="kpi-label">Ativos</span>
                    <span class="kpi-value">${totalAtivos != null ? totalAtivos : 0}</span>
                    <span class="kpi-sub">status ATIVO</span>
                </div>

                <div class="kpi-card red">
                    <span class="kpi-label">Inativos</span>
                    <span class="kpi-value">${totalInativos != null ? totalInativos : 0}</span>
                    <span class="kpi-sub">status INATIVO</span>
                </div>

                <div class="kpi-card yellow">
                    <span class="kpi-label">Admissões no Ano</span>
                    <span class="kpi-value">${totalAdmissoesAno != null ? totalAdmissoesAno : 0}</span>
                    <span class="kpi-sub">ano ${anoSelecionado}</span>
                </div>

            </div>

            <%-- ══════════════════════════════════════════════
                 GRÁFICO + EXPORTAR
            ══════════════════════════════════════════════ --%>
            <div class="report-grid">

                <%-- Gráfico de admissões por mês --%>
                <div class="chart-card">
                    <div class="chart-card-header">
                        <h3>Admissões por Mês</h3>
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
                    <div class="chart-container-wrapper" style="position: relative; height: 130px; width: 100%;">
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
                    <p>Listagem Geral de Funcionários</p>
                </div>

                <table id="tabelaRelatorio">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Nome</th>
                            <th>CPF</th>
                            <th>Matrícula</th>
                            <th>Email</th>
                            <th>Telefone</th>
                            <th>Setor</th>
                            <th>Admissão</th>
                            <th>Status</th>
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
                                <td>${not empty f.telefone ? f.telefone : '—'}</td>
                                <td>${f.setor.nome}</td>
                                <td>${f.dataAdmissaoFormatada}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${f.status == 'ATIVO'}">
                                            <span class="badge badge-green">ATIVO</span>
                                        </c:when>
                                        <c:when test="${f.status == 'INATIVO'}">
                                            <span class="badge badge-red">INATIVO</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-gray">${f.status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty funcionarios}">
                            <tr>
                                <td colspan="9">
                                    <div class="empty-state">
                                        <i class="fa-solid fa-users"></i>
                                        <p>Nenhum funcionário encontrado para os filtros selecionados.</p>
                                    </div>
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

            if (meuGrafico) {
                meuGrafico.destroy();
            }

            meuGrafico = new Chart(ctx, {
                type: 'bar',
                data: {
                    labels: meses,
                    datasets: [{
                        label: 'Admissões',
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
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            backgroundColor: '#1e2535',
                            borderColor: 'rgba(255,255,255,0.1)',
                            borderWidth: 1,
                            titleColor: '#e2e8f0',
                            bodyColor: '#94a3b8',
                            callbacks: {
                                label: function (ctx) {
                                    return ' ' + ctx.parsed.y + ' admissões';
                                }
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
            const contextPath = '${pageContext.request.contextPath}';

            // IMPORTANTE: usar concatenacao de string, nunca crases (template literal)
            // dentro de script em jsp - a EL do JSP tenta avaliar qualquer cifrao-chave
            // no servidor e apaga o valor silenciosamente.
            fetch(contextPath + '/RelatorioFuncionarioController?action=dadosGrafico&ano=' + anoSelecionado)
                .then(function (response) { return response.json(); })
                .then(function (dados) {
                    renderizarGrafico(dados);
                })
                .catch(function (err) {
                    console.error('Erro ao carregar dados do gráfico:', err);
                });
        }

        /* ── Carga inicial (Executada estritamente uma única vez) ─────────────────────── */
        document.addEventListener('DOMContentLoaded', function () {
            const dadosIniciais = [
                <c:choose>
                    <c:when test="${not empty admissoesPorMes}">
                        <c:forEach var="qtd" items="${admissoesPorMes}" varStatus="s">
                            ${qtd}<c:if test="${!s.last}">,</c:if>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>0,0,0,0,0,0,0,0,0,0,0,0</c:otherwise>
                </c:choose>
            ];

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
                function (tr) { return !tr.querySelector('.empty-state'); }
            );

            if (linhas.length <= LINHAS_POR_PAGINA) {
                document.getElementById('paginationBar').style.display = 'none';
                return;
            }

            renderizarPagina(linhas, 1);
        }

        function renderizarPagina(linhas, pagina) {
            const totalPaginas = Math.ceil(linhas.length / LINHAS_POR_PAGINA);
            paginaAtual = Math.min(Math.max(pagina, 1), totalPaginas);

            const inicio = (paginaAtual - 1) * LINHAS_POR_PAGINA;
            const fim = inicio + LINHAS_POR_PAGINA;

            linhas.forEach(function (tr, i) {
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
            btnAnterior.onclick = function () { renderizarPagina(linhas, paginaAtual - 1); };
            controlesEl.appendChild(btnAnterior);

            for (let p = 1; p <= totalPaginas; p++) {
                const btnPagina = document.createElement('button');
                btnPagina.type = 'button';
                btnPagina.className = 'pagination-btn' + (p === paginaAtual ? ' active' : '');
                btnPagina.textContent = p;
                btnPagina.onclick = function () { renderizarPagina(linhas, p); };
                controlesEl.appendChild(btnPagina);
            }

            const btnProximo = document.createElement('button');
            btnProximo.type = 'button';
            btnProximo.className = 'pagination-btn';
            btnProximo.innerHTML = '<i class="fa-solid fa-chevron-right"></i>';
            btnProximo.disabled = (paginaAtual === totalPaginas);
            btnProximo.onclick = function () { renderizarPagina(linhas, paginaAtual + 1); };
            controlesEl.appendChild(btnProximo);
        }

        /* ── Exportar CSV ───────────────────────────────────────────────── */
        function exportarCSV() {
            const tabela = document.getElementById('tabelaRelatorio');
            if (!tabela) return;

            const linhas = [];
            const cabecalhos = [];
            tabela.querySelectorAll('thead th').forEach(function (th) {
                cabecalhos.push('"' + th.innerText.trim() + '"');
            });
            linhas.push(cabecalhos.join(';'));

            tabela.querySelectorAll('tbody tr').forEach(function (tr) {
                const cols = [];
                tr.querySelectorAll('td').forEach(function (td) {
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
            a.download = 'relatorio_funcionarios.csv';
            a.click();
            URL.revokeObjectURL(url);
        }

        function exportarPDF() {
            const jsPDFRef = window.jspdf.jsPDF;
            const doc = new jsPDFRef({ orientation: 'landscape' });

            const gerarPDF = function () {

                // ── Logo: quadrado roxo com calendário desenhado em canvas ──
                const size = 56;
                const canvas = document.createElement('canvas');
                canvas.width  = size;
                canvas.height = size;
                const ctx = canvas.getContext('2d');

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

                ctx.fillStyle = '#ffffff';
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

                ctx.fillStyle = '#4f46e5';
                const pontos = [
                    [18, 31], [28, 31], [38, 31],
                    [18, 38], [28, 38], [38, 38]
                ];
                pontos.forEach(function (p) {
                    ctx.beginPath();
                    ctx.arc(p[0], p[1], 2.2, 0, Math.PI * 2);
                    ctx.fill();
                });

                try {
                    doc.addImage(canvas.toDataURL('image/png'), 'PNG', 14, 7, 10, 10);
                } catch (e) {
                    console.warn('Logo não adicionado:', e);
                }

                // ── Cabeçalho de texto ────────────────────────────────────────
                doc.setFontSize(16);
                doc.setTextColor(30, 37, 53);
                doc.text('Relatório de Funcionários - FrequenSys', 27, 13);

                doc.setFontSize(9);
                doc.setTextColor(148, 163, 184);
                doc.text('Gerado em: ' + new Date().toLocaleString('pt-BR'), 27, 19);
                doc.setTextColor(0);

                // ── Coleta dados da tabela ────────────────────────────────────
                const tabela = document.getElementById('tabelaRelatorio');

                const cabecalhos = [];
                tabela.querySelectorAll('thead th').forEach(function (th) {
                    cabecalhos.push(th.innerText.trim());
                });

                const linhas = [];
                tabela.querySelectorAll('tbody tr').forEach(function (tr) {
                    const cols = [];
                    tr.querySelectorAll('td').forEach(function (td) {
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
                        1: { cellWidth: 36 },
                        4: { cellWidth: 40 }
                    }
                });

                // ── Rodapé com número de página ───────────────────────────────
                const totalPaginas = doc.internal.getNumberOfPages();
                for (let i = 1; i <= totalPaginas; i++) {
                    doc.setPage(i);
                    doc.setFontSize(7);
                    doc.setTextColor(180);
                    doc.text(
                        'Página ' + i + ' de ' + totalPaginas,
                        doc.internal.pageSize.getWidth() - 14,
                        doc.internal.pageSize.getHeight() - 8,
                        { align: 'right' }
                    );
                }

                doc.save('relatorio_funcionarios.pdf');
            };

            if (document.fonts && document.fonts.ready) {
                document.fonts.ready.then(gerarPDF);
            } else {
                gerarPDF();
            }
        }

        /* ── User dropdown ──────────────────────────────────────────────── */
        const dropdown = document.getElementById('userDropdown');
        if (dropdown) {
            dropdown.addEventListener('click', function (e) {
                e.stopPropagation();
                dropdown.classList.toggle('open');
            });
        }
        window.addEventListener('click', function () {
            if (dropdown) dropdown.classList.remove('open');
        });
    </script>

    <%-- ── Print styles ─────────────────────────────────────────────────── --%>
    <style>
        @media print {
            body { background: #fff !important; color: #000 !important; }
            .main-content { margin-left: 0 !important; }
            header.page-header,
            .filter-card,
            .export-card,
            .pagination-bar,
            nav, aside { display: none !important; }
            .detail-card table tbody tr { display: table-row !important; }
            .kpi-card, .chart-card, .detail-card {
                border: 1px solid #ccc !important;
                background: #fff !important;
                color: #000 !important;
                break-inside: avoid;
            }
            .kpi-value, .kpi-label, .kpi-sub,
            .chart-card-header h3, .detail-card-header h3,
            .detail-card-header p,
            td, th { color: #000 !important; }
            .report-grid { grid-template-columns: 1fr !important; }
        }
    </style>

</body>
</html>
