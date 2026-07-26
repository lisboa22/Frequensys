<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Registrar Frequência" scope="request" />

<!DOCTYPE html>
<html lang="pt-br" data-theme="${temaAtual}">
<head>
    <meta charset="UTF-8">
    <title>FrequenSys - ${pageTitle}</title>
    
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/frequensys.css">
</head>
<body data-context-path="${pageContext.request.contextPath}">

    <jsp:include page="/includes/sidebar.jsp" />

    <%-- ═══════════════════════════════════════════════════════
         MODAL DE LOGIN (inalterado)
    ════════════════════════════════════════════════════════ --%>
    <div class="modal-overlay" id="loginModal">
        <div class="login-card">
            <h3>Acesso ao Sistema</h3>
            
            <c:if test="${not empty sessionScope.mensagemErro}">
                <div id="msg-erro-login" class="alerta-erro-modal">
                    <span>${sessionScope.mensagemErro}</span>
                    <button type="button" class="btn-fechar-mini" onclick="this.parentElement.style.display='none'">&times;</button>
                </div>
            </c:if>

            <form id="formLogin" action="${pageContext.request.contextPath}/LoginController" method="post">
                <input type="hidden" name="action" value="adicionar">
                <div class="input-group">
                    <i class="fa-regular fa-envelope"></i>
                    <input name="loginInput" type="text" placeholder="E-mail ou Nome de Usuário" required>
                </div>
                <div class="input-group">
                    <i class="fa-solid fa-lock"></i>
                    <input name="senha" type="password" id="password" placeholder="Senha" required>
                </div>
                <button type="submit" class="btn-entrar">Entrar</button>
                <button type="button" class="btn-cancelar" onclick="toggleModal()">Cancelar</button>
            </form>
        </div>
    </div>

    <main class="main-content">
        <header class="page-header">
             <div class="header-title-group">
                <h2>${pageTitle}</h2>
            </div>
            
            <div id="container-avisos">
                <c:if test="${not empty sessionScope.mensagemSucesso}">
                    <div id="alerta-sucesso-sessao" class="alerta-custom alerta-sucesso">
                        <span><strong>✅ Sucesso!</strong> ${sessionScope.mensagemSucesso}</span>
                        <button type="button" class="btn-fechar-alerta" onclick="this.parentElement.style.display='none'">&times;</button>
                    </div>
                    <% session.removeAttribute("mensagemSucesso"); %>
                </c:if>
            </div>
            
            <jsp:include page="/includes/user-menu.jsp" />
        </header>

        <div class="ponto-container">
            <section class="clock-section">
                <div class="date-info" id="current-date">Atualizando data...</div>
                <h1 id="digital-clock">00:00:00</h1>
                <div class="terminal-status">
                    <i class="fa-solid fa-wifi"></i> Terminal Online
                </div>
                <div id="status-message" class="status-message-area">Escolha o tipo de Registro...</div>
            </section>
            
            <section class="action-section">
                <div class="buttons-group">
                    <%-- Os botões chamam ativarToken() — mesma assinatura de antes --%>
                    <button class="btn-ponto btn-in"  onclick="ativarToken('ENTRADA')"><i class="fa-solid fa-right-to-bracket"></i> ENTRADA</button>
                    <button class="btn-ponto btn-out" onclick="ativarToken('SAÍDA')"><i class="fa-solid fa-right-from-bracket"></i> SAÍDA</button>
                </div>
                <div class="log-table-container">
                    <div class="table-title">Registros Recentes de Hoje</div>
                    <div class="table-scroll-wrapper">
                        <table>
                            <thead><tr><th>EVENTO</th><th>HORÁRIO</th><th>STATUS</th></tr></thead>
                            <tbody id="tbody-registros-recentes">
                                <tr><td colspan="3" class="empty-log-message">Nenhum registro hoje.</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>
        </div>

        <footer class="user-footer">
            <%-- Campo oculto que guarda ENTRADA ou SAÍDA — alimentado por ativarToken() --%>
            <input type="hidden" id="tipo_registro">

            <div class="info-field">
                <span class="info-label">Matrícula</span>
                <span class="info-value" id="val_matricula">Aguardando...</span>
            </div>
            <div class="info-field">
                <label for="id_token" class="info-label">Token</label>
                <div class="token-field-row">
                    <input type="text"
                           id="id_token"
                           class="matricula-input"
                           placeholder="Bloqueado"
                           disabled
                           onkeydown="if(event.key==='Enter') enviarPonto()">
                    <button id="btn-confirmar-ponto"
                            class="btn-confirmar-estilo"
                            onclick="enviarPonto()">
                        Registrar Ponto
                    </button>
                </div>
            </div>
            <div class="info-field">
                <span class="info-label">Operação</span>
                <span class="info-value text-amber" id="val_operacao">Aguardando...</span>
            </div>
            <div class="info-field">
                <span class="info-label">Colaborador</span>
                <span class="info-value" id="val_colaborador">Aguardando...</span>
            </div>
        </footer>
    </main>

    <script>
        // ════════════════════════════════════════════════════════════════
        // CONTEXTO DA APLICAÇÃO (para o fetch)
        // ════════════════════════════════════════════════════════════════
        const CTX = document.body.getAttribute('data-context-path') || '';

        // ════════════════════════════════════════════════════════════════
        // INICIALIZAÇÃO
        // ════════════════════════════════════════════════════════════════
        window.addEventListener('load', function () {
            const erroLogin    = document.getElementById('msg-erro-login');
            const sucessoSessao = document.getElementById('alerta-sucesso-sessao');

            if (erroLogin) {
                document.getElementById('loginModal').classList.add('active');
                setTimeout(() => {
                    erroLogin.style.opacity = '0';
                    setTimeout(() => { erroLogin.style.display = 'none'; }, 500);
                }, 5000);
            }
            if (sucessoSessao) {
                setTimeout(() => { sucessoSessao.style.display = 'none'; }, 5000);
            }
        });

        // ════════════════════════════════════════════════════════════════
        // RELÓGIO E DATA  (inalterado)
        // ════════════════════════════════════════════════════════════════
        function updateClock() {
            document.getElementById('digital-clock').textContent =
                new Date().toLocaleTimeString('pt-BR');
        }
        function updateDate() {
            const options  = { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' };
            document.getElementById('current-date').textContent =
                new Date().toLocaleDateString('pt-BR', options);
        }
        setInterval(updateClock, 1000);
        updateClock();
        updateDate();

        // ════════════════════════════════════════════════════════════════
        // ATIVAR TOKEN — inalterado, apenas guarda o tipo no hidden
        // ════════════════════════════════════════════════════════════════
        function ativarToken(tipo) {
            const inputToken = document.getElementById('id_token');
            inputToken.disabled = false;
            inputToken.placeholder = "Digite o token...";
            inputToken.focus();

            document.getElementById('tipo_registro').value     = tipo;
            document.getElementById('val_operacao').textContent = tipo;

            const statusMsg = document.getElementById('status-message');
            statusMsg.classList.add('active');
            if (tipo === 'ENTRADA') {
                statusMsg.textContent = '➡ Entrada Selecionada';
                statusMsg.style.color = '#10b981';
            } else {
                statusMsg.textContent = '⬅ Saída Selecionada';
                statusMsg.style.color = '#ef4444';
            }
            document.getElementById('btn-confirmar-ponto').style.display = 'block';
        }

        // ════════════════════════════════════════════════════════════════
        // ENVIAR PONTO — agora chama o backend via AJAX
        // ════════════════════════════════════════════════════════════════
        async function enviarPonto() {
            const token     = document.getElementById('id_token').value.trim();
            const tipo      = document.getElementById('tipo_registro').value;
            const statusMsg = document.getElementById('status-message');
            const btnReg    = document.getElementById('btn-confirmar-ponto');

            // ── Validação local antes de ir ao servidor ──────────────────
            if (!token) {
                statusMsg.textContent = '⚠ Por favor, insira o token!';
                statusMsg.style.color = '#ef4444';
                statusMsg.classList.add('active');
                return;
            }
            if (!tipo) {
                statusMsg.textContent = '⚠ Selecione ENTRADA ou SAÍDA primeiro!';
                statusMsg.style.color = '#ef4444';
                statusMsg.classList.add('active');
                return;
            }

            // ── Loading no botão ─────────────────────────────────────────
            btnReg.disabled   = true;
            btnReg.innerHTML  = '<span class="spinner-inline"></span>Aguarde...';

            // ── Chamada AJAX ─────────────────────────────────────────────
            try {
                const params = new URLSearchParams({ token, tipo });
                const resp   = await fetch(CTX + '/RegistrarPontoController', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body:   params.toString()
                });

                if (!resp.ok) throw new Error('Falha na comunicação com o servidor.');

                const data = await resp.json();

                if (data.sucesso) {
                    // ── Sucesso ──────────────────────────────────────────
                    exibirSucesso(data, tipo);
                } else {
                    // ── Falha de negócio (token inválido, fora da janela) ─
                    exibirErro(data.mensagem);
                    // Mantém o token no campo para o usuário corrigir
                    btnReg.disabled  = false;
                    btnReg.innerHTML = 'Registrar Ponto';
                }

            } catch (err) {
                exibirErro('Erro de comunicação com o servidor. Tente novamente.');
                btnReg.disabled  = false;
                btnReg.innerHTML = 'Registrar Ponto';
            }
        }

        // ── Exibe resultado positivo e atualiza o rodapé ─────────────────
        function exibirSucesso(data, tipo) {
            const statusMsg      = document.getElementById('status-message');
            const valMatricula   = document.getElementById('val_matricula');
            const valColaborador = document.getElementById('val_colaborador');
            const btnReg         = document.getElementById('btn-confirmar-ponto');

            // Cor do status conforme resultado do servidor
            const corStatus = {
                'PRESENTE':         '#10b981',
                'ATRASO':           '#f59e0b',
                'SAÍDA ANTECIPADA': '#f97316'
            }[data.status] || '#10b981';

            statusMsg.textContent = '✔ ' + data.mensagem + ' (' + data.status + ')';
            statusMsg.style.color = corStatus;
            statusMsg.classList.add('active');

            valMatricula.textContent   = data.matricula   || '—';
            valColaborador.textContent = data.colaborador || '—';
            valMatricula.classList.add('highlight-data');
            valColaborador.classList.add('highlight-data');

            // Repopula a tabela com TODOS os registros do dia vindos do backend
            renderizarTabelaHoje(data.registrosHoje || []);

            // Reset do formulário
            resetarFormulario();

            // Restaura botão (ficará oculto após resetarFormulario)
            btnReg.disabled  = false;
            btnReg.innerHTML = 'Registrar Ponto';

            // Após 5 segundos, limpa o rodapé e a tabela
            setTimeout(() => {
                statusMsg.textContent = 'Escolha o tipo de Registro...';
                statusMsg.style.color = '#64748b';
                statusMsg.classList.remove('active');

                valMatricula.textContent = 'Aguardando...';
                valMatricula.classList.remove('highlight-data');
                valColaborador.textContent = 'Aguardando...';
                valColaborador.classList.remove('highlight-data');
                document.getElementById('val_operacao').textContent = 'Aguardando...';

                limparTabela();
            }, 5000);
        }

        // ── Renderiza a tabela completa com os registros do dia ──────────
        //    Recebe o array registrosHoje vindo do JSON do backend.
        //    Cada item: { tipo, horario, status }
        function renderizarTabelaHoje(registros) {
            const tbody = document.getElementById('tbody-registros-recentes');

            if (!registros || registros.length === 0) {
                tbody.innerHTML = '<tr><td colspan="3" class="empty-log-message">Nenhum registro hoje.</td></tr>';
                return;
            }

            tbody.innerHTML = '';

            // Cores por status
            const coresPorStatus = {
                'PRESENTE':         '#10b981',
                'ATRASO':           '#f59e0b',
                'SAÍDA ANTECIPADA': '#f97316'
            };

            registros.forEach((reg, index) => {
                const corStatus = coresPorStatus[reg.status] || '#10b981';

                const tr = document.createElement('tr');
                tr.classList.add('linha-recente-enter');

                const tdTipo   = document.createElement('td');
                const tdHora   = document.createElement('td');
                const tdStatus = document.createElement('td');

                tdTipo.textContent   = reg.tipo;
                tdHora.textContent   = reg.horario;
                tdStatus.textContent = reg.status;
                tdStatus.style.cssText = 'color: ' + corStatus + ' !important; font-weight: 600 !important;';

                tr.appendChild(tdTipo);
                tr.appendChild(tdHora);
                tr.appendChild(tdStatus);

                tbody.appendChild(tr);

                // Remove a animação de entrada após ela terminar
                setTimeout(() => tr.classList.remove('linha-recente-enter'), 400);
            });
        }

        // ── Exibe mensagem de erro sem resetar o tipo selecionado ────────
        function exibirErro(mensagem) {
            const statusMsg = document.getElementById('status-message');
            statusMsg.textContent = '✖ ' + mensagem;
            statusMsg.style.color = '#ef4444';
            statusMsg.classList.add('active');

            // Após 5 segundos retorna tudo ao estado inicial
            setTimeout(() => {
                statusMsg.textContent = 'Escolha o tipo de Registro...';
                statusMsg.style.color = '#64748b';
                statusMsg.classList.remove('active');

                const inputToken = document.getElementById('id_token');
                inputToken.value       = '';
                inputToken.disabled    = true;
                inputToken.placeholder = 'Bloqueado';

                document.getElementById('btn-confirmar-ponto').style.display = 'none';
                document.getElementById('tipo_registro').value               = '';
                document.getElementById('val_operacao').textContent          = 'Aguardando...';

                limparTabela();
            }, 5000);
        }

        // ── Limpa a tabela com fade-out e reexibe o placeholder ─────────
        function limparTabela() {
            const tbody = document.getElementById('tbody-registros-recentes');
            const linhas = Array.from(tbody.querySelectorAll('tr'));

            linhas.forEach(tr => {
                tr.classList.add('linha-recente-exit');
            });

            setTimeout(() => {
                tbody.innerHTML = '<tr><td colspan="3" class="empty-log-message">Nenhum registro hoje.</td></tr>';
            }, 400);
        }

        // ── Limpa campos de entrada após registro bem-sucedido ───────────
        function resetarFormulario() {
            document.getElementById('id_token').value        = '';
            document.getElementById('id_token').disabled     = true;
            document.getElementById('id_token').placeholder  = 'Bloqueado';
            document.getElementById('btn-confirmar-ponto').style.display = 'none';
            document.getElementById('val_operacao').textContent = 'Concluído';
        }


        // ════════════════════════════════════════════════════════════════
        // MODAL DE LOGIN  (inalterado)
        // ════════════════════════════════════════════════════════════════
        function toggleModal() {
            document.getElementById('loginModal').classList.toggle('active');
        }

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

    <c:if test="${not empty sessionScope.mensagemErro}">
        <% session.removeAttribute("mensagemErro"); %>
    </c:if>
</body>
</html>
