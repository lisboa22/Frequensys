package br.com.frequensys.controller;

import br.com.frequensys.dao.FuncionarioDAO;
import br.com.frequensys.dao.PreferenciaDAO;
import br.com.frequensys.dao.RegistroFrequenciaDAO;
import br.com.frequensys.dao.TurnoDAO;
import br.com.frequensys.model.Funcionario;
import br.com.frequensys.model.Preferencia;
import br.com.frequensys.model.RegistroFrequencia;
import br.com.frequensys.model.Turno;
import br.com.frequensys.utils.Conexao;

import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Servlet AJAX responsável por validar o token do funcionário
 * e registrar o ponto na tabela registrofrequencia.
 *
 * Endpoint : POST /RegistrarPontoController
 * Retorno  : JSON { sucesso, mensagem, matricula, colaborador, status }
 *
 * Fluxo completo:
 *  1. Recebe token + tipo (ENTRADA | SAÍDA) via POST
 *  2. Busca o funcionário pelo token — se não achar, retorna "Token Inválido!"
 *  3. Busca o turno ativo do funcionário via tabela funcionarioturno
 *     O vínculo correto é: funcionario → funcionarioturno → turno
 *  4. Valida a chegada antecipada (único bloqueio de horário existente),
 *     usando as tolerâncias globais configuradas em Preferências
 *     (tabela "preferencia", não mais fixas nem por turno):
 *     - ENTRADA: bloqueia se horaAtual < (horaEntrada - toleranciaEntrada),
 *       evitando que o funcionário bata o ponto bem antes do turno e
 *       gere horas extras indevidas. Não há bloqueio por chegar tarde.
 *     - SAÍDA  : nenhum bloqueio de horário — o registro de saída é
 *       sempre permitido, a qualquer momento.
 *     Se a tolerância de entrada configurada for 0, essa restrição fica
 *     DESATIVADA — ver passo 6.
 *  5. Calcula o status:
 *     - ENTRADA dentro da tolerância  → PRESENTE
 *     - ENTRADA após a tolerância     → ATRASO  + minutosatraso
 *     - SAÍDA dentro da tolerância    → PRESENTE
 *     - SAÍDA antes da tolerância     → SAÍDA ANTECIPADA + minutossaidaantecipada
 *  6. Persiste em registrofrequencia via RegistroFrequenciaDAO
 *  7. Devolve JSON com resultado para o front-end atualizar a UI
 *
 * Observações:
 * - Não exige sessão de usuário logado — é um terminal público de ponto.
 * - Gson é usado para serializar a resposta JSON.
 */
