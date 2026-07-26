<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="pageTitle" value="Justificativas" scope="request" />

<!DOCTYPE html>
<html lang="pt-br" data-theme="${temaAtual}">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gerenciamento de ${pageTitle} - FrequenSys</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/frequensys.css">
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

            <%-- Mensagem de sucesso --%>
            <c:if test="${not empty sessionScope.mensagemSucesso}">
                <div id="alerta-sucesso" style="position: relative; background: rgba(16, 185, 129, 0.1); color: #10b981; padding: 15px; border-radius: 8px; margin-bottom: 20px; border: 1px solid rgba(16, 185, 129, 0.2);">
                    ${sessionScope.mensagemSucesso}
                    <button onclick="fecharAlerta()"
                            style="position: absolute; top: 5px; right: 10px; background: transparent; border: none; font-size: 18px; cursor: pointer;">
                        &times;
                    </button>
                </div>
                <% session.removeAttribute("mensagemSucesso"); %>
            </c:if>

            <%-- Mensagem de erro --%>
            <c:if test="${not empty sessionScope.mensagemErro}">
                <div id="alerta-erro" style="position: relative; background: rgba(239, 68, 68, 0.1); color: #ef4444; padding: 15px; border-radius: 8px; margin-bottom: 20px; border: 1px solid rgba(239, 68, 68, 0.2);">
                    ${sessionScope.mensagemErro}
                    <button onclick="document.getElementById('alerta-erro').style.display='none'"
                            style="position: absolute; top: 5px; right: 10px; background: transparent; border: none; font-size: 18px; cursor: pointer;">
                        &times;
                    </button>
                </div>
                <% session.removeAttribute("mensagemErro"); %>
            </c:if>

            <div class="table-container">
                <div class="table-header-row">
                    <div class="table-title">Justificativas Cadastradas</div>
                    <div class="header-actions" style="display: flex; flex-direction: row; align-items: center; gap: 10px;">
                    	<button class="btn-report" onclick="window.location.href='${pageContext.request.contextPath}/RelatorioJustificativaController'">
                            <i class="fa-solid fa-chart-bar"></i> Relatório
                        </button>
                        <button class="btn-primary" onclick="openModal()">
                            <i class="fa-solid fa-plus"></i> Nova Justificativa
                        </button>
                    </div>
                </div>

                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Funcionário</th>
                            <th>Registro</th>
                            <th>Tipo</th>
                            <th>Descrição</th>
                            <th>Data Início</th>
                            <th>Data Fim</th>
                            <th>Comprovante</th>
                            <th>Status</th>
                            <th>Aprovador</th>
                            <th style="text-align: right;">Ações</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="j" items="${justificativas}">
                            <tr>
                                <td>${j.id}</td>
                                <td style="font-weight: 500;">${j.funcionario.nome}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty j.registro}">${j.registro.id}</c:when>
                                        <c:otherwise>${j.idRegistro}</c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${j.tipo}</td>
                                <td style="max-width: 180px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;"
                                    title="${j.descricao}">${j.descricao}</td>
                                <td>
                                    <fmt:parseDate value="${j.dataInicio}" pattern="yyyy-MM-dd" var="dtIniFmt" type="date" />
                                    <fmt:formatDate value="${dtIniFmt}" pattern="dd/MM/yyyy" />
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty j.dataFim}">
                                            <fmt:parseDate value="${j.dataFim}" pattern="yyyy-MM-dd" var="dtFimFmt" type="date" />
                                            <fmt:formatDate value="${dtFimFmt}" pattern="dd/MM/yyyy" />
                                        </c:when>
                                        <c:otherwise>—</c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty j.documentoComprovante}">
                                            <a href="${pageContext.request.contextPath}/uploads/comprovantes/${j.documentoComprovante}"
                                               target="_blank" style="color: #6366f1; text-decoration: none;">
                                                <i class="fa-solid fa-file-lines"></i> Ver
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color: #94a3b8; font-size: 0.8rem;">Sem arquivo</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${j.status == 'APROVADO'}">
                                            <span style="color:#10b981;background:rgba(16,185,129,0.1);padding:4px 8px;border-radius:4px;font-size:0.8rem;">APROVADO</span>
                                        </c:when>
                                        <c:when test="${j.status == 'REPROVADO'}">
                                            <span style="color:#ef4444;background:rgba(239,68,68,0.1);padding:4px 8px;border-radius:4px;font-size:0.8rem;">REPROVADO</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color:#f59e0b;background:rgba(245,158,11,0.1);padding:4px 8px;border-radius:4px;font-size:0.8rem;">PENDENTE</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty j.aprovador}">
                                            ${j.aprovador.nome}
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color:#94a3b8;font-size:0.8rem;">—</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td style="text-align: right; white-space: nowrap;">
                                    <c:if test="${j.status == 'PENDENTE'}">
                                        <button class="btn-icon" title="Editar"
                                                onclick="openModalEditar(
                                                    '${j.id}',
                                                    '${j.funcionario.id}',
                                                    '${j.registro.id}',
                                                    '${j.tipo}',
                                                    '${j.descricao}',
                                                    '${j.dataInicio}',
                                                    '${j.dataFim}',
                                                    '${j.documentoComprovante}',
                                                    '${j.status}',
                                                    '${not empty j.aprovador ? j.aprovador.id : ""}'
                                                )">
                                            <i class="fa-solid fa-pen"></i>
                                        </button>
                                    </c:if>

                                    <c:if test="${isAdmin and j.status == 'PENDENTE'}">
                                        <button class="btn-icon" title="Aprovar" style="color:#10b981;"
                                                onclick="aprovarJustificativa(${j.id})">
                                            <i class="fa-solid fa-check"></i>
                                        </button>
                                        <button class="btn-icon" title="Reprovar" style="color:#ef4444;"
                                                onclick="reprovarJustificativa(${j.id})">
                                            <i class="fa-solid fa-xmark"></i>
                                        </button>
                                    </c:if>

                                    <c:if test="${isAdmin}">
                                        <button class="btn-icon delete" title="Excluir"
                                                onclick="excluirJustificativa(${j.id})">
                                            <i class="fa-solid fa-trash"></i>
                                        </button>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty justificativas}">
                            <tr>
                                <td colspan="11" style="text-align:center;color:#94a3b8;padding:30px;">
                                    Nenhuma justificativa cadastrada.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <%-- ================================= --%>
    <%-- MODAL: CADASTRAR JUSTIFICATIVA    --%>
    <%-- ================================= --%>
    <div id="modalCadastro" class="modal-overlay">
        <div class="modal-box">
            <h3>Nova Justificativa</h3>
            <form action="JustificativaController" method="post" enctype="multipart/form-data">
                <input type="hidden" name="action" value="adicionar">

                <div class="form-group">
                    <label>Funcionário</label>
                    <select name="idFuncionario" id="cad_idFuncionario" class="form-input" required
                            onchange="filtrarRegistros('cad_idFuncionario', 'cad_idRegistro')">
                        <option value="">Selecione...</option>
                        <c:forEach var="f" items="${funcionarios}">
                            <option value="${f.id}">${f.nome} — ${f.matricula}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label>Registro de Frequência</label>
                    <select name="idRegistro" id="cad_idRegistro" class="form-input">
                        <option value="">Selecione um funcionário primeiro...</option>
                        <c:forEach var="r" items="${registros}">
                            <option value="${r.id}"
                                    data-funcionario="${r.idFuncionario}"
                                    data-datahora="${r.datahora}">
                                #${r.id} — ${r.datahora}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label>Tipo</label>
                    <select name="tipo" class="form-input" required>
                        <option value="">Selecione...</option>
                        <option value="ATESTADO MÉDICO">ATESTADO MÉDICO</option>
                        <option value="FALTA JUSTIFICADA">FALTA JUSTIFICADA</option>
                        <option value="ATRASO">ATRASO</option>
                        <option value="SAÍDA ANTECIPADA">SAÍDA ANTECIPADA</option>
                        <option value="OUTRO">OUTRO</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Descrição</label>
                    <textarea name="descricao" class="form-input" rows="3"
                              placeholder="Descreva a justificativa..."></textarea>
                </div>
                <div style="display: flex; gap: 12px;">
                    <div class="form-group" style="flex: 1;">
                        <label>Data Início</label>
                        <input type="date" id="cad_dataInicio" class="form-input" placeholder="dd/mm/aaaa">
                        <input type="hidden" name="dataInicio" id="cad_dataInicio_hidden">
                    </div>
                    <div class="form-group" style="flex: 1;">
                        <label>Data Fim <span style="font-size:0.78rem;color:#94a3b8;">(opcional)</span></label>
                        <input type="date" name="dataFim" class="form-input">
                    </div>
                </div>
                <div class="form-group">
                    <label>Comprovante <span style="font-size:0.78rem;color:#94a3b8;">(PDF, JPG, PNG — máx. 5 MB)</span></label>
                    <input type="file" name="documentoComprovante" class="form-input"
                           accept=".pdf,.jpg,.jpeg,.png">
                </div>
                <div class="form-group"> 
                	<label>Status</label> 
                	<select name="status" class="form-input" required>
                        <option value="">Selecione...</option>
                        <option value="PENDENTE">PENDENTE</option>
                        <option value="APROVADO">APROVADO</option>
                        <option value="REJEITADO">REJEITADO</option>
                    </select>
                </div> 
                <div class="form-group"> 
                	<label>Aprovador</label> 
                	<select name="idAprovador" id="aprovador" class="form-input" required> 
                		<option value="">Selecione...</option> 
                		<c:forEach var="u" items="${usuarios}"> 
                			<option value="${u.id}">${u.nome}</option> 
                		</c:forEach> 
                	</select> 
                </div>

                <div style="margin-top:20px;display:flex;gap:10px;justify-content:flex-end;">
                    <button type="button" class="btn btn-outline" onclick="closeModal()">Cancelar</button>
                    <button type="submit" class="btn btn-primary">Enviar</button>
                </div>
            </form>
        </div>
    </div>

    <%-- ================================= --%>
    <%-- MODAL: EDITAR JUSTIFICATIVA       --%>
    <%-- ================================= --%>
    <div id="modalEditar" class="modal-overlay">
        <div class="modal-box">
            <h3>Editar Justificativa</h3>
            <form action="JustificativaController" method="post" enctype="multipart/form-data">
                <input type="hidden" name="action"                    value="editar">
                <input type="hidden" name="id"                        id="edit_id">
                <%-- Removidos os inputs ocultos redundantes de status e idAprovador que causavam duplicidade de ID --%>
                <input type="hidden" name="documentoComprovanteAtual" id="edit_comprovanteAtual">

                <div class="form-group">
                    <label>Funcionário</label>
                    <select name="idFuncionario" id="edit_idFuncionario" class="form-input" required
                            onchange="filtrarRegistros('edit_idFuncionario', 'edit_idRegistro')">
                        <option value="">Selecione...</option>
                        <c:forEach var="f" items="${funcionarios}">
                            <option value="${f.id}">${f.nome} — ${f.matricula}</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label>Registro de Frequência</label>
                    <select name="idRegistro" id="edit_idRegistro" class="form-input" required>
                        <option value="">Selecione um funcionário primeiro...</option>
                        <c:forEach var="r" items="${registros}">
                            <option value="${r.id}"
                                    data-funcionario="${r.idFuncionario}"
                                    data-datahora="${r.datahora}">
                                #${r.id} — ${r.datahora}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group">
                    <label>Tipo</label>
                    <select name="tipo" id="edit_tipo" class="form-input" required>
                        <option value="">Selecione...</option>
                        <option value="ATESTADO MÉDICO">ATESTADO MÉDICO</option>
                        <option value="FALTA JUSTIFICADA">FALTA JUSTIFICADA</option>
                        <option value="ATRASO">ATRASO</option>
                        <option value="SAÍDA ANTECIPADA">SAÍDA ANTECIPADA</option>
                        <option value="OUTRO">OUTRO</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Descrição</label>
                    <textarea name="descricao" id="edit_descricao" class="form-input" rows="3"></textarea>
                </div>
                <div style="display: flex; gap: 12px;">
                    <div class="form-group" style="flex: 1;">
                        <label>Data Início</label>
                        <input type="date" id="edit_dataInicio" class="form-input">
                        <input type="hidden" name="dataInicio" id="edit_dataInicio_hidden">
                    </div>
                    <div class="form-group" style="flex: 1;">
                        <label>Data Fim <span style="font-size:0.78rem;color:#94a3b8;">(opcional)</span></label>
                        <input type="date" name="dataFim" id="edit_dataFim" class="form-input">
                    </div>
                </div>
                <div class="form-group">
                    <label>Novo Comprovante <span style="font-size:0.78rem;color:#94a3b8;">(deixe vazio para manter o atual)</span></label>
                    <input type="file" name="documentoComprovante" class="form-input"
                           accept=".pdf,.jpg,.jpeg,.png">
                    <span id="edit_comprovanteNome"
                          style="font-size:0.78rem;color:#94a3b8;margin-top:4px;display:block;"></span>
                </div>
                <div class="form-group"> 
                	<label>Status</label> 
                	<select name="status" id="edit_status" class="form-input" required>
                        <option value="">Selecione...</option>
                        <option value="PENDENTE">PENDENTE</option>
                        <option value="APROVADO">APROVADO</option>
                        <option value="REJEITADO">REJEITADO</option>
                    </select>
                </div> 
                <div class="form-group"> 
                	<label>Aprovador</label> 
                	<select name="idAprovador" id="edit_idAprovador" class="form-input" required> 
                		<option value="">Selecione...</option> 
                		<c:forEach var="u" items="${usuarios}"> 
                			<option value="${u.id}">${u.nome}</option> 
                		</c:forEach> 
                	</select> 
                </div>
                

                <div style="margin-top:20px;display:flex;gap:10px;justify-content:flex-end;">
                    <button type="button" class="btn btn-outline" onclick="closeModalEditar()">Cancelar</button>
                    <button type="submit" class="btn btn-primary">Atualizar</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function capturarOptions(idSelect) {
            return Array.from(document.getElementById(idSelect).options)
                        .slice(1) 
                        .map(opt => ({
                            value:       opt.value,
                            text:        opt.text,
                            funcionario: opt.getAttribute('data-funcionario') || '',
                            datahora:    opt.getAttribute('data-datahora')    || ''
                        }));
        }

        const todosRegistrosCad  = capturarOptions('cad_idRegistro');
        const todosRegistrosEdit = capturarOptions('edit_idRegistro');

        function filtrarRegistros(idSelectFunc, idSelectReg, valorSelecionado) {
            const idFunc    = document.getElementById(idSelectFunc).value;
            const selectReg = document.getElementById(idSelectReg);
            const fonte     = idSelectReg === 'cad_idRegistro' ? todosRegistrosCad : todosRegistrosEdit;

            selectReg.innerHTML = '';
            const placeholder = new Option(
                idFunc ? 'Selecione o registro...' : 'Selecione um funcionário primeiro...', ''
            );
            selectReg.appendChild(placeholder);

            if (idFunc) {
                fonte.filter(opt => opt.funcionario === idFunc)
                     .forEach(opt => {
                         const nova = new Option(opt.text, opt.value);
                         nova.dataset.funcionario = opt.funcionario;
                         nova.dataset.datahora    = opt.datahora;
                         if (valorSelecionado && nova.value === String(valorSelecionado)) {
                             nova.selected = true;
                         }
                         selectReg.appendChild(nova);
                     });
            }

            const campoData = idSelectReg === 'cad_idRegistro' ? 'cad_dataInicio' : 'edit_dataInicio';
            preencherDataDoRegistro(idSelectReg, campoData);
        }

        function preencherDataDoRegistro(idSelectReg, idCampoData) {
            const selectReg   = document.getElementById(idSelectReg);
            const campoData   = document.getElementById(idCampoData);
            const campoHidden = document.getElementById(idCampoData + '_hidden');

            if (!selectReg || selectReg.selectedIndex < 0) return;

            const optSelecionada = selectReg.options[selectReg.selectedIndex];
            if (!optSelecionada) return;

            let datahora = optSelecionada.getAttribute("data-datahora");

            if (datahora) {
                const dataISO = datahora.includes(" ") ? datahora.split(" ")[0] : datahora.split("T")[0];

                if (campoHidden) campoHidden.value = dataISO;

                if (campoData.type === "text") {
                    const partes = dataISO.split("-");
                    campoData.value = partes[2] + "/" + partes[1] + "/" + partes[0];
                } else {
                    campoData.value = dataISO;
                }
                
                campoData.disabled = true;
            } else {
                campoData.value = '';
                campoData.disabled = false;
                if (campoHidden) campoHidden.value = '';
            }
        }

        // ---- Modais ----
        function openModal() {
            document.getElementById('modalCadastro').classList.add('show');
        }
        function closeModal() {
            document.getElementById('modalCadastro').classList.remove('show');
            document.getElementById('cad_idFuncionario').value = '';
            filtrarRegistros('cad_idFuncionario', 'cad_idRegistro');
        }

        function openModalEditar(id, idFuncionario, idRegistro, tipo, descricao,
                                  dataInicio, dataFim, comprovante, status, idAprovador) {
            document.getElementById('edit_id').value               = id;
            document.getElementById('edit_tipo').value             = tipo;
            document.getElementById('edit_descricao').value        = descricao;
            document.getElementById('edit_dataFim').value          = dataFim;
            document.getElementById('edit_comprovanteAtual').value = comprovante;
            document.getElementById('edit_status').value           = status;
            document.getElementById('edit_idAprovador').value      = idAprovador;
            document.getElementById('edit_comprovanteNome').textContent =
                comprovante ? 'Arquivo atual: ' + comprovante : 'Nenhum arquivo atual';

            document.getElementById('edit_idFuncionario').value = idFuncionario;
            
            filtrarRegistros('edit_idFuncionario', 'edit_idRegistro', idRegistro);
            preencherDataDoRegistro('edit_idRegistro', 'edit_dataInicio');

            document.getElementById('modalEditar').classList.add('show');
        }
        function closeModalEditar() {
            document.getElementById('modalEditar').classList.remove('show');
        }

        // ---- Ações via form dinâmico ----
        function aprovarJustificativa(id) {
            if (confirm("Confirma a APROVAÇÃO desta justificativa?")) enviarAcao('aprovar', id);
        }
        function reprovarJustificativa(id) {
            if (confirm("Confirma a REPROVAÇÃO desta justificativa?")) enviarAcao('reprovar', id);
        }
        function excluirJustificativa(id) {
            if (confirm("Deseja excluir esta justificativa?")) enviarAcao('deletar', id);
        }
        function enviarAcao(action, id) {
            const form = document.createElement("form");
            form.method = "post";
            form.action = "JustificativaController";
            const a = document.createElement("input");
            a.type = "hidden"; a.name = "action"; a.value = action;
            const i = document.createElement("input");
            i.type = "hidden"; i.name = "id"; i.value = id;
            form.appendChild(a); form.appendChild(i);
            document.body.appendChild(form); form.submit();
        }

        // ---- Alertas ----
        function fecharAlerta() {
            const el = document.getElementById('alerta-sucesso');
            if (el) el.style.display = 'none';
        }
        setTimeout(() => {
            const el = document.getElementById('alerta-sucesso');
            if (el) {
                el.style.transition = "opacity 0.5s ease";
                el.style.opacity = "0";
                setTimeout(() => el.style.display = 'none', 500);
            }
        }, 4000);

        // ---- Listeners dos selects de registro ----
        document.getElementById('cad_idRegistro').addEventListener('change', function() {
            preencherDataDoRegistro('cad_idRegistro', 'cad_dataInicio');
        });
        document.getElementById('edit_idRegistro').addEventListener('change', function() {
            preencherDataDoRegistro('edit_idRegistro', 'edit_dataInicio');
        });

        // ---- Dropdown usuário ----
        const dropdown = document.getElementById('userDropdown');
        if (dropdown) {
            dropdown.addEventListener('click', e => { e.stopPropagation(); dropdown.classList.toggle('open'); });
        }
        window.addEventListener('click', () => { if (dropdown) dropdown.classList.remove('open'); });
    </script>
</body>
</html>