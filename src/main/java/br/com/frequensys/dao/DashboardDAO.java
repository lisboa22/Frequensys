package br.com.frequensys.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * DAO responsável por fornecer todos os dados analíticos do Dashboard.
 *
 * Cada método executa uma query específica e retorna os dados
 * necessários para popular os cards, gráficos e tabelas do painel.
 *
 * Estrutura das queries:
 * - KPIs gerais (totais e contagens)
 * - Registros de hoje
 * - Justificativas pendentes
 * - Ranking de assiduidade do mês
 * - Alertas de baixa frequência
 * - Registros por dia (últimos 7 dias) para gráfico
 * - Distribuição de ocorrências por tipo
 */
public class DashboardDAO {

    private Connection conexao;

    public DashboardDAO(Connection conexao) {
        this.conexao = conexao;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // KPIs — CARDS SUPERIORES
    // ─────────────────────────────────────────────────────────────────────────

    /** Total de funcionários ATIVOS no sistema. */
    public int totalFuncionariosAtivos() throws Exception {
        String sql = "SELECT COUNT(*) FROM funcionario WHERE status = 'ATIVO'";
        try (PreparedStatement stmt = conexao.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    /** Quantos funcionários registraram ENTRADA hoje. */
    public int presencasHoje() throws Exception {
        String sql = "SELECT COUNT(DISTINCT idFuncionario) "
                   + "FROM registrofrequencia "
                   + "WHERE tipo = 'ENTRADA' AND DATE(datahora) = CURDATE()";
        try (PreparedStatement stmt = conexao.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    /** Quantos funcionários NÃO registraram ENTRADA hoje (ausentes). */
    public int ausentesHoje() throws Exception {
        int ativos   = totalFuncionariosAtivos();
        int presentes = presencasHoje();
        return Math.max(0, ativos - presentes);
    }

    /** Total de justificativas com status PENDENTE. */
    public int justificativasPendentes() throws Exception {
        String sql = "SELECT COUNT(*) FROM justificativa WHERE status = 'PENDENTE'";
        try (PreparedStatement stmt = conexao.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    /** Quantidade de registros com atraso (minutosatraso > 0) no mês atual. */
    public int atrasosNoMes() throws Exception {
        String sql = "SELECT COUNT(*) FROM registrofrequencia "
                   + "WHERE minutosatraso > 0 "
                   + "  AND MONTH(datahora) = MONTH(CURDATE()) "
                   + "  AND YEAR(datahora)  = YEAR(CURDATE())";
        try (PreparedStatement stmt = conexao.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    /**
     * Percentual médio de presença dos funcionários ativos no mês atual.
     * Calcula: (dias com ENTRADA / dias úteis no mês até hoje) * 100
     */
    public double percentualPresencaMes() throws Exception {
        // Subquery isola o COUNT(DISTINCT ...) sobre datahora sem GROUP BY,
        // evitando rejeição pelo sql_mode=only_full_group_by do MySQL.
        String sql = "SELECT ROUND( "
                   + "    sub.presencas * 100.0 "
                   + "    / NULLIF( "
                   + "        (SELECT COUNT(DISTINCT f.id) FROM funcionario f WHERE f.status = 'ATIVO') "
                   + "        * (DATEDIFF(CURDATE(), DATE_FORMAT(CURDATE(), '%Y-%m-01')) + 1) "
                   + "      , 0) "
                   + "  , 1) AS percentual "
                   + "FROM ( "
                   + "  SELECT COUNT(DISTINCT CONCAT(idFuncionario, '-', DATE(datahora))) AS presencas "
                   + "  FROM registrofrequencia "
                   + "  WHERE tipo = 'ENTRADA' "
                   + "    AND MONTH(datahora) = MONTH(CURDATE()) "
                   + "    AND YEAR(datahora)  = YEAR(CURDATE()) "
                   + ") sub";
        try (PreparedStatement stmt = conexao.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                double v = rs.getDouble("percentual");
                return rs.wasNull() ? 0.0 : Math.min(v, 100.0);
            }
            return 0.0;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // REGISTROS DE HOJE — TABELA "ÚLTIMAS MARCAÇÕES"
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Retorna as últimas 10 marcações do dia (ENTRADA ou SAÍDA),
     * com nome do funcionário, tipo e status.
     * Cada linha: [nome, matricula, tipo, status, hora]
     */
    public List<Map<String, String>> ultimasMarcacoesHoje() throws Exception {
        List<Map<String, String>> lista = new ArrayList<>();
        String sql = "SELECT f.nome, f.matricula, r.tipo, r.status, "
                   + "       DATE_FORMAT(r.datahora, '%H:%i') AS hora "
                   + "FROM registrofrequencia r "
                   + "JOIN funcionario f ON f.id = r.idFuncionario "
                   + "WHERE DATE(r.datahora) = CURDATE() "
                   + "ORDER BY r.datahora DESC "
                   + "LIMIT 10";
        try (PreparedStatement stmt = conexao.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, String> row = new LinkedHashMap<>();
                row.put("nome",      rs.getString("nome"));
                row.put("matricula", rs.getString("matricula"));
                row.put("tipo",      rs.getString("tipo"));
                row.put("status",    rs.getString("status"));
                row.put("hora",      rs.getString("hora"));
                lista.add(row);
            }
        }
        return lista;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // JUSTIFICATIVAS PENDENTES — TABELA
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Retorna as 8 justificativas mais recentes com status PENDENTE.
     * Cada linha: [id, nomeFuncionario, tipo, dataInicio]
     */
    public List<Map<String, String>> justificativasPendentesRecentes() throws Exception {
        List<Map<String, String>> lista = new ArrayList<>();
        String sql = "SELECT j.id, f.nome AS nomeFuncionario, j.tipo, "
                   + "       DATE_FORMAT(j.dataInicio, '%d/%m/%Y') AS dataInicio "
                   + "FROM justificativa j "
                   + "JOIN funcionario f ON f.id = j.idFuncionario "
                   + "WHERE j.status = 'PENDENTE' "
                   + "ORDER BY j.id DESC "
                   + "LIMIT 8";
        try (PreparedStatement stmt = conexao.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, String> row = new LinkedHashMap<>();
                row.put("id",              String.valueOf(rs.getInt("id")));
                row.put("nomeFuncionario", rs.getString("nomeFuncionario"));
                row.put("tipo",            rs.getString("tipo"));
                row.put("dataInicio",      rs.getString("dataInicio"));
                lista.add(row);
            }
        }
        return lista;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // RANKING DE ASSIDUIDADE — TOP 5 DO MÊS
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Top 5 funcionários com maior percentual de presença no mês atual.
     * Considera apenas funcionários ATIVOS e dias com registro de ENTRADA.
     * Cada linha: [nome, matricula, nomeSetor, percentual]
     */
    public List<Map<String, Object>> rankingAssiduidade() throws Exception {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "SELECT f.nome, f.matricula, s.nome AS nomeSetor, "
                   + "       ROUND( "
                   + "         COUNT(DISTINCT DATE(r.datahora)) * 100.0 "
                   + "         / NULLIF(DATEDIFF(CURDATE(), DATE_FORMAT(CURDATE(),'%Y-%m-01')) + 1, 0) "
                   + "       , 1) AS percentual "
                   + "FROM funcionario f "
                   + "JOIN setor s ON s.id = f.idSetor "
                   + "LEFT JOIN registrofrequencia r "
                   + "       ON r.idFuncionario = f.id "
                   + "      AND r.tipo = 'ENTRADA' "
                   + "      AND MONTH(r.datahora) = MONTH(CURDATE()) "
                   + "      AND YEAR(r.datahora)  = YEAR(CURDATE()) "
                   + "WHERE f.status = 'ATIVO' "
                   + "GROUP BY f.id, f.nome, f.matricula, s.nome "
                   + "ORDER BY percentual DESC "
                   + "LIMIT 5";
        try (PreparedStatement stmt = conexao.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("nome",       rs.getString("nome"));
                row.put("matricula",  rs.getString("matricula"));
                row.put("nomeSetor",  rs.getString("nomeSetor"));
                row.put("percentual", rs.getDouble("percentual"));
                lista.add(row);
            }
        }
        return lista;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ALERTAS DE BAIXA FREQUÊNCIA
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Funcionários ATIVOS com percentual de presença abaixo de 75% no mês.
     * Cada linha: [nome, matricula, nomeSetor, percentual]
     */
    public List<Map<String, Object>> alertasBaixaFrequencia() throws Exception {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "SELECT f.nome, f.matricula, s.nome AS nomeSetor, "
                   + "       ROUND( "
                   + "         COUNT(DISTINCT DATE(r.datahora)) * 100.0 "
                   + "         / NULLIF(DATEDIFF(CURDATE(), DATE_FORMAT(CURDATE(),'%Y-%m-01')) + 1, 0) "
                   + "       , 1) AS percentual "
                   + "FROM funcionario f "
                   + "JOIN setor s ON s.id = f.idSetor "
                   + "LEFT JOIN registrofrequencia r "
                   + "       ON r.idFuncionario = f.id "
                   + "      AND r.tipo = 'ENTRADA' "
                   + "      AND MONTH(r.datahora) = MONTH(CURDATE()) "
                   + "      AND YEAR(r.datahora)  = YEAR(CURDATE()) "
                   + "WHERE f.status = 'ATIVO' "
                   + "GROUP BY f.id, f.nome, f.matricula, s.nome "
                   + "HAVING percentual < 75 "
                   + "ORDER BY percentual ASC "
                   + "LIMIT 6";
        try (PreparedStatement stmt = conexao.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("nome",       rs.getString("nome"));
                row.put("matricula",  rs.getString("matricula"));
                row.put("nomeSetor",  rs.getString("nomeSetor"));
                row.put("percentual", rs.getDouble("percentual"));
                lista.add(row);
            }
        }
        return lista;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // GRÁFICO — REGISTROS POR DIA (ÚLTIMOS 7 DIAS)
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Retorna a contagem de ENTRADAs por dia nos últimos 7 dias.
     * Usado para o gráfico de barras/linha.
     * Retorna LinkedHashMap para garantir ordem cronológica.
     * Chave: "DD/MM", Valor: quantidade
     */
    public Map<String, Integer> registrosPorDia() throws Exception {
        Map<String, Integer> dados = new LinkedHashMap<>();
        // GROUP BY inclui DATE(datahora) e sua projeção formatada para satisfazer
        // o only_full_group_by; ORDER BY em DATE() garante ordem cronológica correta.
        String sql = "SELECT DATE_FORMAT(DATE(datahora), '%d/%m') AS dia, "
                   + "       COUNT(DISTINCT idFuncionario)         AS qtd "
                   + "FROM registrofrequencia "
                   + "WHERE tipo = 'ENTRADA' "
                   + "  AND datahora >= DATE_SUB(CURDATE(), INTERVAL 6 DAY) "
                   + "GROUP BY DATE(datahora), DATE_FORMAT(DATE(datahora), '%d/%m') "
                   + "ORDER BY DATE(datahora) ASC";
        try (PreparedStatement stmt = conexao.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                dados.put(rs.getString("dia"), rs.getInt("qtd"));
            }
        }
        return dados;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // GRÁFICO — OCORRÊNCIAS POR TIPO NO MÊS
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Distribuição de registros por tipo (ENTRADA, SAÍDA) e status no mês.
     * Retorna: [tipo/status -> contagem]
     */
    public Map<String, Integer> ocorrenciasPorTipo() throws Exception {
        Map<String, Integer> dados = new LinkedHashMap<>();
        String sql = "SELECT status, COUNT(*) AS qtd "
                   + "FROM registrofrequencia "
                   + "WHERE MONTH(datahora) = MONTH(CURDATE()) "
                   + "  AND YEAR(datahora)  = YEAR(CURDATE()) "
                   + "  AND tipo = 'ENTRADA' "
                   + "GROUP BY status "
                   + "ORDER BY qtd DESC";
        try (PreparedStatement stmt = conexao.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                dados.put(rs.getString("status"), rs.getInt("qtd"));
            }
        }
        return dados;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // PRESENÇA POR SETOR NO MÊS
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Percentual médio de presença agrupado por setor no mês atual.
     * Usado para o gráfico de barras horizontais por setor.
     * Cada linha: [nomeSetor, percentual]
     */
    public List<Map<String, Object>> presencaPorSetor() throws Exception {
        List<Map<String, Object>> lista = new ArrayList<>();
        String sql = "SELECT s.nome AS nomeSetor, "
                   + "       ROUND( "
                   + "         COUNT(DISTINCT CONCAT(r.idFuncionario, '-', DATE(r.datahora))) * 100.0 "
                   + "         / NULLIF( "
                   + "             COUNT(DISTINCT f.id) "
                   + "             * (DATEDIFF(CURDATE(), DATE_FORMAT(CURDATE(),'%Y-%m-01')) + 1) "
                   + "           , 0) "
                   + "       , 1) AS percentual "
                   + "FROM setor s "
                   + "JOIN funcionario f ON f.idSetor = s.id AND f.status = 'ATIVO' "
                   + "LEFT JOIN registrofrequencia r "
                   + "       ON r.idFuncionario = f.id "
                   + "      AND r.tipo = 'ENTRADA' "
                   + "      AND MONTH(r.datahora) = MONTH(CURDATE()) "
                   + "      AND YEAR(r.datahora)  = YEAR(CURDATE()) "
                   + "GROUP BY s.id, s.nome "
                   + "ORDER BY percentual DESC";
        try (PreparedStatement stmt = conexao.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("nomeSetor",  rs.getString("nomeSetor"));
                row.put("percentual", rs.getDouble("percentual"));
                lista.add(row);
            }
        }
        return lista;
    }
}