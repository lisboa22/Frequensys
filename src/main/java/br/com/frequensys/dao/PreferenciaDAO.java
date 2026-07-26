package br.com.frequensys.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import br.com.frequensys.model.Preferencia;

/**
 * DAO responsável pela persistência da entidade Preferencia.
 *
 * Diferente das demais entidades do sistema, Preferencia representa uma
 * configuração única e global (os parâmetros gerais de frequência/ponto),
 * portanto a tabela "preferencia" deve conter apenas um registro.
 *
 * Responsabilidades:
 * - Inserir a configuração inicial (primeira vez que o sistema é configurado).
 * - Buscar a configuração atual.
 * - Atualizar a configuração existente.
 */
public class PreferenciaDAO {

    private Connection conexao;

    public PreferenciaDAO(Connection conexao) {
        this.conexao = conexao;
    }

    // ==========================================
    // INSERT
    // ==========================================
    public void adicionarPreferencia(Preferencia preferencia) throws Exception {

        String sql = "INSERT INTO preferencia (tolerancia_entrada, tolerancia_saida, intervalo, modo_escuro) VALUES (?, ?, ?, ?)";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setInt(1, preferencia.getToleranciaEntrada());
        stmt.setInt(2, preferencia.getToleranciaSaida());
        stmt.setInt(3, preferencia.getIntervalo());
        stmt.setBoolean(4, preferencia.getModoEscuro());

        stmt.executeUpdate();
        stmt.close();
    }

    // ==========================================
    // SELECT (configuração única do sistema)
    // ==========================================
    public Preferencia buscarPreferencia() throws Exception {

        Preferencia preferencia = null;

        String sql = "SELECT * FROM preferencia LIMIT 1";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        ResultSet rs = stmt.executeQuery();

        if (rs.next()) {
            preferencia = new Preferencia(
                rs.getInt("tolerancia_entrada"),
                rs.getInt("tolerancia_saida"),
                rs.getInt("intervalo"),
                rs.getBoolean("modo_escuro")
            );
        }

        rs.close();
        stmt.close();

        return preferencia;
    }

    // ==========================================
    // UPDATE
    // ==========================================
    public void alterarPreferencia(Preferencia preferencia) throws Exception {

        // Como só existe um registro de configuração, o UPDATE atinge
        // diretamente a única linha da tabela (sem cláusula WHERE por id).
        String sql = "UPDATE preferencia SET tolerancia_entrada = ?, tolerancia_saida = ?, intervalo = ?, modo_escuro = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);

        stmt.setInt(1, preferencia.getToleranciaEntrada());
        stmt.setInt(2, preferencia.getToleranciaSaida());
        stmt.setInt(3, preferencia.getIntervalo());
        stmt.setBoolean(4, preferencia.getModoEscuro());

        stmt.executeUpdate();
        stmt.close();
    }

    // ==========================================
    // UPDATE (somente o campo modo_escuro)
    // ==========================================
    public void alterarModoEscuro(boolean modoEscuro) throws Exception {

        // Se ainda não existe configuração salva, cria o registro com
        // valores padrão para os demais campos, já com o tema escolhido.
        if (buscarPreferencia() == null) {
            adicionarPreferencia(new Preferencia(15, 10, 60, modoEscuro));
            return;
        }

        String sql = "UPDATE preferencia SET modo_escuro = ?";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.setBoolean(1, modoEscuro);

        stmt.executeUpdate();
        stmt.close();
    }

    // ==========================================
    // DELETE
    // ==========================================
    public void excluirPreferencia() throws Exception {

        String sql = "DELETE FROM preferencia";

        PreparedStatement stmt = conexao.prepareStatement(sql);
        stmt.executeUpdate();
        stmt.close();
    }

    // ==========================================
    // SALVAR (insere se ainda não existir configuração, senão atualiza)
    // ==========================================
    public void salvarPreferencia(Preferencia preferencia) throws Exception {

        if (buscarPreferencia() == null) {
            adicionarPreferencia(preferencia);
        } else {
            alterarPreferencia(preferencia);
        }
    }
}