@WebServlet("/RegistrarPontoController")
public class RegistrarPontoController extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // ── POST: único ponto de entrada ──────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");

        PrintWriter out = response.getWriter();
        Map<String, Object> resultado = new HashMap<>();

        try (Connection con = Conexao.getConnection()) {

            String token = request.getParameter("token");
            String tipo  = request.getParameter("tipo");

            // ── 1. Validações básicas de entrada ──────────────────────────────
            if (token == null || token.isBlank()) {
                responder(out, resultado, false, "Por favor, insira o token!", null, null, null);
                return;
            }
            if (tipo == null || tipo.isBlank()) {
                responder(out, resultado, false,
                        "Selecione ENTRADA ou SAÍDA antes de confirmar.", null, null, null);
                return;
            }

            // ── 2. Valida o token e busca o funcionário ───────────────────────
            FuncionarioDAO funcDAO     = new FuncionarioDAO(con);
            Funcionario    funcionario = funcDAO.buscarPorToken(token.trim());

            if (funcionario == null) {
                responder(out, resultado, false, "Token Inválido!", null, null, null);
                return;
            }

            // Bloqueia funcionário inativo
            if (!"ATIVO".equalsIgnoreCase(funcionario.getStatus())) {
                responder(out, resultado, false,
                        "Funcionário inativo. Contate o RH.", null, null, null);
                return;
            }

            // ── 3. Busca o turno ativo do funcionário via funcionarioturno ────
            //
            // O vínculo correto é: funcionario → funcionarioturno → turno
            // A busca filtra pelo idFuncionario e pela data atual dentro
            // do período de vigência (dataInicio <= CURDATE() <= dataFim).
            //
            TurnoDAO turnoDAO = new TurnoDAO(con);
            Turno    turno    = turnoDAO.buscarTurnoAtivoPorFuncionario(funcionario.getId());

            if (turno == null) {
                responder(out, resultado, false,
                        "Nenhum turno ativo vinculado a este funcionário. Contate o RH.",
                        null, null, null);
                return;
            }

            // ── 3.5. Carrega as tolerâncias globais (tabela preferencia) ──────
            //
            //  As tolerâncias de entrada/saída não são mais lidas do turno:
            //  agora vêm da configuração única e global do sistema, editável
            //  em Preferências (mesma tabela usada por PreferenciaController).
            //
            //  Regra especial: valor 0 = tolerância DESATIVADA para aquele
            //  tipo (entrada ou saída) — nesse caso não há bloqueio por
            //  chegada antecipada nem cálculo de atraso/saída antecipada
            //  baseado em tolerância; o registro é sempre aceito dentro da
            //  janela do turno e marcado como PRESENTE.
            //
            PreferenciaDAO preferenciaDAO = new PreferenciaDAO(con);
            Preferencia    preferencia    = preferenciaDAO.buscarPreferencia();

            if (preferencia == null) {
                // Nenhuma configuração salva ainda: usa os mesmos padrões
                // exibidos em Preferências (15 min, 10 min, 60 min, escuro).
                preferencia = new Preferencia(15, 10, 60, true);
            }

            int toleranciaEntrada = preferencia.getToleranciaEntrada();
            int toleranciaSaida   = preferencia.getToleranciaSaida();

            boolean toleranciaEntradaAtiva = toleranciaEntrada > 0;
            boolean toleranciaSaidaAtiva   = toleranciaSaida > 0;

            // ── 4. Hora atual do sistema ──────────────────────────────────────
            LocalDateTime agora     = LocalDateTime.now();
            LocalTime     horaAgora = agora.toLocalTime();

            // ── 5. Bloqueia registro duplicado no mesmo dia ───────────────────
            //
            //  Regra: cada funcionário pode registrar apenas UMA ENTRADA
            //  e UMA SAÍDA por dia. Se já existir um registro do mesmo tipo
            //  hoje, o sistema recusa e informa o colaborador.
            //
            RegistroFrequenciaDAO registroDAO = new RegistroFrequenciaDAO(con);

            if (registroDAO.verificarRegistroHoje(funcionario.getId(), tipo)) {
                String tipoFmt = "ENTRADA".equalsIgnoreCase(tipo) ? "entrada" : "saída";
                responder(out, resultado, false,
                        "Ponto de " + tipoFmt + " já registrado hoje!",
                        funcionario.getMatricula(),
                        funcionario.getNome(),
                        null);
                return;
            }

            // ── 6. Validação da janela de registro (ENTRADA e SAÍDA) ─────────
            //
            //  ENTRADA:
            //    Único bloqueio possível é "chegada antecipada", baseado
            //    exclusivamente na tolerância de entrada — não é permitido
            //    bater o ponto muito antes do horário do turno, pois isso
            //    geraria horas extras indevidas.
            //    Limite mínimo permitido: horaEntrada - toleranciaEntrada
            //    Se toleranciaEntrada == 0 (desativada), não há bloqueio.
            //    Não existe limite de "muito tarde" para entrada — chegar
            //    atrasado não bloqueia o registro, apenas gera o status
            //    ATRASO (calculado no passo 7).
            //
            //  SAÍDA:
            //    Não há nenhum tipo de bloqueio de horário. O funcionário
            //    pode registrar a saída a qualquer momento; a tolerância de
            //    saída é usada apenas para classificar o status como
            //    SAÍDA ANTECIPADA (passo 7), nunca para impedir o registro.
            //
            String horaEntradaFmt = turno.getHoraEntrada().toString();

            if ("ENTRADA".equalsIgnoreCase(tipo)) {

                if (toleranciaEntradaAtiva) {
                    LocalTime limiteMinimo = turno.getHoraEntrada()
                            .minusMinutes(toleranciaEntrada);

                    if (horaAgora.isBefore(limiteMinimo)) {
                        long minutosRestantes = Duration.between(horaAgora, limiteMinimo).toMinutes();
                        responder(out, resultado, false,
                                "Registro antecipado não permitido. "
                                + "Seu turno inicia às " + horaEntradaFmt
                                + ". Aguarde " + minutosRestantes + " minuto(s).",
                                null, null, null);
                        return;
                    }
                }
                // toleranciaEntradaAtiva == false → sem bloqueio por chegada antecipada

            }
            // SAÍDA: nenhuma validação de janela — registro sempre permitido

            // ── 7. Calcula status, minutosatraso e minutossaidaantecipada ──────
            String statusRegistro         = "PRESENTE";
            int    minutosatraso          = 0;
            int    minutossaidaantecipada = 0;

            if ("ENTRADA".equalsIgnoreCase(tipo)) {
                //
                // Limite máximo de chegada sem ser considerado atraso:
                //   horaEntrada + toleranciaEntrada
                //
                // Exemplo: turno 08:00, tolerância 15 min → limite = 08:15
                //   08:00 a 08:15 → PRESENTE
                //   após  08:15   → ATRASO (calcula minutos desde 08:00)
                //
                // Se toleranciaEntradaAtiva == false (valor 0), a tolerância
                // está desativada: não há cálculo de atraso, status sempre
                // PRESENTE para entrada.
                //
                if (toleranciaEntradaAtiva) {
                    LocalTime limiteAtraso = turno.getHoraEntrada()
                            .plusMinutes(toleranciaEntrada);

                    if (horaAgora.isAfter(limiteAtraso)) {
                        statusRegistro = "ATRASO";
                        minutosatraso  = (int) Duration
                                .between(turno.getHoraEntrada(), horaAgora).toMinutes();
                    }
                }

            } else { // SAÍDA
                //
                // Limite mínimo de saída sem ser considerado saída antecipada:
                //   horaSaida - toleranciaSaida
                //
                // Exemplo: turno saída 17:00, tolerância 15 min → limite = 16:45
                //   a partir de 16:45 → PRESENTE
                //   antes de  16:45   → SAÍDA ANTECIPADA (calcula minutos até 17:00)
                //
                // Se toleranciaSaidaAtiva == false (valor 0), a tolerância
                // está desativada: não há cálculo de saída antecipada, status
                // sempre PRESENTE para saída.
                //
                if (toleranciaSaidaAtiva) {
                    LocalTime limiteSaidaMinimo = turno.getHoraSaida()
                            .minusMinutes(toleranciaSaida);

                    if (horaAgora.isBefore(limiteSaidaMinimo)) {
                        statusRegistro         = "SAÍDA ANTECIPADA";
                        minutossaidaantecipada = (int) Duration
                                .between(horaAgora, turno.getHoraSaida()).toMinutes();
                    }
                }
            }

            // ── 8. Monta e persiste o registro de frequência ─────────────────
            RegistroFrequencia registro = new RegistroFrequencia();
            registro.setIdFuncionario(funcionario.getId());
            registro.setDatahora(agora);
            registro.setIdTurno(turno.getId());
            registro.setTipo(tipo.toUpperCase());
            registro.setStatus(statusRegistro);
            registro.setMinutosatraso(minutosatraso);
            registro.setMinutossaidaantecipada(minutossaidaantecipada);
            registro.setCargahorariacumprida(""); // calculado no fechamento do dia
            registro.setObservacao("");

            // registroDAO já foi instanciado na etapa de validação de duplicata
            registroDAO.adicionarRegistro(registro);

            // ── 9. Busca todos os registros do funcionário no dia de hoje ─────
            //
            //  Retornados no JSON para o front-end popular a tabela completa,
            //  garantindo que o colaborador veja o histórico do dia todo.
            //
            List<RegistroFrequencia> registrosHoje =
                    registroDAO.listarRegistrosHojePorFuncionario(funcionario.getId());

            // ── 10. Resposta de sucesso ao front-end ──────────────────────────
            responderComLista(out, resultado, true,
                    tipo.toUpperCase() + " registrada com sucesso!",
                    funcionario.getMatricula(),
                    funcionario.getNome(),
                    statusRegistro,
                    registrosHoje);

        } catch (Exception e) {
            e.printStackTrace();
            responder(out, resultado, false,
                    "Erro interno ao registrar ponto. Tente novamente.", null, null, null);
        }
    }

    // ── Helper: resposta com lista de registros do dia ────────────────────────

    /**
     * Versão estendida do helper de resposta que inclui a lista de registros
     * do dia do funcionário, serializada como array JSON.
     *
     * Cada item do array contém: tipo, datahora (como string HH:mm:ss) e status.
     */
    private void responderComLista(PrintWriter out, Map<String, Object> resultado,
                                    boolean sucesso, String mensagem,
                                    String matricula, String colaborador, String status,
                                    List<RegistroFrequencia> registros) {

        // Serializa apenas os campos necessários para o front-end
        List<Map<String, String>> lista = new ArrayList<>();
        for (RegistroFrequencia r : registros) {
            Map<String, String> item = new HashMap<>();
            item.put("tipo",    r.getTipo());
            item.put("horario", r.getDatahora() != null
                    ? r.getDatahora().toLocalTime().toString() : "");
            item.put("status",  r.getStatus());
            lista.add(item);
        }

        resultado.clear();
        resultado.put("sucesso",        sucesso);
        resultado.put("mensagem",       mensagem);
        resultado.put("matricula",      matricula   != null ? matricula   : "");
        resultado.put("colaborador",    colaborador != null ? colaborador : "");
        resultado.put("status",         status      != null ? status      : "");
        resultado.put("registrosHoje",  lista);
        out.print(new Gson().toJson(resultado));
        out.flush();
    }

    // ── Helper: monta e escreve o JSON de resposta ────────────────────────────

    /**
     * Serializa o mapa de resultado em JSON e escreve na resposta HTTP.
     *
     * @param out         PrintWriter da resposta
     * @param resultado   mapa reutilizado para evitar alocações extras
     * @param sucesso     true se a operação foi bem-sucedida
     * @param mensagem    texto exibido na pílula de status da tela
     * @param matricula   matrícula do funcionário (null em caso de erro)
     * @param colaborador nome do funcionário (null em caso de erro)
     * @param status      status calculado do registro (null em caso de erro)
     */
    private void responder(PrintWriter out, Map<String, Object> resultado,
                            boolean sucesso, String mensagem,
                            String matricula, String colaborador, String status) {
        resultado.clear();
        resultado.put("sucesso",     sucesso);
        resultado.put("mensagem",    mensagem);
        resultado.put("matricula",   matricula   != null ? matricula   : "");
        resultado.put("colaborador", colaborador != null ? colaborador : "");
        resultado.put("status",      status      != null ? status      : "");
        out.print(new Gson().toJson(resultado));
        out.flush();
    }
}