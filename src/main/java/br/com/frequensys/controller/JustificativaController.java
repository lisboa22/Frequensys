package br.com.frequensys.controller;

import br.com.frequensys.dao.FuncionarioDAO;
import br.com.frequensys.dao.JustificativaDAO;
import br.com.frequensys.dao.RegistroFrequenciaDAO;
import br.com.frequensys.dao.UsuarioDAO;
import br.com.frequensys.model.Funcionario;
import br.com.frequensys.model.Justificativa;
import br.com.frequensys.model.RegistroFrequencia;
import br.com.frequensys.model.Usuario;
import br.com.frequensys.utils.Conexao;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

/**
 * Controller responsável pelo gerenciamento das requisições da entidade Justificativa.
 *
 * CORREÇÕES APLICADAS:
 * 1. listarJustificativas(): agora envia também "funcionarios", "registros" e "usuarios"
 *    para o JSP — sem isso os selects dos modais ficavam vazios.
 * 2. Instanciação de RegistroFrequenciaDAO adicionada ao init().
 * 3. UsuarioDAO.listarUsuarios() incluído no listar para popular select de aprovadores.
 */
@WebServlet("/JustificativaController")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize       = 5  * 1024 * 1024,
    maxRequestSize    = 10 * 1024 * 1024
)
public class JustificativaController extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final String UPLOAD_DIR = "uploads/comprovantes";

    private JustificativaDAO     justificativaDAO;
    private FuncionarioDAO       funcionarioDAO;
    private RegistroFrequenciaDAO registroDAO;
    private UsuarioDAO           usuarioDAO;

    @Override
    public void init() throws ServletException {
        try {
            justificativaDAO = new JustificativaDAO(Conexao.getConnection());
            funcionarioDAO   = new FuncionarioDAO(Conexao.getConnection());
            registroDAO      = new RegistroFrequenciaDAO(Conexao.getConnection());
            usuarioDAO       = new UsuarioDAO(Conexao.getConnection());
        } catch (Exception e) {
            throw new ServletException("Erro ao inicializar DAOs", e);
        }
    }

    // ==========================
    // GET — exibe listagem
    // ==========================

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuarioLogado") == null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        try {
            listarJustificativas(request, response);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ==========================
    // POST — roteia actions
    // ==========================

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuarioLogado") == null) {
            response.sendRedirect(request.getContextPath() + "/");
            return;
        }

        try {
            String action = request.getParameter("action");
            if (action == null) {
                listarJustificativas(request, response);
                return;
            }

            switch (action) {
                case "adicionar": adicionarJustificativa(request, response); break;
                case "editar":    editarJustificativa(request, response);    break;
                case "aprovar":   atualizarStatus(request, response, "APROVADO");  break;
                case "reprovar":  atualizarStatus(request, response, "REPROVADO"); break;
                case "deletar":   deletarJustificativa(request, response);  break;
                default:          listarJustificativas(request, response);   break;
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ==========================
    // CONTROLE DE ACESSO
    // ==========================

    private boolean isAdmin(HttpSession session) {
        Usuario u = (Usuario) session.getAttribute("usuarioLogado");
        if (u == null || u.getPerfil() == null) return false;
        String p = u.getPerfil().getNome();
        return p != null && p.trim().equalsIgnoreCase("ADMINISTRADOR");
    }

    // ==========================
    // ADICIONAR
    // ==========================

    private void adicionarJustificativa(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        try {
            Funcionario funcionario = new Funcionario();
            funcionario.setId(Integer.parseInt(request.getParameter("idFuncionario")));

            RegistroFrequencia registro = new RegistroFrequencia();
            registro.setId(Integer.parseInt(request.getParameter("idRegistro")));

            String tipo       = request.getParameter("tipo");
            String descricao  = request.getParameter("descricao");
            String dataIniStr = request.getParameter("dataInicio");
            String dataFimStr = request.getParameter("dataFim");

            LocalDate dataInicio = (dataIniStr != null && !dataIniStr.isBlank())
                                   ? LocalDate.parse(dataIniStr) : null;
            LocalDate dataFim    = (dataFimStr != null && !dataFimStr.isBlank())
                                   ? LocalDate.parse(dataFimStr) : null;

            String nomeArquivo = processarUpload(request);

            // Status inicial sempre PENDENTE; aprovador null
            Justificativa justificativa = new Justificativa(
                funcionario, registro, tipo, descricao,
                dataInicio, dataFim, nomeArquivo, "PENDENTE", null
            );

            justificativaDAO.adicionarJustificativa(justificativa);
            request.getSession().setAttribute("mensagemSucesso", "Justificativa cadastrada com sucesso!");

        } catch (Exception e) {
            request.getSession().setAttribute("mensagemErro", "Erro ao cadastrar justificativa.");
            throw e;
        }
        response.sendRedirect(request.getContextPath() + "/JustificativaController");
    }

    // ==========================
    // EDITAR
    // ==========================

    private void editarJustificativa(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        try {
            int id = Integer.parseInt(request.getParameter("id"));

            Funcionario funcionario = new Funcionario();
            funcionario.setId(Integer.parseInt(request.getParameter("idFuncionario")));

            RegistroFrequencia registro = new RegistroFrequencia();
            registro.setId(Integer.parseInt(request.getParameter("idRegistro")));

            String tipo             = request.getParameter("tipo");
            String descricao        = request.getParameter("descricao");
            String dataIniStr       = request.getParameter("dataInicio");
            String dataFimStr       = request.getParameter("dataFim");
            String status           = request.getParameter("status");
            String comprovanteAtual = request.getParameter("documentoComprovanteAtual");

            LocalDate dataInicio = (dataIniStr != null && !dataIniStr.isBlank())
                                   ? LocalDate.parse(dataIniStr) : null;
            LocalDate dataFim    = (dataFimStr != null && !dataFimStr.isBlank())
                                   ? LocalDate.parse(dataFimStr) : null;

            // Mantém comprovante anterior se nenhum novo for enviado
            String nomeArquivo = processarUpload(request);
            if (nomeArquivo == null || nomeArquivo.isBlank()) {
                nomeArquivo = comprovanteAtual;
            }

            // Preserva aprovador existente
            String idAprovadorStr = request.getParameter("idAprovador");
            Usuario aprovador = null;
            if (idAprovadorStr != null && !idAprovadorStr.isBlank()) {
                aprovador = new Usuario();
                aprovador.setId(Integer.parseInt(idAprovadorStr));
            }

            Justificativa justificativa = new Justificativa(
                id, funcionario, registro, tipo, descricao,
                dataInicio, dataFim, nomeArquivo, status, aprovador
            );

            justificativaDAO.alterarJustificativa(justificativa);
            request.getSession().setAttribute("mensagemSucesso", "Justificativa alterada com sucesso!");

        } catch (Exception e) {
            request.getSession().setAttribute("mensagemErro", "Erro ao alterar justificativa.");
            throw e;
        }
        response.sendRedirect(request.getContextPath() + "/JustificativaController");
    }

    // ==========================
    // APROVAR / REPROVAR
    // ==========================

    private void atualizarStatus(HttpServletRequest request, HttpServletResponse response,
                                  String novoStatus) throws Exception {
        HttpSession session = request.getSession(false);
        if (!isAdmin(session)) {
            session.setAttribute("mensagemErro", "Acesso negado. Apenas administradores podem aprovar/reprovar.");
            response.sendRedirect(request.getContextPath() + "/JustificativaController");
            return;
        }
        try {
            int id          = Integer.parseInt(request.getParameter("id"));
            Usuario logado  = (Usuario) session.getAttribute("usuarioLogado");
            justificativaDAO.atualizarStatus(id, novoStatus, logado.getId());
            String msg = "APROVADO".equals(novoStatus) ? "Justificativa aprovada!" : "Justificativa reprovada.";
            request.getSession().setAttribute("mensagemSucesso", msg);
        } catch (Exception e) {
            request.getSession().setAttribute("mensagemErro", "Erro ao atualizar status.");
            throw e;
        }
        response.sendRedirect(request.getContextPath() + "/JustificativaController");
    }

    // ==========================
    // DELETAR
    // ==========================

    private void deletarJustificativa(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        HttpSession session = request.getSession(false);
        if (!isAdmin(session)) {
            session.setAttribute("mensagemErro", "Acesso negado.");
            response.sendRedirect(request.getContextPath() + "/JustificativaController");
            return;
        }
        String idStr = request.getParameter("id");
        if (idStr != null && !idStr.isEmpty()) {
            try {
                justificativaDAO.excluirJustificativa(Integer.parseInt(idStr));
                request.getSession().setAttribute("mensagemSucesso", "Justificativa excluída com sucesso!");
            } catch (java.sql.SQLIntegrityConstraintViolationException e) {
                request.getSession().setAttribute("mensagemErro",
                    "Não é possível excluir: existem registros vinculados.");
            } catch (Exception e) {
                request.getSession().setAttribute("mensagemErro", "Erro ao excluir justificativa.");
                e.printStackTrace();
            }
        }
        response.sendRedirect(request.getContextPath() + "/JustificativaController");
    }

    // ==========================
    // LISTAR
    // ==========================

    /**
     * CORREÇÃO PRINCIPAL: além de "justificativas", agora envia para o JSP:
     * - "funcionarios" → List<Funcionario> para o select do formulário
     * - "registros"    → List<RegistroFrequencia> para o select do formulário
     * - "usuarios"     → List<Usuario> para o select de aprovador (uso admin)
     * - "isAdmin"      → boolean para controle de botões na view
     *
     * Sem esses atributos os selects ficavam vazios (nenhum dado para iterar).
     */
    private void listarJustificativas(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        List<Justificativa>      lista         = justificativaDAO.listarJustificativas();
        List<Funcionario>        funcionarios  = funcionarioDAO.listarFuncionarios();
        List<RegistroFrequencia> registros     = registroDAO.listarRegistros();
        List<Usuario>            usuarios      = usuarioDAO.listarUsuarios();

        request.setAttribute("justificativas", lista);
        request.setAttribute("funcionarios",   funcionarios);
        request.setAttribute("registros",      registros);
        request.setAttribute("usuarios",       usuarios);
        request.setAttribute("isAdmin",        isAdmin(request.getSession(false)));

        RequestDispatcher dispatcher = request.getRequestDispatcher("/pages/justificativa.jsp");
        dispatcher.forward(request, response);
    }

    // ==========================
    // UPLOAD
    // ==========================

    private String processarUpload(HttpServletRequest request) throws Exception {
        Part filePart = request.getPart("documentoComprovante");
        if (filePart == null || filePart.getSize() == 0) return null;

        String nomeOriginal = filePart.getSubmittedFileName();
        if (nomeOriginal == null || nomeOriginal.isBlank()) return null;

        String extensao    = nomeOriginal.contains(".")
                             ? nomeOriginal.substring(nomeOriginal.lastIndexOf(".")) : "";
        String nomeArquivo = System.currentTimeMillis() + extensao;

        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        filePart.write(uploadPath + File.separator + nomeArquivo);
        return nomeArquivo;
    }
}
