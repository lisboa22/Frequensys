package br.com.frequensys.model;

import java.time.LocalDate;

/**
 * Model da entidade Justificativa conforme estrutura da tabela no banco.
 *
 * Colunas: id (PK), idRegistro (FK), tipo, descricao,
 *          dataInicio, dataFim, documentoComprovante, status,
 *          idAprovador (FK → Usuario)
 */
public class Justificativa {

    private int         		id;
    private Funcionario 		Funcionario;
    private RegistroFrequencia  Registro;           
    private String      		tipo;                 // Ex: "ATESTADO", "FALTA", "ATRASO", etc.
    private String      		descricao;
    private LocalDate   		dataInicio;
    private LocalDate   		dataFim;             // Pode ser null
    private String      		documentoComprovante; // Caminho ou nome do arquivo comprovante
    private String      		status;              // Ex: "PENDENTE", "APROVADO", "REPROVADO"
    private Usuario     		Usuario;    // FK → Usuario (pode ser null enquanto pendente)

    // -------------------------
    // Construtores
    // -------------------------

    /** Construtor vazio — necessário para instanciação sem dados (ex: ResultSet). */
    public Justificativa() {
    }

    /** Construtor completo — utilizado ao recuperar registros do banco. */
    public Justificativa(int id, Funcionario Funcionario, RegistroFrequencia Registro, String tipo, String descricao,
                         LocalDate dataInicio, LocalDate dataFim, String documentoComprovante,
                         String status, Usuario Usuario) {
        this.id      = id;
        this.Funcionario		  = Funcionario;
        this.Registro             = Registro;
        this.tipo                 = tipo;
        this.descricao            = descricao;
        this.dataInicio           = dataInicio;
        this.dataFim              = dataFim;
        this.documentoComprovante = documentoComprovante;
        this.status               = status;
        this.Usuario     		  = Usuario;
    }

    /** Construtor sem ID — utilizado em INSERT (id gerado pelo banco). */
    public Justificativa(Funcionario Funcionario, RegistroFrequencia Registro, String tipo, String descricao,
                         LocalDate dataInicio, LocalDate dataFim, String documentoComprovante,
                         String status, Usuario Usuario) {
        this.Funcionario		  = Funcionario;
    	this.Registro           = Registro;
        this.tipo                 = tipo;
        this.descricao            = descricao;
        this.dataInicio           = dataInicio;
        this.dataFim              = dataFim;
        this.documentoComprovante = documentoComprovante;
        this.status               = status;
        this.Usuario    		  = Usuario;
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
    
    public Funcionario getFuncionario() {
        return Funcionario;
    }

    public void setFuncionario(Funcionario Funcionario) {
        this.Funcionario = Funcionario;
    }
    
    public RegistroFrequencia getRegistro() {
        return Registro;
    }

    public void setRegistro(RegistroFrequencia Registro) {
        this.Registro = Registro;
    }

    public String getTipo() {
        return tipo;
    }

    public void setTipo(String tipo) {
        this.tipo = tipo;
    }

    public String getDescricao() {
        return descricao;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
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

    public String getDocumentoComprovante() {
        return documentoComprovante;
    }

    public void setDocumentoComprovante(String documentoComprovante) {
        this.documentoComprovante = documentoComprovante;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Usuario getAprovador() {
        return Usuario;
    }

    public void setAprovador(Usuario Usuario) {
        this.Usuario = Usuario;
    }
}
