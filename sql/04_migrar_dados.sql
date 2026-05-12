-- Vamos inserir os dados nas respectiva tabela
INSERT INTO risp (cod_risp, nome_sede)
SELECT DISTINCT
    CAST(SPLIT_PART(risp, ' ', 2) AS INTEGER) AS cod_risp,
    SPLIT_PART(risp, ' - ', 2) AS nome_sede
FROM crimes_raw
ORDER BY cod_risp;

-- retornar 19
SELECT COUNT(*) AS qtd_risps FROM risp;


INSERT INTO municipio (cod_ibge, nome, pertence_rmbh, cod_risp)
SELECT DISTINCT
    cod_municipio AS cod_ibge,
    municipio AS nome,
    CASE WHEN rmbh = 'SIM' THEN TRUE ELSE FALSE END AS pertence_rmbh,
    CAST(SPLIT_PART(risp, ' ', 2) AS INTEGER) AS cod_risp
FROM crimes_raw
ORDER BY cod_ibge;

-- Retorna 853
SELECT COUNT(*) AS qtd_municipios FROM municipio;

INSERT INTO natureza (descricao, consumado)
SELECT DISTINCT
    natureza AS descricao,
    CASE WHEN natureza LIKE '%CONSUMADO' THEN TRUE ELSE FALSE END AS consumado
FROM crimes_raw
ORDER BY natureza;

-- retornar 15
SELECT COUNT(*) AS qtd_naturezas FROM natureza;

SELECT DISTINCT descricao FROM natureza;

INSERT INTO periodo (mes, ano, trimestre)
SELECT DISTINCT
    mes,
    ano,
    ((mes - 1) / 3) + 1 AS trimestre
FROM crimes_raw
ORDER BY ano, mes;

-- Retornar 15 (12 de 2025 + 3 de 2026)
SELECT COUNT(*) AS qtd_periodos FROM periodo;


INSERT INTO registro (cod_municipio, cod_natureza, id_periodo, quantidade)
SELECT
    cr.cod_municipio,
    n.cod_natureza,
    p.id_periodo,
    cr.registros AS quantidade
FROM crimes_raw cr
JOIN natureza n ON n.descricao = cr.natureza
JOIN periodo  p ON p.mes = cr.mes AND p.ano = cr.ano;

-- Retorna 191925
SELECT COUNT(*) AS qtd_registros FROM registro;

-- retorna 31620
SELECT SUM(quantidade) AS total_ocorrencias FROM registro;

