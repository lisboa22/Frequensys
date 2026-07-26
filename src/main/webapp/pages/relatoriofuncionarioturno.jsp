<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Relatório de Funcionário x Turno" scope="request" />

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
                 FILTROS
            ══════════════════════════════════════════════ --%>
            <div class="filter-card">
                <form action="RelatorioFuncionarioTurnoController" method="get">
                    <div class="filter-grid">

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
                                <option value="ATIVO"     <c:if test="${param.status == 'ATIVO'}">selected</c:if>>ATIVO</option>
                                <option value="ENCERRADO" <c:if test="${param.status == 'ENCERRADO'}">selected</c:if>>ENCERRADO</option>
                            </select>
                        </div>

                        <div class="filter-group">
                            <label>Início a partir de</label>
                            <input type="date" name="dataInicio"
                                   value="${param.dataInicio}">
                        </div>

                        <div class="filter-group">
                            <label>Início até</label>
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
                    <span class="kpi-label">Total de Vínculos</span>
                    <span class="kpi-value">${totalVinculos != null ? totalVinculos : 0}</span>
                    <span class="kpi-sub">no filtro aplicado</span>
                </div>

                <div class="kpi-card green">
                    <span class="kpi-label">Vínculos Ativos</span>
                    <span class="kpi-value">${totalAtivos != null ? totalAtivos : 0}</span>
                    <span class="kpi-sub">sem data fim ou vigentes</span>
                </div>

                <div class="kpi-card red">
                    <span class="kpi-label">Vínculos Encerrados</span>
                    <span class="kpi-value">${totalEncerrados != null ? totalEncerrados : 0}</span>
                    <span class="kpi-sub">data fim no passado</span>
                </div>

                <div class="kpi-card yellow">
                    <span class="kpi-label">Turnos em Uso</span>
                    <span class="kpi-value">${totalTurnosEmUso != null ? totalTurnosEmUso : 0}</span>
                    <span class="kpi-sub">turnos com vínculo ativo</span>
                </div>

            </div>

            <%-- ══════════════════════════════════════════════
                 GRÁFICO + EXPORTAR
            ══════════════════════════════════════════════ --%>
            <div class="report-grid">

                <%-- Gráfico de vínculos iniciados por mês --%>
                <div class="chart-card">
                    <div class="chart-card-header">
                        <h3>Vínculos Iniciados por Mês</h3>
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
                    <p>Listagem Geral de Vínculos Funcionário x Turno</p>
                </div>

                <table id="tabelaRelatorio">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Funcionário</th>
                            <th>Matrícula</th>
                            <th>Turno</th>
                            <th>Horário</th>
                            <th>Data Início</th>
                            <th>Data Fim</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="r" items="${funcionarioTurnos}">
                            <tr>
                                <td>${r.id}</td>

                                <%-- Funcionário --%>
                                <td style="font-weight: 500;">${r.funcionario.nome}</td>

                                <%-- Matrícula --%>
                                <td>${not empty r.funcionario.matricula ? r.funcionario.matricula : '—'}</td>

                                <%-- Turno --%>
                                <td>${r.turno.nome}</td>

                                <%-- Horário --%>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty r.turno.horaEntrada and not empty r.turno.horaSaida}">
                                            ${r.turno.horaEntrada} - ${r.turno.horaSaida}
                                        </c:when>
                                        <c:otherwise>—</c:otherwise>
                                    </c:choose>
                                </td>

                                <%-- Data Início (LocalDate — EL exibe no formato ISO yyyy-MM-dd) --%>
                                <td>${not empty r.dataInicio ? r.dataInicio : '—'}</td>

                                <%-- Data Fim --%>
                                <td>${not empty r.dataFim ? r.dataFim : 'Em aberto'}</td>

                                <%-- Status (derivado no Controller, via mapaStatusVinculo) --%>
                                <td>
                                    <c:set var="statusVinculo" value="${mapaStatusVinculo[r.id]}" />
                                    <c:choose>
                                        <c:when test="${statusVinculo == 'ATIVO'}">
                                            <span class="badge badge-green">ATIVO</span>
                                        </c:when>
                                        <c:when test="${statusVinculo == 'ENCERRADO'}">
                                            <span class="badge badge-red">ENCERRADO</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-gray">—</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty funcionarioTurnos}">
                            <tr>
                                <td colspan="8">
                                    <div class="empty-state">
                                        <i class="fa-solid fa-chart-bar"></i>
                                        <p>Nenhum vínculo encontrado para os filtros selecionados.</p>
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
        // contextPath resolvido pelo servidor (EL), usado nas chamadas AJAX abaixo
        const contextPath = '${pageContext.request.contextPath}';

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
                        label: 'Vínculos Iniciados',
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
                                label: ctx => ` ${ctx.parsed.y} vínculos`
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

            // Ajustado para bater no endpoint correto do RelatorioFuncionarioTurnoController
            fetch(contextPath + '/RelatorioFuncionarioTurnoController?action=dadosGrafico&ano=' + anoSelecionado)
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
                    <c:when test="${not empty vinculosPorMes}">
                        <c:forEach var="qtd" items="${vinculosPorMes}" varStatus="s">
                            ${qtd}<c:if test="${!s.last}">,</c:if>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>0,0,0,0,0,0,0,0,0,0,0,0</c:otherwise>
                </c:choose>
            ];

            // Renderiza sem acionar gatilho de requisição cíclica
            renderizarGrafico(dadosIniciais);
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
            a.download = 'relatorio_funcionarioturno.csv';
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
                doc.text('Relatório de Funcionário x Turno - FrequenSys', 27, 13);

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
                        1: { cellWidth: 42 },
                        3: { cellWidth: 30 }
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

                doc.save('relatorio_funcionarioturno.pdf');
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
