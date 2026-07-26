package br.com.frequensys.model;

import java.time.LocalTime;

/**
 * Model da entidade Turno conforme estrutura da tabela no banco.
 *
 * Colunas: id (PK), nome, horaEntrada, horaSaida,
 *          toleranciaAtraso (minutos), toleranciaSaida (minutos),
 *          cargaHorariaDiaria (minutos), status
 */
public class Turno {

    private int       id;
    private String    nome;
    private LocalTime horaEntrada;
    private LocalTime horaSaida;
    private int       toleranciaEntrada;    // em minutos
    private int       toleranciaSaida;     // em minutos
    private int       cargaHorariaDiaria;  // em minutos
    private String    status;              // Ex: "ATIVO" | "INATIVO"

    // -------------------------
    // Construtores
    // -------------------------

    /** Construtor vazio — necessário para instanciação sem dados (ex: ResultSet). */
    public Turno() {
    }

    /** Construtor completo — utilizado ao recuperar registros do banco. */
    public Turno(int id, String nome, LocalTime horaEntrada, LocalTime horaSaida,
                 int toleranciaEntrada, int toleranciaSaida, int cargaHorariaDiaria, String status) {
        this.id            = id;
        this.nome               = nome;
        this.horaEntrada        = horaEntrada;
        this.horaSaida          = horaSaida;
        this.toleranciaEntrada   = toleranciaEntrada;
        this.toleranciaSaida    = toleranciaSaida;
        this.cargaHorariaDiaria = cargaHorariaDiaria;
        this.status             = status;
    }

    /** Construtor sem ID — utilizado em INSERT (id gerado pelo banco). */
    public Turno(String nome, LocalTime horaEntrada, LocalTime horaSaida,
                 int toleranciaEntrada, int toleranciaSaida, int cargaHorariaDiaria, String status) {
        this.nome               = nome;
        this.horaEntrada        = horaEntrada;
        this.horaSaida          = horaSaida;
        this.toleranciaEntrada  = toleranciaEntrada;
        this.toleranciaSaida    = toleranciaSaida;
        this.cargaHorariaDiaria = cargaHorariaDiaria;
        this.status             = status;
    }

    // -------------------------
    // Getters e Setters
    // -------------------------

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getNome() {
        return nome;
    }

    public void setNome(String nome) {
        this.nome = nome;
    }

    public LocalTime getHoraEntrada() {
        return horaEntrada;
    }

    public void setHoraEntrada(LocalTime horaEntrada) {
        this.horaEntrada = horaEntrada;
    }

    public LocalTime getHoraSaida() {
        return horaSaida;
    }

    public void setHoraSaida(LocalTime horaSaida) {
        this.horaSaida = horaSaida;
    }

    public int getToleranciaEntrada() {
        return toleranciaEntrada;
    }

    public void setToleranciaEntrada(int toleranciaEntrada) {
        this.toleranciaEntrada = toleranciaEntrada;
    }

    public int getToleranciaSaida() {
        return toleranciaSaida;
    }

    public void setToleranciaSaida(int toleranciaSaida) {
        this.toleranciaSaida = toleranciaSaida;
    }

    public int getCargaHorariaDiaria() {
        return cargaHorariaDiaria;
    }

    public void setCargaHorariaDiaria(int cargaHorariaDiaria) {
        this.cargaHorariaDiaria = cargaHorariaDiaria;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}