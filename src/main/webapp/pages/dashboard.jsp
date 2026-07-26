<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Painel" scope="request" />

<!DOCTYPE html>
<html lang="pt-br" data-theme="${temaAtual}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Painel - FrequenSys</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/frequensys.css">

    <style>
        /* ══════════════════════════════════════════════════════════
           PAINEL — usa as variáveis de tema definidas em frequensys.css
           (claro/escuro já resolvidos por --bg-card, --text-on-card, etc.)
           Escala de espaçamento: 4 / 8 / 12 / 16 / 24 / 32 / 48px
           ══════════════════════════════════════════════════════════ */

        .dashboard-container {
            display: flex;
            flex-direction: column;
            gap: 24px;
        }

        /* ── Grid de KPI cards ── */
        .kpi-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
        }
        .kpi-card {
            background: var(--bg-card);
            border-radius: 12px;
            padding: 20px;
            display: flex;
            align-items: center;
            gap: 16px;
            box-shadow: 0 1px 4px rgba(0,0,0,.06);
            border: 1px solid var(--border-color-soft);
        }
        .kpi-card:hover { box-shadow: 0 4px 16px rgba(0,0,0,.12); }
        .kpi-icon {
            width: 48px; height: 48px; border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.3rem; flex-shrink: 0;
        }
        .kpi-icon.blue   { background: rgba(99,102,241,.14); color: #818cf8; }
        .kpi-icon.green  { background: rgba(16,185,129,.14); color: #34d399; }
        .kpi-icon.red    { background: rgba(239,68,68,.14);  color: #f87171; }
        .kpi-icon.orange { background: rgba(245,158,11,.14); color: #fbbf24; }
        .kpi-icon.purple { background: rgba(139,92,246,.14); color: #a78bfa; }
        .kpi-icon.teal   { background: rgba(20,184,166,.14); color: #2dd4bf; }
        [data-theme="light"] .kpi-icon.blue   { color: #6366f1; }
        [data-theme="light"] .kpi-icon.green  { color: #10b981; }
        [data-theme="light"] .kpi-icon.red    { color: #ef4444; }
        [data-theme="light"] .kpi-icon.orange { color: #f59e0b; }
        [data-theme="light"] .kpi-icon.purple { color: #8b5cf6; }
        [data-theme="light"] .kpi-icon.teal   { color: #14b8a6; }
        .kpi-label {
            font-size: 0.75rem; color: var(--text-muted);
            text-transform: uppercase; letter-spacing: .5px;
            font-weight: 600; margin-bottom: 4px;
        }
        .kpi-value {
            font-size: 1.8rem; font-weight: 700;
            color: var(--text-on-card); line-height: 1;
        }
        .kpi-sub {
            font-size: 0.72rem; color: var(--text-muted); margin-top: 4px;
        }

        /* ── Grid de conteúdo ── */
        .dash-grid {
            display: grid;
            gap: 16px;
        }
        .dash-grid-2 { grid-template-columns: 1fr 1fr; }
        .dash-grid-3 { grid-template-columns: 2fr 1fr; }

        /* ── Card genérico ── */
        .dash-card {
            background: var(--bg-card);
            border-radius: 12px;
            border: 1px solid var(--border-color-soft);
            box-shadow: 0 1px 4px rgba(0,0,0,.06);
            overflow: hidden;
        }
        .dash-card-header {
            display: flex; align-items: center; justify-content: space-between;
            padding: 16px;
            border-bottom: 1px solid var(--border-color-soft);
        }
        .dash-card-title {
            font-size: 0.85rem; font-weight: 700;
            color: var(--text-on-card); text-transform: uppercase;
            letter-spacing: .4px;
        }
        .dash-card-body { padding: 16px; }

        /* ── Tabela interna ── */
        .dash-table { width: 100%; border-collapse: collapse; font-size: 0.83rem; }
        .dash-table th {
            text-align: left; padding: 8px 12px;
            color: var(--text-muted); font-weight: 600;
            text-transform: uppercase; font-size: 0.7rem;
            border-bottom: 1px solid var(--border-color-soft);
        }
        .dash-table td {
            padding: 12px; color: var(--text-on-card);
            border-bottom: 1px solid var(--border-color-soft);
            vertical-align: middle;
        }
        .dash-table tr:last-child td { border-bottom: none; }
        .dash-table tr:hover td { background: rgba(128,128,128,.06); }

        /* ── Badges de status ── */
        .badge {
            display: inline-block; padding: 4px 10px;
            border-radius: 20px; font-size: 0.72rem; font-weight: 600;
        }
        .badge-green  { background: rgba(16,185,129,.14); color: #10b981; }
        .badge-red    { background: rgba(239,68,68,.14);  color: #ef4444; }
        .badge-yellow { background: rgba(245,158,11,.14); color: #f59e0b; }
        .badge-blue   { background: rgba(99,102,241,.14); color: #818cf8; }
        .badge-gray   { background: rgba(148,163,184,.14);color: var(--text-muted); }
        [data-theme="light"] .badge-blue { color: #6366f1; }

        /* ── Barra de progresso ── */
        .progress-bar-wrap {
            display: flex; align-items: center; gap: 12px; margin-bottom: 16px;
        }
        .progress-bar-wrap:last-child { margin-bottom: 0; }
        .progress-label {
            font-size: 0.8rem; color: var(--text-on-card); font-weight: 500;
            min-width: 120px; white-space: nowrap;
            overflow: hidden; text-overflow: ellipsis;
        }
        .progress-track {
            flex: 1; height: 8px; background: var(--border-color-soft);
            border-radius: 99px; overflow: hidden;
        }
        .progress-fill {
            height: 100%; border-radius: 99px;
            transition: width .6s ease;
        }
        .progress-pct {
            font-size: 0.78rem; font-weight: 700;
            color: var(--text-on-card); min-width: 40px; text-align: right;
        }

        /* ── Ranking ── */
        .ranking-item {
            display: flex; align-items: center; gap: 12px;
            padding: 12px 0; border-bottom: 1px solid var(--border-color-soft);
        }
        .ranking-item:last-child { border-bottom: none; }
        .ranking-pos {
            width: 28px; height: 28px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.75rem; font-weight: 800; flex-shrink: 0;
        }
        .pos-1 { background: #fef3c7; color: #b45309; }
        .pos-2 { background: rgba(148,163,184,.2); color: var(--text-muted); }
        .pos-3 { background: #fde3c8; color: #9a5b13; }
        .pos-other { background: var(--border-color-soft); color: var(--text-muted); }
        .ranking-nome { font-size: 0.83rem; font-weight: 600; color: var(--text-on-card); }
        .ranking-setor { font-size: 0.72rem; color: var(--text-muted); }

        /* ── Alerta baixa frequência ── */
        .alerta-item {
            display: flex; align-items: center; justify-content: space-between;
            padding: 12px 0; border-bottom: 1px solid var(--border-color-soft); gap: 12px;
        }
        .alerta-item:last-child { border-bottom: none; }
        .alerta-nome { font-size: 0.83rem; font-weight: 600; color: var(--text-on-card); }
        .alerta-setor { font-size: 0.72rem; color: var(--text-muted); }
        .alerta-pct {
            font-size: 0.83rem; font-weight: 700; color: #ef4444;
            white-space: nowrap;
        }

        /* ── Canvas chart placeholder ── */
        .chart-wrap {
            position: relative; width: 100%;
            padding: 16px;
        }

        /* ── Empty state ── */
        .empty-state {
            text-align: center; padding: 32px 16px;
            color: var(--text-muted); font-size: 0.83rem;
        }
        .empty-state i { font-size: 1.8rem; margin-bottom: 8px; opacity: .4; }

        /* ── Link ver todos ── */
        .ver-todos {
            font-size: 0.78rem; color: var(--accent-primary); text-decoration: none;
            font-weight: 600;
        }
        .ver-todos:hover { text-decoration: underline; }

        /* ── Percentual geral destaque ── */
        .pct-destaque {
            display: flex; flex-direction: column; align-items: center;
            justify-content: center; padding: 24px;
        }
        .pct-numero {
            font-size: 3rem; font-weight: 800; color: var(--accent-primary); line-height: 1;
        }
        .pct-label { font-size: 0.8rem; color: var(--text-muted); margin-top: 8px; }

        /* ── Cabeçalho da página ── */
        .page-header-title { display: flex; align-items: center; gap: 16px; flex-wrap: wrap; }
        .page-header-sub { font-size: 0.8rem; color: var(--text-muted); font-weight: 400; }

        /* ── Responsividade ── */
        @media (max-width: 900px) {
            .dash-grid-2, .dash-grid-3 { grid-template-columns: 1fr; }
            .kpi-grid { grid-template-columns: repeat(2, 1fr); }
        }
        @media (max-width: 600px) {
            .kpi-grid { grid-template-columns: 1fr; }
            .dash-card-header { flex-direction: column; align-items: flex-start; gap: 8px; }
            .progress-label { min-width: 90px; }
        }
    </style>
</head>
<body>

    <jsp:include page="/includes/sidebar.jsp" />

    <main class="main-content">
        <header class="page-header">
            <div class="page-header-title">
                <h2>Painel</h2>
                <span class="page-header-sub">
                    Visão geral — <span id="dataHoje"></span>
                </span>
            </div>
            <jsp:include page="/includes/user-menu.jsp" />
        </header>

        <div class="dashboard-container">

            <%-- ══════════════════════════════════════════════════ --%>
            <%-- KPI CARDS                                          --%>
            <%-- ══════════════════════════════════════════════════ --%>
            <div class="kpi-grid">

                <div class="kpi-card">
                    <div class="kpi-icon blue"><i class="fa-solid fa-users"></i></div>
                    <div>
                        <div class="kpi-label">Funcionários Ativos</div>
                        <div class="kpi-value">${totalAtivos}</div>
                        <div class="kpi-sub">cadastrados e ativos</div>
                    </div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-icon green"><i class="fa-solid fa-user-check"></i></div>
                    <div>
                        <div class="kpi-label">Presentes Hoje</div>
                        <div class="kpi-value">${presencasHoje}</div>
                        <div class="kpi-sub">registraram entrada</div>
                    </div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-icon red"><i class="fa-solid fa-user-xmark"></i></div>
                    <div>
                        <div class="kpi-label">Ausentes Hoje</div>
                        <div class="kpi-value">${ausentesHoje}</div>
                        <div class="kpi-sub">sem registro de entrada</div>
                    </div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-icon orange"><i class="fa-solid fa-clock-rotate-left"></i></div>
                    <div>
                        <div class="kpi-label">Atrasos no Mês</div>
                        <div class="kpi-value">${atrasosNoMes}</div>
                        <div class="kpi-sub">registros com atraso</div>
                    </div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-icon purple"><i class="fa-solid fa-clipboard-list"></i></div>
                    <div>
                        <div class="kpi-label">Justificativas</div>
                        <div class="kpi-value">${justPendentes}</div>
                        <div class="kpi-sub">aguardando aprovação</div>
                    </div>
                </div>

                <div class="kpi-card">
                    <div class="kpi-icon teal"><i class="fa-solid fa-chart-line"></i></div>
                    <div>
                        <div class="kpi-label">Presença Mês</div>
                        <div class="kpi-value">
                            <fmt:formatNumber value="${percentualPresenca}" maxFractionDigits="1"/>%
                        </div>
                        <div class="kpi-sub">média geral de presença</div>
                    </div>
                </div>

            </div>

            <%-- ══════════════════════════════════════════════════ --%>
            <%-- LINHA 1: GRÁFICO PRESENÇA 7 DIAS + OCORRÊNCIAS    --%>
            <%-- ══════════════════════════════════════════════════ --%>
            <!--  <div class="dash-grid dash-grid-3" style="margin-bottom:24px;">

                <%-- Gráfico de linha: presenças nos últimos 7 dias --%>
                <div class="dash-card">
                    <div class="dash-card-header">
                        <span class="dash-card-title">
                            <i class="fa-solid fa-chart-area" style="color:#6366f1;margin-right:6px;"></i>
                            Presenças — Últimos 7 Dias
                        </span>
                    </div>
                    <div class="chart-wrap">
                        <canvas id="chartPresenca" height="120"></canvas>
                    </div>
                </div>

                <%-- Gráfico rosca: status das entradas no mês --%>
                <div class="dash-card">
                    <div class="dash-card-header">
                        <span class="dash-card-title">
                            <i class="fa-solid fa-chart-pie" style="color:#8b5cf6;margin-right:6px;"></i>
                            Status das Entradas
                        </span>
                    </div>
                    <div class="chart-wrap" style="display:flex;flex-direction:column;align-items:center;">
                        <canvas id="chartStatus" width="180" height="180"
                                style="max-width:180px;max-height:180px;"></canvas>
                        <div id="legendaStatus" style="margin-top:12px;font-size:0.78rem;color:#64748b;text-align:left;width:100%;"></div>
                    </div>
                </div>

            </div>-->
            <%-- ══════════════════════════════════════════════════ --%>
            <%-- LINHA 2: PRESENÇA POR SETOR + ÚLTIMAS MARCAÇÕES   --%>
            <%-- ══════════════════════════════════════════════════ --%>
            <div class="dash-grid dash-grid-2">

                <%-- Barras de progresso: presença por setor --%>
                <div class="dash-card">
                    <div class="dash-card-header">
                        <span class="dash-card-title">
                            <i class="fa-solid fa-building" style="color:#14b8a6;margin-right:6px;"></i>
                            Presença por Setor — Mês Atual
                        </span>
                    </div>
                    <div class="dash-card-body">
                        <c:choose>
                            <c:when test="${empty presencaPorSetor}">
                                <div class="empty-state">
                                    <i class="fa-solid fa-building"></i>
                                    <p>Sem dados de setor disponíveis.</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="ps" items="${presencaPorSetor}">
                                    <div class="progress-bar-wrap">
                                        <span class="progress-label" title="${ps['nomeSetor']}">${ps['nomeSetor']}</span>
                                        <div class="progress-track">
                                            <c:choose>
                                                <c:when test="${ps['percentual'] >= 85}">
                                                    <div class="progress-fill" style="width:${ps['percentual']}%;background:#10b981;"></div>
                                                </c:when>
                                                <c:when test="${ps['percentual'] >= 70}">
                                                    <div class="progress-fill" style="width:${ps['percentual']}%;background:#f59e0b;"></div>
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="progress-fill" style="width:${ps['percentual']}%;background:#ef4444;"></div>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                        <span class="progress-pct">${ps['percentual']}%</span>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <%-- Tabela: últimas marcações de hoje --%>
                <div class="dash-card">
                    <div class="dash-card-header">
                        <span class="dash-card-title">
                            <i class="fa-solid fa-list-check" style="color:#6366f1;margin-right:6px;"></i>
                            Últimas Marcações de Hoje
                        </span>
                        <a href="${pageContext.request.contextPath}/RegistroFrequenciaController"
                           class="ver-todos">Ver todos →</a>
                    </div>
                    <c:choose>
                        <c:when test="${empty ultimasMarcacoes}">
                            <div class="empty-state">
                                <i class="fa-solid fa-clock"></i>
                                <p>Nenhuma marcação registrada hoje.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <table class="dash-table">
                                <thead>
                                    <tr>
                                        <th>Funcionário</th>
                                        <th>Tipo</th>
                                        <th>Status</th>
                                        <th>Hora</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="m" items="${ultimasMarcacoes}">
                                        <tr>
                                            <td>
                                                <div style="font-weight:600;">${m['nome']}</div>
                                                <div style="font-size:0.72rem;color:#94a3b8;">${m['matricula']}</div>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${m['tipo'] == 'ENTRADA'}">
                                                        <span class="badge badge-green">${m['tipo']}</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-blue">${m['tipo']}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${m['status'] == 'NORMAL'}">
                                                        <span class="badge badge-green">${m['status']}</span>
                                                    </c:when>
                                                    <c:when test="${m['status'] == 'ATRASO'}">
                                                        <span class="badge badge-yellow">${m['status']}</span>
                                                    </c:when>
                                                    <c:when test="${m['status'] == 'SAIDA_ANTECIPADA'}">
                                                        <span class="badge badge-red">S. ANTECIPADA</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge badge-gray">${m['status']}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="font-weight:600;color:#6366f1;">${m['hora']}</td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:otherwise>
                    </c:choose>
                </div>

            </div>

            <%-- ══════════════════════════════════════════════════ --%>
            <%-- LINHA 3: RANKING ASSIDUIDADE + ALERTAS BAIXA FREQ --%>
            <%-- ══════════════════════════════════════════════════ --%>
            <div class="dash-grid dash-grid-2">

                <%-- Ranking Top 5 --%>
                <div class="dash-card">
                    <div class="dash-card-header">
                        <span class="dash-card-title">
                            <i class="fa-solid fa-trophy" style="color:#f59e0b;margin-right:6px;"></i>
                            Top 5 Assiduidade — Mês Atual
                        </span>
                    </div>
                    <div class="dash-card-body">
                        <c:choose>
                            <c:when test="${empty rankingAssiduidade}">
                                <div class="empty-state">
                                    <i class="fa-solid fa-trophy"></i>
                                    <p>Sem dados de assiduidade disponíveis.</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="r" items="${rankingAssiduidade}" varStatus="loop">
                                    <div class="ranking-item">
                                        <c:choose>
                                            <c:when test="${loop.index == 0}"><div class="ranking-pos pos-1"></c:when>
                                            <c:when test="${loop.index == 1}"><div class="ranking-pos pos-2"></c:when>
                                            <c:when test="${loop.index == 2}"><div class="ranking-pos pos-3"></c:when>
                                            <c:otherwise><div class="ranking-pos pos-other"></c:otherwise>
                                        </c:choose>
                                            ${loop.index + 1}
                                        </div>
                                        <div style="flex:1;">
                                            <div class="ranking-nome">${r['nome']}</div>
                                            <div class="ranking-setor">${r['matricula']} · ${r['nomeSetor']}</div>
                                        </div>
                                        <div>
                                            <c:choose>
                                                <c:when test="${r['percentual'] >= 90}">
                                                    <span class="badge badge-green">${r['percentual']}%</span>
                                                </c:when>
                                                <c:when test="${r['percentual'] >= 75}">
                                                    <span class="badge badge-yellow">${r['percentual']}%</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-red">${r['percentual']}%</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

                <%-- Alertas baixa frequência --%>
                <div class="dash-card">
                    <div class="dash-card-header">
                        <span class="dash-card-title">
                            <i class="fa-solid fa-triangle-exclamation" style="color:#ef4444;margin-right:6px;"></i>
                            Alertas de Baixa Frequência
                        </span>
                        <span style="font-size:0.72rem;color:#94a3b8;">abaixo de 75%</span>
                    </div>
                    <div class="dash-card-body">
                        <c:choose>
                            <c:when test="${empty alertasBaixa}">
                                <div class="empty-state">
                                    <i class="fa-solid fa-circle-check" style="color:#10b981;opacity:1;"></i>
                                    <p style="color:#10b981;font-weight:600;">Nenhum alerta ativo!</p>
                                    <p>Todos os funcionários estão com frequência adequada.</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="a" items="${alertasBaixa}">
                                    <div class="alerta-item">
                                        <div>
                                            <div class="alerta-nome">
                                                <i class="fa-solid fa-circle-exclamation"
                                                   style="color:#ef4444;font-size:.75rem;margin-right:4px;"></i>
                                                ${a['nome']}
                                            </div>
                                            <div class="alerta-setor">${a['matricula']} · ${a['nomeSetor']}</div>
                                        </div>
                                        <span class="alerta-pct">${a['percentual']}%</span>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>

            </div>

            <%-- ══════════════════════════════════════════════════ --%>
            <%-- LINHA 4: JUSTIFICATIVAS PENDENTES                  --%>
            <%-- ══════════════════════════════════════════════════ --%>
            <div class="dash-card">
                <div class="dash-card-header">
                    <span class="dash-card-title">
                        <i class="fa-solid fa-clipboard-check" style="color:#8b5cf6;margin-right:6px;"></i>
                        Justificativas Pendentes de Aprovação
                    </span>
                    <a href="${pageContext.request.contextPath}/JustificativaController"
                       class="ver-todos">Ver todas →</a>
                </div>
                <c:choose>
                    <c:when test="${empty justPendentesLista}">
                        <div class="empty-state">
                            <i class="fa-solid fa-clipboard-check"></i>
                            <p>Nenhuma justificativa pendente.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <table class="dash-table">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Funcionário</th>
                                    <th>Tipo</th>
                                    <th>Data Início</th>
                                    <th style="text-align:right;">Ação</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="jp" items="${justPendentesLista}">
                                    <tr>
                                        <td style="color:var(--text-muted);">#${jp['id']}</td>
                                        <td style="font-weight:600;">${jp['nomeFuncionario']}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${jp['tipo'] == 'ATESTADO'}">
                                                    <span class="badge badge-blue">${jp['tipo']}</span>
                                                </c:when>
                                                <c:when test="${jp['tipo'] == 'FALTA_JUSTIFICADA'}">
                                                    <span class="badge badge-yellow">FALTA JUST.</span>
                                                </c:when>
                                                <c:when test="${jp['tipo'] == 'ATRASO'}">
                                                    <span class="badge badge-yellow">${jp['tipo']}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-gray">${jp['tipo']}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>${jp['dataInicio']}</td>
                                        <td style="text-align:right;">
                                            <a href="${pageContext.request.contextPath}/JustificativaController"
                                               style="font-size:0.78rem;color:#6366f1;font-weight:600;text-decoration:none;">
                                                <i class="fa-solid fa-arrow-right"></i> Analisar
                                            </a>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </c:otherwise>
                </c:choose>
            </div>

        </div><%-- /dashboard-container --%>
    </main>

    <%-- ══════════════════════════════════════════════════════════════ --%>
    <%-- CHART.JS — Gráficos                                            --%>
    <%-- ══════════════════════════════════════════════════════════════ --%>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>

    <script>
        // ── Data atual no header ──────────────────────────────────────────────
        document.getElementById('dataHoje').textContent =
            new Date().toLocaleDateString('pt-BR', {weekday:'long',day:'2-digit',month:'long',year:'numeric'});

        // ── Dropdown usuário ──────────────────────────────────────────────────
        const dropdown = document.getElementById('userDropdown');
        if (dropdown) {
            dropdown.addEventListener('click', e => { e.stopPropagation(); dropdown.classList.toggle('open'); });
        }
        window.addEventListener('click', () => { if (dropdown) dropdown.classList.remove('open'); });

        // ════════════════════════════════════════════════════════════════════
        // GRÁFICO 1 — Presenças últimos 7 dias (linha)
        // Dados injetados pelo JSTL
        // ════════════════════════════════════════════════════════════════════
        const labelsPresenca = [];
        const valoresPresenca = [];

        <c:forEach var="entry" items="${registrosPorDia}">
            labelsPresenca.push('${entry.key}');
            valoresPresenca.push(${entry.value});
        </c:forEach>

        // Preenche dias sem registro com 0 para exibir o eixo completo
        if (labelsPresenca.length === 0) {
            for (let i = 6; i >= 0; i--) {
                const d = new Date(); d.setDate(d.getDate() - i);
                labelsPresenca.push(d.toLocaleDateString('pt-BR', {day:'2-digit',month:'2-digit'}));
                valoresPresenca.push(0);
            }
        }

        new Chart(document.getElementById('chartPresenca'), {
            type: 'line',
            data: {
                labels: labelsPresenca,
                datasets: [{
                    label: 'Funcionários Presentes',
                    data: valoresPresenca,
                    borderColor: '#6366f1',
                    backgroundColor: 'rgba(99,102,241,.10)',
                    borderWidth: 2.5,
                    pointBackgroundColor: '#6366f1',
                    pointRadius: 4,
                    pointHoverRadius: 6,
                    tension: 0.4,
                    fill: true,
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            label: ctx => ` ${ctx.raw} funcionários`
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: { stepSize: 1, color: '#94a3b8', font: { size: 11 } },
                        grid: { color: '#f1f5f9' }
                    },
                    x: {
                        ticks: { color: '#94a3b8', font: { size: 11 } },
                        grid: { display: false }
                    }
                }
            }
        });

        // ════════════════════════════════════════════════════════════════════
        // GRÁFICO 2 — Status das entradas no mês (rosca)
        // ════════════════════════════════════════════════════════════════════
        const labelsStatus  = [];
        const valoresStatus = [];

        <c:forEach var="entry" items="${ocorrenciasPorTipo}">
            labelsStatus.push('${entry.key}');
            valoresStatus.push(${entry.value});
        </c:forEach>

        const coresStatus = ['#10b981','#f59e0b','#ef4444','#6366f1','#8b5cf6','#14b8a6'];

        if (labelsStatus.length > 0) {
            new Chart(document.getElementById('chartStatus'), {
                type: 'doughnut',
                data: {
                    labels: labelsStatus,
                    datasets: [{
                        data: valoresStatus,
                        backgroundColor: coresStatus.slice(0, labelsStatus.length),
                        borderWidth: 2,
                        borderColor: '#fff',
                        hoverOffset: 4,
                    }]
                },
                options: {
                    responsive: false,
                    cutout: '68%',
                    plugins: {
                        legend: { display: false },
                        tooltip: {
                            callbacks: {
                                label: ctx => ` ${ctx.label}: ${ctx.raw} registros`
                            }
                        }
                    }
                }
            });

            // Legenda manual abaixo do gráfico
            const legenda = document.getElementById('legendaStatus');
            labelsStatus.forEach((lbl, i) => {
                legenda.innerHTML +=
                    `<span style="display:inline-flex;align-items:center;gap:5px;margin-right:12px;margin-bottom:4px;">
                       <span style="width:10px;height:10px;border-radius:50%;background:${coresStatus[i]};display:inline-block;"></span>
                       ${lbl}: <b>${valoresStatus[i]}</b>
                     </span>`;
            });
        } else {
            document.getElementById('chartStatus').style.display = 'none';
            document.getElementById('legendaStatus').innerHTML =
                '<div class="empty-state"><i class="fa-solid fa-chart-pie"></i><p>Sem dados no mês.</p></div>';
        }
    </script>

</body>
</html>
