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
