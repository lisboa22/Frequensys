package br.com.frequensys.model;

public class Perfil {
	
	/**
     * Identificador único do perfil.
     */
    private int id;

    /**
     * Nome do perfil.
     * Representa o tipo de acesso do usuário.
     */
    private String nome;

    /**
     * Construtor vazio.
     * Necessário para frameworks e mecanismos de reflexão.
     */
    public Perfil() {
    }

    /**
     * Construtor completo.
     * Utilizado ao reconstruir o objeto vindo do banco (SELECT).
     */
    public Perfil(int id, String nome) {
        this.id = id;
        this.nome = nome;
    }

    /**
     * Construtor para inserção.
     */
    public Perfil(String nome) {
        this.nome = nome;
    }

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

}
