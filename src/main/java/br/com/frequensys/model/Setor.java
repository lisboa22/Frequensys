package br.com.frequensys.model;

/**
 * Model da entidade Setor conforme estrutura da tabela no banco.
 *
 * Colunas: id (PK), nome, descricao
 */
public class Setor {

    private int    id;
    private String nome;
    private String descricao;

    // -------------------------
    // Construtores
    // -------------------------

    /** Construtor vazio — necessário para instanciação sem dados (ex: ResultSet). */
    public Setor() {
    }

    /** Construtor completo — utilizado ao recuperar registros do banco. */
    public Setor(int id, String nome, String descricao) {
        this.id   = id;
        this.nome      = nome;
        this.descricao = descricao;
    }

    /** Construtor sem ID — utilizado em INSERT (id gerado pelo banco). */
    public Setor(String nome, String descricao) {
        this.nome      = nome;
        this.descricao = descricao;
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

    public String getDescricao() {
        return descricao;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }
}

