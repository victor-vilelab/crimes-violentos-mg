-- Vamos preencher as categorias da tabela da natureza.
UPDATE natureza SET categoria = CASE
    WHEN descricao LIKE '%HOMICIDIO%' THEN 'Crimes contra a vida'
    WHEN descricao LIKE '%FEMINICIDIO%' THEN 'Crimes contra a vida'
    WHEN descricao LIKE '%LESAO CORPORAL SEGUIDA%' THEN 'Crimes contra a vida'
    WHEN descricao LIKE '%ESTUPRO%' THEN 'Crimes contra a dignidade sexual'
    WHEN descricao LIKE '%ROUBO%' THEN 'Crimes contra o patrimônio'
    WHEN descricao LIKE '%EXTORSAO%' THEN 'Crimes contra o patrimônio'
    WHEN descricao LIKE '%SEQUESTRO%' THEN 'Crimes contra a liberdade pessoal'
    WHEN descricao LIKE '%CARCERE%' THEN 'Crimes contra a liberdade pessoal'
END;

-- Retorna 5 crimes contra patrimônio, 3 contra diginidade, 4 contra a vida, 2 contra a liberdade
SELECT categoria, COUNT(*) AS qtd_naturezas
FROM natureza
GROUP BY categoria
ORDER BY qtd_naturezas DESC;


-- Tem que mostrar as 4 categorias que criamos
SELECT DISTINCT categoria
FROM natureza;



-- 1) Tabela de carga (staging) com as MESMAS colunas do CSV
DROP TABLE IF EXISTS stg_populacao;
CREATE TABLE stg_populacao (
    cod_ibge             INTEGER,
    nome                 VARCHAR(100),
    populacao            INTEGER,
    populacao_censo_2022 INTEGER
);

-- 2) Importar o CSV para stg_populacao.
--    No pgAdmin: clique direito na tabela stg_populacao > "Import/Export Data...",
--    escolha o arquivo municipios_mg_populacao_limpo.csv, Header = Yes, Delimiter = ','.
--
--    Alternativa por SQL (o servidor PostgreSQL precisa conseguir ler o arquivo):
-- COPY stg_populacao FROM '/caminho/para/municipios_mg_populacao_limpo.csv'
--      WITH (FORMAT csv, HEADER true);

-- 3) Atualizar a tabela municipio com a população.
--    ATENÇÃO: o CSV usa o código IBGE de 7 dígitos (com dígito verificador, ex: 3100104)
--    e a tabela municipio usa o de 6 dígitos (ex: 310010). Dividir por 10 remove
--    o último dígito e faz os dois baterem.

UPDATE municipio m
SET populacao = s.populacao
FROM stg_populacao s
WHERE s.cod_ibge / 10 = m.cod_ibge;

-- 0 municípios sem população
SELECT COUNT(*) AS municipios_sem_populacao
FROM municipio
WHERE populacao IS NULL;

