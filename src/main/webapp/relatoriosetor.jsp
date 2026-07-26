<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<c:set var="pageTitle" value="Relatório de Setores" scope="request" />

<!DOCTYPE html>
<html lang="pt-br">
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
        .filter-group input {
            background: var(--input-bg, #151c2c);
            border: 1px solid var(--border-color, rgba(255,255,255,0.1));
            border-radius: 8px;
            color: var(--text-primary, #e2e8f0);
            padding: 9px 12px;
            font-size: 0.875rem;
            font-family: inherit;
            outline: none;
            transition: border-color 0.2s;
        }
        .filter-group input:focus {
            border-color: #6366f1;
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
            padding: 20px 24px;
        }
        .chart-card-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 16px;
        }
        .chart-card-header h3 {
            font-size: 0.95rem;
            font-weight: 600;
            color: var(--text-primary, #e2e8f0);
            margin: 0;
        }

        /* ── Exportar card ─────────────────────────────────────────────── */
        .export-card {
            background: var(--card-bg, #1e2535);
            border: 1px solid var(--border-color, rgba(255,255,255,0.07));
            border-radius: 12px;
            padding: 20px 24px;
        }
        .export-card h3 {
            font-size: 0.95rem;
            font-weight: 600;
            color: var(--text-primary, #e2e8f0);
            margin: 0 0 16px 0;
        }
        .export-btn {
            display: flex;
            align-items: center;
            gap: 12px;
            width: 100%;
            padding: 13px 16px;
            background: var(--input-bg, #151c2c);
            border: 1px solid var(--border-color, rgba(255,255,255,0.08));
            border-radius: 8px;
            color: var(--text-primary, #e2e8f0);
            font-size: 0.875rem;
            font-family: inherit;
            cursor: pointer;
            transition: background 0.2s, border-color 0.2s;
            margin-bottom: 10px;
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
            color: var(--text-primary, #e2e8f0);
            vertical-align: middle;
        }
        .detail-card table tbody tr:last-child td {
            border-bottom: none;
        }
        .detail-card table tbody tr:hover td {
            background: rgba(255,255,255,0.03);
        }

        .badge {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 4px;
            font-size: 0.75rem;
            font-weight: 600;
        }
        .badge-green  { color:#10b981; background:rgba(16,185,129,0.12); }
        .badge-yellow { color:#f59e0b; background:rgba(245,158,11,0.12); }

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
                 FILTRO
            ══════════════════════════════════════════════ --%>
            <div class="filter-card">
                <form action="RelatorioSetorController" method="get">
                    <div class="filter-grid">

                        <div class="filter-group">
                            <label>Nome do Setor</label>
                            <input type="text" name="nome" placeholder="Buscar por nome..."
                                   value="${nomeFiltro}">
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
                    <span class="kpi-label">Total de Setores</span>
                    <span class="kpi-value">${totalSetores != null ? totalSetores : 0}</span>
                    <span class="kpi-sub">no filtro aplicado</span>
                </div>

                <div class="kpi-card green">
                    <span class="kpi-label">Com Descrição</span>
                    <span class="kpi-value">${comDescricao != null ? comDescricao : 0}</span>
                    <span class="kpi-sub">setores com descrição preenchida</span>
                </div>

                <div class="kpi-card yellow">
                    <span class="kpi-label">Sem Descrição</span>
                    <span class="kpi-value">${semDescricao != null ? semDescricao : 0}</span>
                    <span class="kpi-sub">setores sem descrição</span>
                </div>

                <div class="kpi-card blue">
                    <span class="kpi-label">Último Cadastrado</span>
                    <span class="kpi-value" style="font-size:1.15rem;">${ultimoCadastrado}</span>
                    <span class="kpi-sub">maior ID na base</span>
                </div>

            </div>

            <%-- ══════════════════════════════════════════════
                 GRÁFICO + EXPORTAR
            ══════════════════════════════════════════════ --%>
            <div class="report-grid">

                <%-- Gráfico: Com Descrição x Sem Descrição --%>
                <div class="chart-card">
                    <div class="chart-card-header">
                        <h3>Com Descrição x Sem Descrição</h3>
                    </div>
                    <div class="chart-container-wrapper" style="position: relative; height: 200px; width: 100%;">
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
                    <p>Listagem Geral de Setores</p>
                </div>

                <table id="tabelaRelatorio">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Nome</th>
                            <th>Descrição</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="s" items="${setores}">
                            <tr>
                                <td>${s.id}</td>
                                <td style="font-weight: 500;">${s.nome}</td>
                                <td>${not empty s.descricao ? s.descricao : '—'}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty s.descricao}">
                                            <span class="badge badge-green">Com Descrição</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-yellow">Sem Descrição</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty setores}">
                            <tr>
                                <td colspan="4">
                                    <div class="empty-state">
                                        <i class="fa-solid fa-chart-bar"></i>
                                        <p>Nenhum setor encontrado para o filtro selecionado.</p>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>

        </div><%-- /dashboard-container --%>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>

    <script>
        /* ── Gráfico: Com Descrição x Sem Descrição ─────────────────────── */
        document.addEventListener("DOMContentLoaded", () => {
            const ctx = document.getElementById('chartCanvas').getContext('2d');

            new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: ['Com Descrição', 'Sem Descrição'],
                    datasets: [{
                        data: [${comDescricao != null ? comDescricao : 0}, ${semDescricao != null ? semDescricao : 0}],
                        backgroundColor: ['#10b981', '#f59e0b'],
                        borderColor: '#1e2535',
                        borderWidth: 2
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'bottom',
                            labels: { color: '#94a3b8', font: { size: 11 } }
                        },
                        tooltip: {
                            backgroundColor: '#1e2535',
                            borderColor: 'rgba(255,255,255,0.1)',
                            borderWidth: 1,
                            titleColor: '#e2e8f0',
                            bodyColor: '#94a3b8'
                        }
                    }
                }
            });
        });

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
            a.download = 'relatorio_setores.csv';
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
                ctx.lineTo(0, r);
                ctx.quadraticCurveTo(0, 0, r, 0);
                ctx.closePath();
                ctx.fill();

                ctx.fillStyle = '#ffffff';
                ctx.beginPath();
                ctx.arc(size / 2, size / 2, 16, 0, Math.PI * 2);
                ctx.fill();

                ctx.fillStyle = '#6366f1';
                ctx.font = 'bold 20px Arial';
                ctx.textAlign = 'center';
                ctx.textBaseline = 'middle';
                ctx.fillText('S', size / 2, size / 2 + 1);

                try {
                    doc.addImage(canvas.toDataURL('image/png'), 'PNG', 14, 7, 10, 10);
                } catch (e) {
                    console.warn('Logo não adicionado:', e);
                }

                // ── Cabeçalho de texto ────────────────────────────────────────
                doc.setFontSize(16);
                doc.setTextColor(30, 37, 53);
                doc.text('Relatório de Setores - FrequenSys', 27, 13);

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
                        fontSize: 8,
                        cellPadding: 4
                    },
                    bodyStyles: {
                        fontSize: 8,
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
                        0: { cellWidth: 14 },
                        1: { cellWidth: 50 },
                        3: { cellWidth: 34 }
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

                doc.save('relatorio_setores.pdf');
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
            dropdown.addEventListener('click', e => {
                e.stopPropagation();
                dropdown.classList.toggle('open');
            });
        }
        window.addEventListener('click', () => {
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
            nav, aside { display: none !important; }
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
