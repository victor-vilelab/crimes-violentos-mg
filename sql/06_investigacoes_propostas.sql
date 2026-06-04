


-- ============================================================================
-- 2) Ranking de municípios por taxa de crimes por 100 mil habitantes
--    (cruzamento com a população do IBGE).
--
--    A taxa por 100 mil habitantes é instável em municípios muito pequenos.
--    Com uma base populacional baixa, pouquíssimas ocorrências já produzem uma
--    taxa altíssima — que não reflete violência real, e sim ruído estatístico.
--    Exemplo observado usando o corte > 0:
--
--        MATHIAS LOBATO          população 3.053   8 ocorrências  ->  262,04 / 100 mil
--        SAO GERALDO DA PIEDADE  população 3.200   8 ocorrências  ->  250,00 / 100 mil
--    Esses municípios sobem para o TOP 5-6 do estado apenas por terem
--    população minúscula: as MESMAS 8 ocorrências numa cidade grande seriam irrelevantes.

--    Por isso mantemos DUAS versões da consulta:
--      A) Versão ingênua (> 0)        -> inclui todos os 853 municípios e fica
--         dominada por cidadezinhas; serve para EXPOR o problema.
--      B) Versão robusta (> 100.000)  -> compara apenas cidades grandes (36 dos
--         853 municípios), onde a taxa por 100 mil é confiável.
--
-- VEREDITO:
--    O ranking final adotado é a VERSÃO B. O corte de 100 mil habitantes é uma
--    escolha consciente: troca a cobertura (só ~4% dos municípios) pela
--    estabilidade estatística da taxa, evitando que o resultado seja distorcido
--    por municípios onde poucos casos inflam o indicador. A versão A é mantida
--    apenas para demonstrar, na apresentação, por que esse piso é necessário.
-- ============================================================================

-- A) Versão INGÊNUA (> 0) — NÃO é o resultado final.
--    Top dominado por municípios minúsculos (problema dos números pequenos).
SELECT
    m.nome, ri.nome_sede AS risp, m.populacao,
    SUM(r.quantidade) AS total_ocorrencias,
    ROUND(SUM(r.quantidade) * 100000.0 / m.populacao, 2) AS taxa_por_100mil
FROM municipio m
JOIN registro  r  ON r.cod_municipio = m.cod_ibge
JOIN risp      ri ON ri.cod_risp     = m.cod_risp
WHERE m.populacao IS NOT NULL
  AND m.populacao > 0
GROUP BY m.cod_ibge, m.nome, ri.nome_sede, m.populacao
ORDER BY taxa_por_100mil DESC
LIMIT 10;

-- B) Versão ROBUSTA (> 100.000 hab) — RANKING FINAL.
--    Apenas cidades grandes (36 municípios), onde a taxa é estatisticamente
--    confiável. É esta a consulta que sustenta a análise.
SELECT
    m.nome, ri.nome_sede AS risp, m.populacao,
    SUM(r.quantidade) AS total_ocorrencias,
    ROUND(SUM(r.quantidade) * 100000.0 / m.populacao, 2) AS taxa_por_100mil
FROM municipio m
JOIN registro  r  ON r.cod_municipio = m.cod_ibge
JOIN risp      ri ON ri.cod_risp     = m.cod_risp
WHERE m.populacao IS NOT NULL
  AND m.populacao > 100000
GROUP BY m.cod_ibge, m.nome, ri.nome_sede, m.populacao
ORDER BY taxa_por_100mil DESC
LIMIT 10;

-- Série mensal completa (2025 + jan-mar/2026) em ordem cronológica, útil para um gráfico de linha da evolução das ocorrências.
SELECT
    p.ano,
    p.mes,
    SUM(r.quantidade) AS total_ocorrencias
FROM registro r
JOIN periodo  p ON p.id_periodo = r.id_periodo
GROUP BY p.ano, p.mes
ORDER BY p.ano, p.mes;
