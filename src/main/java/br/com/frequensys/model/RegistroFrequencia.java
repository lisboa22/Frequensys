package br.com.frequensys.model;

import java.time.LocalDateTime;

/**
 * Entidade que representa um registro de frequência de funcionário.
 *
 * Contém informações sobre o momento do registro (datahora), turno,
 * tipo de marcação, status do dia e eventuais ocorrências
 * (atraso, saída antecipada, carga cumprida, observação).
 */
public class RegistroFrequencia {

    private int           id;
    private int           idFuncionario;
    private LocalDateTime datahora;
    private int           idTurno;
    private String        tipo;
    private String        status;
    private int           minutosatraso;
    private int           minutossaidaantecipada;
    private String        cargahorariacumprida;
    private String        observacao;

    // ── Construtores ──────────────────────────────────────────────────────────

    public RegistroFrequencia() {}

    public RegistroFrequencia(int id, int idFuncionario, LocalDateTime datahora,
                               int idTurno, String tipo, String status,
                               int minutosatraso, int minutossaidaantecipada,
                               String cargahorariacumprida, String observacao) {
        this.id                    = id;
        this.idFuncionario         = idFuncionario;
        this.datahora              = datahora;
        this.idTurno               = idTurno;
        this.tipo                  = tipo;
        this.status                = status;
        this.minutosatraso         = minutosatraso;
        this.minutossaidaantecipada = minutossaidaantecipada;
        this.cargahorariacumprida  = cargahorariacumprida;
        this.observacao            = observacao;
    }

    // ── Getters & Setters ─────────────────────────────────────────────────────

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getIdFuncionario() { return idFuncionario; }
    public void setIdFuncionario(int idFuncionario) { this.idFuncionario = idFuncionario; }

    public LocalDateTime getDatahora() { return datahora; }
    public void setDatahora(LocalDateTime datahora) { this.datahora = datahora; }

    public int getIdTurno() { return idTurno; }
    public void setIdTurno(int idTurno) { this.idTurno = idTurno; }

    public String getTipo() { return tipo; }
    public void setTipo(String tipo) { this.tipo = tipo; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getMinutosatraso() { return minutosatraso; }
    public void setMinutosatraso(int minutosatraso) { this.minutosatraso = minutosatraso; }

    public int getMinutossaidaantecipada() { return minutossaidaantecipada; }
    public void setMinutossaidaantecipada(int minutossaidaantecipada) { this.minutossaidaantecipada = minutossaidaantecipada; }

    public String getCargahorariacumprida() { return cargahorariacumprida; }
    public void setCargahorariacumprida(String cargahorariacumprida) { this.cargahorariacumprida = cargahorariacumprida; }

    public String getObservacao() { return observacao; }
    public void setObservacao(String observacao) { this.observacao = observacao; }

    @Override
    public String toString() {
        return "RegistroFrequencia{" +
                "id=" + id +
                ", idFuncionario=" + idFuncionario +
                ", datahora=" + datahora +
                ", idTurno=" + idTurno +
                ", tipo='" + tipo + '\'' +
                ", status='" + status + '\'' +
                ", minutosatraso=" + minutosatraso +
                ", minutossaidaantecipada=" + minutossaidaantecipada +
                ", cargahorariacumprida='" + cargahorariacumprida + '\'' +
                ", observacao='" + observacao + '\'' +
                '}';
    }
}
