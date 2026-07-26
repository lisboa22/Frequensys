package br.com.frequensys.model;

import java.time.LocalDate;

/**
 * Model da entidade FuncionarioTurno conforme estrutura da tabela no banco.
 *
 * Representa a associação entre Funcionario e Turno, com vigência definida
 * por dataInicio e dataFim.
 *
 * Colunas: idFuncionarioTurno (PK), idFuncionario (FK), idTurno (FK),
 *          dataInicio, dataFim
 */
public class FuncionarioTurno {

    private int        idFuncionarioTurno;
    private Funcionario funcionario;       // FK → Funcionario
    private Turno       turno;            // FK → Turno
    private LocalDate   dataInicio;
    private LocalDate   dataFim;          // Pode ser null (vínculo em aberto)

    // -------------------------
    // Construtores
    // -------------------------

    /** Construtor vazio — necessário para instanciação sem dados (ex: ResultSet). */
    public FuncionarioTurno() {
    }

    /** Construtor completo — utilizado ao recuperar registros do banco. */
    public FuncionarioTurno(int idFuncionarioTurno, Funcionario funcionario,
                            Turno turno, LocalDate dataInicio, LocalDate dataFim) {
        this.idFuncionarioTurno = idFuncionarioTurno;
        this.funcionario        = funcionario;
        this.turno              = turno;
        this.dataInicio         = dataInicio;
        this.dataFim            = dataFim;
    }

    /** Construtor sem ID — utilizado em INSERT (id gerado pelo banco). */
    public FuncionarioTurno(Funcionario funcionario, Turno turno,
                            LocalDate dataInicio, LocalDate dataFim) {
        this.funcionario = funcionario;
        this.turno       = turno;
        this.dataInicio  = dataInicio;
        this.dataFim     = dataFim;
    }

    // -------------------------
    // Getters e Setters
    // -------------------------

    public int getId() {
        return idFuncionarioTurno;
    }

    public void setId(int idFuncionarioTurno) {
        this.idFuncionarioTurno = idFuncionarioTurno;
    }

    public Funcionario getFuncionario() {
        return funcionario;
    }

    public void setFuncionario(Funcionario funcionario) {
        this.funcionario = funcionario;
    }

    public Turno getTurno() {
        return turno;
    }

    public void setTurno(Turno turno) {
        this.turno = turno;
    }

    public LocalDate getDataInicio() {
        return dataInicio;
    }

    public void setDataInicio(LocalDate dataInicio) {
        this.dataInicio = dataInicio;
    }

    public LocalDate getDataFim() {
        return dataFim;
    }

    public void setDataFim(LocalDate dataFim) {
        this.dataFim = dataFim;
    }
}

