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


-- Quais são as naturezas de crime distintas registradas?

SELECT DISTINCT natureza FROM crimes_raw ORDER BY natureza;

-- Listar apenas os nomes dos municípios e as naturezas dos crimes que ocorreram na RMBH

SELECT DISTINCT municipio, natureza FROM crimes_raw WHERE rmbh = 'SIM' AND ano = 2025 AND registros > 0;

-- Listar apenas os municipios que tiveram resgistro em dezembro de 2025

SELECT DISTINCT municipio FROM crimes_raw WHERE ano = 2025 AND mes = 12 AND registros > 0;

-- Descobrir quais municípios registraram crimes no mês 1 de 2025 ou mẽs 1 de 2026 

SELECT DISTINCT municipio, mes, ano FROM crimes_raw WHERE mes = 1 AND ano IN (2025, 2026) AND registros > 0;

-- Descobrir quais municípios não registraram crimes no mês 12 de 2025

SELECT DISTINCT municipio FROM crimes_raw 
EXCEPT
SELECT DISTINCT municipio FROM crimes_raw 
WHERE ano = 2025 and mes = 12 AND registros > 0;

