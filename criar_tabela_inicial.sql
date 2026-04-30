CREATE TABLE IF NOT EXISTS crimes_raw (
	id SERIAL PRIMARY KEY,
	registros INTEGER,
	natureza VARCHAR(100),
	municipio VARCHAR(100),
	cod_municipio INTEGER,
	mes INTEGER,
	ano INTEGER,
	risp VARCHAR(100),
	rmbh VARCHAR(10)
);

-- Verificando se tem dados no banco de dados
SELECT * FROM crimes_raw;

-- verificando se subiu o ano de 2025 e de 2026
SELECT ano, count(*) AS linhas
FROM crimes_raw
GROUP BY ano
ORDER BY ano;


-- Quantas naturezas únicas existem?
SELECT DISTINCT natureza FROM crimes_raw ORDER BY natureza;


-- Quantas RISPs únicas existem?
SELECT DISTINCT risp FROM crimes_raw ORDER BY risp;


-- Cada município pertence a UMA risp só? (validar relação N:1)
SELECT municipio, COUNT(DISTINCT risp) AS qtd_risps
FROM crimes_raw
GROUP BY municipio
HAVING COUNT(DISTINCT risp) > 1;

-- Cada município tem só um valor de RMBH?
SELECT municipio, COUNT(DISTINCT rmbh) AS qtd_rmbh
FROM crimes_raw
GROUP BY municipio
HAVING COUNT(DISTINCT rmbh) > 1;


-- Quantos municípios únicos?
SELECT COUNT(DISTINCT cod_municipio) AS qtd_municipios FROM crimes_raw;


-- Normalização dos dados
--Qual a chave primária?

--Opção 1: usar o número da RISP (1, 2, 3, ..., 19) como cod_risp INTEGER PRIMARY KEY
--Opção 2: usar id SERIAL PRIMARY KEY (chave artificial)
--Opção 3: usar o nome inteiro como PK (texto)
--Qual você escolheria? Por quê?
--Que colunas a tabela deve ter?

--O CSV traz só o texto completo "RISP 10 - PATOS DE MINAS". Você vai:
--(a) guardar tudo numa coluna nome só?
--(b) separar em numero (10) e nome_sede ("PATOS DE MINAS")?
--Qual faz mais sentido pra você?
--Tipos de dados:

--VARCHAR(100) ou TEXT?
--O número da RISP cabe em SMALLINT (1-19) — vale a pena economizar?
--Restrições (constraints):

--O nome pode ser nulo? Pode ser duplicado?
--Já temos PRIMARY KEY. Falta NOT NULL em algum campo? UNIQUE?



CREATE TABLE risp (
	cod_risp INTEGER PRIMARY KEY,
	nome_sede VARCHAR(100) UNIQUE NOT NULL
);