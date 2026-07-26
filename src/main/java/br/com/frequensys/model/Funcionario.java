package br.com.frequensys.model;

import java.time.LocalDate;

/**
 * Model da entidade Funcionario conforme estrutura da tabela no banco.
 *
 * Colunas: id (PK), nome, cpf, matricula, email,
 *          telefone, dataAdmissao, status, idSetor (FK → Setor)
 */
public class Funcionario {

    private int       id;
    private String    nome;
    private String    cpf;
    private String    matricula;
    private String    email;
    private String    telefone;
    private LocalDate dataAdmissao;
    private String    status;       // Ex: "ATIVO" | "INATIVO"
    private Setor     setor;        // FK → Setor
    private String    token;

    // -------------------------
    // Construtores
    // -------------------------

    /** Construtor vazio — necessário para instanciação sem dados (ex: ResultSet). */
    public Funcionario() {
    }

    /** Construtor completo — utilizado ao recuperar registros do banco. */
    public Funcionario(int id, String nome, String cpf, String matricula,
                       String email, String telefone, LocalDate dataAdmissao,
                       String status, Setor setor, String token) {
        this.id = id;
        this.nome          = nome;
        this.cpf           = cpf;
        this.matricula     = matricula;
        this.email         = email;
        this.telefone      = telefone;
        this.dataAdmissao  = dataAdmissao;
        this.status        = status;
        this.setor         = setor;
        this.token		   = token;
    }

    /** Construtor sem ID — utilizado em INSERT (id gerado pelo banco). */
    public Funcionario(String nome, String cpf, String matricula, String email,
                       String telefone, LocalDate dataAdmissao, String status, Setor setor, String token) {
        this.nome         = nome;
        this.cpf          = cpf;
        this.matricula    = matricula;
        this.email        = email;
        this.telefone     = telefone;
        this.dataAdmissao = dataAdmissao;
        this.status       = status;
        this.setor        = setor;
        this.token		  = token;
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

    public String getCpf() {
        return cpf;
    }

    public void setCpf(String cpf) {
        this.cpf = cpf;
    }

    public String getMatricula() {
        return matricula;
    }

    public void setMatricula(String matricula) {
        this.matricula = matricula;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getTelefone() {
        return telefone;
    }

    public void setTelefone(String telefone) {
        this.telefone = telefone;
    }

    public LocalDate getDataAdmissao() {
        return dataAdmissao;
    }

    public void setDataAdmissao(LocalDate dataAdmissao) {
        this.dataAdmissao = dataAdmissao;
    }

    /**
     * Retorna a data de admissão já formatada como String (dd/MM/yyyy),
     * pronta para exibição em JSP. Usar este getter em vez de
     * &lt;fmt:formatDate&gt;, pois a tag do JSTL não suporta java.time.LocalDate.
     *
     * @return data formatada, ou "—" caso não haja data de admissão
     */
    public String getDataAdmissaoFormatada() {
        return dataAdmissao != null
            ? dataAdmissao.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"))
            : "—";
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Setor getSetor() {
        return setor;
    }

    public void setSetor(Setor setor) {
        this.setor = setor;
    }
    
    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }
}