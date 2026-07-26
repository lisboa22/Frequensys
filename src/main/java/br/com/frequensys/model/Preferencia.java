package br.com.frequensys.model;

public class Preferencia {
	
	private int toleranciaEntrada;
	private int toleranciaSaida;
	private int intervalo;
	private boolean modoEscuro;
	
	// -------------------------
    // Construtores
    // -------------------------

    /** Construtor vazio — necessário para instanciação sem dados (ex: ResultSet). */
    public Preferencia() {
    } 

    /** Construtor completo — utilizado ao recuperar registros do banco. */
    public Preferencia(int toleranciaEntrada, int toleranciaSaida, int intervalo, boolean modoEscuro) {
    	this.toleranciaEntrada = toleranciaEntrada;
    	this.toleranciaSaida = toleranciaSaida;
    	this.intervalo = intervalo;
    	this.modoEscuro = modoEscuro;
    } 
    
    // -------------------------
    // Getters e Setters
    // -------------------------

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
    
    public int getIntervalo() {
        return intervalo;
    }

    public void setIntervalo(int intervalo) {
        this.intervalo = intervalo;
    }
    
    public boolean getModoEscuro() {
        return modoEscuro;
    }

    public void setModoEscuro(boolean modoEscuro) {
        this.modoEscuro = modoEscuro;
    }
    
}
