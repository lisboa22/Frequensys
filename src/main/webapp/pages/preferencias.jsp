<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<c:set var="pageTitle" value="Preferências" scope="request" />

<!DOCTYPE html>
<html lang="pt-br" data-theme="${temaAtual}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle} - FrequenSys</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/frequensys.css">
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

            <form action="${pageContext.request.contextPath}/PreferenciaController" method="post">

                <c:if test="${not empty sessionScope.mensagemSucesso}">
                    <div class="status-banner success" id="statusBanner">
                        <i class="fa-solid fa-circle-check"></i> ${sessionScope.mensagemSucesso}
                    </div>
                    <c:remove var="mensagemSucesso" scope="session" />
                </c:if>
                <c:if test="${not empty sessionScope.mensagemErro}">
                    <div class="status-banner error" id="statusBanner">
                        <i class="fa-solid fa-triangle-exclamation"></i> ${sessionScope.mensagemErro}
                    </div>
                    <c:remove var="mensagemErro" scope="session" />
                </c:if>

                <%-- ══════════════════════════════════════════════
                     SUBTÍTULO + SALVAR
                ══════════════════════════════════════════════ --%>
                <div class="pref-intro">
                    <p>Defina os parâmetros gerais para o controle de frequência e regras de ponto.</p>
                    <button type="submit" class="btn-save">
                        <i class="fa-solid fa-floppy-disk"></i> Salvar Alterações
                    </button>
                </div>

                <%-- ══════════════════════════════════════════════
                     GRID DE CONFIGURAÇÕES
                ══════════════════════════════════════════════ --%>
                <div class="settings-grid">

                    <%-- Tolerância de Entrada --%>
                    <div class="settings-card">
                        <div class="settings-card-header">
                            <div class="icon-wrap"><i class="fa-regular fa-clock"></i></div>
                            <h3>Tolerância de Entrada</h3>
                        </div>

                        <div class="setting-row">
                            <div class="setting-info">
                                <label>Tolerância para entrada com atraso</label>
                                <p>Tempo permitido após o horário de entrada para não considerar atraso.</p>
                            </div>
                            <div class="setting-control">
                                <div class="input-unit-wrap">
                                    <input type="number" name="toleranciaEntrada" value="${preferencia.toleranciaEntrada}" min="0">
                                    <span class="unit">minutos</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <%-- Tolerância de Saída --%>
                    <div class="settings-card">
                        <div class="settings-card-header">
                            <div class="icon-wrap"><i class="fa-solid fa-right-from-bracket"></i></div>
                            <h3>Tolerância de Saída</h3>
                        </div>

                        <div class="setting-row">
                            <div class="setting-info">
                                <label>Tolerância para saída antecipada</label>
                                <p>Tempo permitido antes do horário de saída para não considerar saída antecipada.</p>
                            </div>
                            <div class="setting-control">
                                <div class="input-unit-wrap">
                                    <input type="number" name="toleranciaSaida" value="${preferencia.toleranciaSaida}" min="0">
                                    <span class="unit">minutos</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <%-- Intervalo --%>
                    <div class="settings-card">
                        <div class="settings-card-header">
                            <div class="icon-wrap"><i class="fa-solid fa-mug-saucer"></i></div>
                            <h3>Intervalo</h3>
                        </div>

                        <div class="setting-row">
                            <div class="setting-info">
                                <label>Tempo de intervalo obrigatório</label>
                                <p>Tempo mínimo de intervalo para descanso ou refeição.</p>
                            </div>
                            <div class="setting-control">
                                <div class="input-unit-wrap">
                                    <input type="number" name="intervalo" value="${preferencia.intervalo}" min="0">
                                    <span class="unit">minutos</span>
                                </div>
                            </div>
                        </div>
                    </div>

                </div><%-- /settings-grid --%>

                <%-- ══════════════════════════════════════════════
                     APARÊNCIA
                ══════════════════════════════════════════════ --%>
                <div class="appearance-card">
                    <div class="settings-card-header">
                        <div class="icon-wrap"><i class="fa-solid fa-palette"></i></div>
                        <h3>Aparência</h3>
                    </div>

                    <div class="appearance-row">
                        <div class="appearance-info">
                            <label>Escolha o tema do aplicativo</label>
                            <p>Selecione entre o modo claro ou escuro para a interface do sistema.</p>
                        </div>

                        <div class="theme-options">
                            <label class="theme-option ${preferencia.modoEscuro ? 'selected' : ''}" id="optEscuro">
                                <input type="radio" name="modoEscuro" value="true" ${preferencia.modoEscuro ? 'checked' : ''}>
                                <span class="theme-icon"><i class="fa-solid fa-moon"></i></span>
                                <span class="theme-option-text">
                                    <strong>Escuro</strong>
                                    <span>Tema escuro</span>
                                </span>
                                <span class="theme-radio"></span>
                            </label>

                            <label class="theme-option ${!preferencia.modoEscuro ? 'selected' : ''}" id="optClaro">
                                <input type="radio" name="modoEscuro" value="false" ${!preferencia.modoEscuro ? 'checked' : ''}>
                                <span class="theme-icon"><i class="fa-solid fa-sun"></i></span>
                                <span class="theme-option-text">
                                    <strong>Claro</strong>
                                    <span>Tema claro</span>
                                </span>
                                <span class="theme-radio"></span>
                            </label>
                        </div>
                    </div>
                </div>

            </form>

        </div><%-- /dashboard-container --%>
    </main>

    <script>
        /* ── Fechar banner de status automaticamente após 5s ──────────────── */
        const statusBanner = document.getElementById('statusBanner');
        if (statusBanner) {
            setTimeout(() => {
                statusBanner.classList.add('hide');
                setTimeout(() => statusBanner.remove(), 400);
            }, 5000);
        }

        /* ── Seleção de tema (Escuro/Claro) — salva direto no banco via AJAX ── */
        document.querySelectorAll('.theme-option').forEach(opt => {
            opt.addEventListener('click', () => {
                document.querySelectorAll('.theme-option').forEach(o => o.classList.remove('selected'));
                opt.classList.add('selected');

                const radio = opt.querySelector('input[type="radio"]');
                radio.checked = true;

                const modoEscuro = radio.value; // "true" ou "false"

                fetch('${pageContext.request.contextPath}/PreferenciaController', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'apenasTema=true&modoEscuro=' + modoEscuro
                })
                .then(res => {
                    if (!res.ok) throw new Error('Falha ao salvar tema');
                    window.location.reload();
                })
                .catch(err => console.error('Erro ao salvar tema:', err));
            });
        });

        /* ── Alternância de abas (visual, sem recarregar página) ──────────── */
        document.querySelectorAll('.tab-item').forEach(tab => {
            tab.addEventListener('click', () => {
                document.querySelectorAll('.tab-item').forEach(t => t.classList.remove('active'));
                tab.classList.add('active');
            });
        });

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
