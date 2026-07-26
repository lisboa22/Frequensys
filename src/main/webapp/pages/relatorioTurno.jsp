<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<c:set var="pageTitle" value="Relatório de Turnos" scope="request" />

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
                 TOOLBAR: FILTROS + EXPORTAÇÃO
            ══════════════════════════════════════════════ --%>
            <div class="filter-card">
                <form action="RelatorioTurnoController" method="get">
                    <div class="toolbar-row">

                        <div class="toolbar-group grow">
                            <label>Nome do Turno</label>
                            <input type="text" name="nome" placeholder="Buscar por nome..."
                                   value="${nomeFiltro}">
                        </div>

                        <div class="toolbar-group">
                            <label>Status</label>
                            <select name="status">
                                <option value="" ${empty statusFiltro ? 'selected' : ''}>Todos</option>
                                <option value="ATIVO" ${statusFiltro == 'ATIVO' ? 'selected' : ''}>Ativo</option>
                                <option value="INATIVO" ${statusFiltro == 'INATIVO' ? 'selected' : ''}>Inativo</option>
                            </select>
                        </div>

                        <button type="submit" class="btn-filter">
                            <i class="fa-solid fa-filter"></i> Filtrar
                        </button>

                        <button type="button" class="toolbar-btn" onclick="exportarPDF()">
                            <i class="fa-solid fa-file-pdf icon-pdf"></i> Baixar PDF
                        </button>

                        <button type="button" class="toolbar-btn" onclick="exportarCSV()">
                            <i class="fa-solid fa-file-excel icon-excel"></i> Baixar Excel (CSV)
                        </button>

                        <button type="button" class="toolbar-btn" onclick="window.print()">
                            <i class="fa-solid fa-print icon-print"></i> Imprimir Tela
                        </button>

                    </div>
                </form>
            </div>

            <%-- ══════════════════════════════════════════════
                 KPIs
            ══════════════════════════════════════════════ --%>
            <div class="kpi-row">

                <div class="kpi-card blue">
                    <span class="kpi-label">Total de Turnos</span>
                    <span class="kpi-value">${totalTurnos != null ? totalTurnos : 0}</span>
                    <span class="kpi-sub">no filtro aplicado</span>
                </div>

                <div class="kpi-card green">
                    <span class="kpi-label">Ativos</span>
                    <span class="kpi-value">${ativos != null ? ativos : 0}</span>
                    <span class="kpi-sub">turnos com status ativo</span>
                </div>

                <div class="kpi-card red">
                    <span class="kpi-label">Inativos</span>
                    <span class="kpi-value">${inativos != null ? inativos : 0}</span>
                    <span class="kpi-sub">turnos com status inativo</span>
                </div>

                <div class="kpi-card yellow">
                    <span class="kpi-label">Carga Horária Média</span>
                    <span class="kpi-value" style="font-size:1.3rem;">${cargaMediaFormatada}</span>
                    <span class="kpi-sub">por turno, diária</span>
                </div>

            </div>

            <%-- ══════════════════════════════════════════════
                 TABELA DE DETALHAMENTO
            ══════════════════════════════════════════════ --%>
            <div class="detail-card">
                <div class="detail-card-header">
                    <h3>Detalhamento</h3>
                    <p>Listagem Geral de Turnos</p>
                </div>

                <table id="tabelaRelatorio" class="table-nowrap">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Nome</th>
                            <th>Entrada</th>
                            <th>Saída</th>
                            <th>Toler. Entrada</th>
                            <th>Toler. Saída</th>
                            <th>Carga Horária</th>
                            <th>Status</th>
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
                                <td>${t.cargaHorariaDiaria} min</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${t.status == 'ATIVO'}">
                                            <span class="badge badge-green">Ativo</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-red">Inativo</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty turnos}">
                            <tr>
                                <td colspan="8">
                                    <div class="empty-state">
                                        <i class="fa-solid fa-chart-bar"></i>
                                        <p>Nenhum turno encontrado para o filtro selecionado.</p>
                                    </div>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>

                <div class="detail-card-footer">
                    <span class="footer-info">Exibindo <c:out value="${empty turnos ? 0 : fn:length(turnos)}" /> registros</span>
                    <div class="pagination">
                        <button type="button" disabled><i class="fa-solid fa-chevron-left"></i></button>
                        <button type="button" class="active">1</button>
                        <button type="button" disabled><i class="fa-solid fa-chevron-right"></i></button>
                    </div>
                </div>
            </div>

        </div><%-- /dashboard-container --%>
    </main>

    <script>
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
            a.download = 'relatorio_turnos.csv';
            a.click();
            URL.revokeObjectURL(url);
        }

        function exportarPDF() {
            const { jsPDF } = window.jspdf;
            const doc = new jsPDF({ orientation: 'landscape' });

            const gerarPDF = function () {

                // ── Logo: quadrado roxo com inicial desenhado em canvas ──
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

                ctx.fillStyle = '#ffffff';
                ctx.beginPath();
                ctx.arc(size / 2, size / 2, 16, 0, Math.PI * 2);
                ctx.fill();

                ctx.fillStyle = '#6366f1';
                ctx.font = 'bold 20px Arial';
                ctx.textAlign = 'center';
                ctx.textBaseline = 'middle';
                ctx.fillText('T', size / 2, size / 2 + 1);

                try {
                    doc.addImage(canvas.toDataURL('image/png'), 'PNG', 14, 7, 10, 10);
                } catch (e) {
                    console.warn('Logo não adicionado:', e);
                }

                // ── Cabeçalho de texto ────────────────────────────────────
                doc.setFontSize(16);
                doc.setTextColor(30, 37, 53);
                doc.text('Relatório de Turnos - FrequenSys', 27, 13);

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
                        0: { cellWidth: 10 },
                        1: { cellWidth: 40 }
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

                doc.save('relatorio_turnos.pdf');
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


</body>
</html>
