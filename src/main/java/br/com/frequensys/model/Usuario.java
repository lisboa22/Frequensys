package br.com.frequensys.model;

/**
 * Model simplificado da entidade Usuario conforme estrutura da tabela no banco.
 */
public class Usuario {

    private int id;
    private String nome;
    private String login;
    private String email;
    private String status; // Pode virar ENUM Java depois
    private Perfil Perfil;
    private String senha;

    // Construtor vazio
    public Usuario() {
    }

    // Construtor completo
    public Usuario(int id, String nome, String login, String email, String status, Perfil Perfil, String senha) {
        this.id = id;
        this.nome = nome;
        this.login = login;
        this.email = email;
        this.status = status;
        this.Perfil = Perfil;
        this.senha = senha;
    }

    // Construtor sem ID (para INSERT)
    public Usuario(String nome, String login, String email, String status, Perfil Perfil, String senha) {
        this.nome = nome;
        this.login = login;
        this.email = email;
        this.status = status;
        this.Perfil = Perfil;
        this.senha = senha;
    }

    // Getters e Setters

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

    public String getLogin() {
        return login;
    }

    public void setLogin(String login) {
        this.login = login;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
    
    public Perfil getPerfil() {
        return Perfil;
    }

    public void setPerfil(Perfil Perfil) {
        this.Perfil = Perfil;
    }
    
    public String getSenha() {
        return senha;
    }

    public void setSenha(String senha) {
        this.senha = senha;
    }
}
