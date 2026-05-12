
-- Vamos tirar os dados que estão brutos nessa tabela e separar cada uma na sua respectiva tabela
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

-- Crie cada uma das tabelas abaixo
CREATE TABLE IF NOT EXISTS risp (
    cod_risp  INTEGER PRIMARY KEY,
    nome_sede VARCHAR(100) UNIQUE NOT NULL
);



CREATE TABLE IF NOT EXISTS municipio (
    cod_ibge INTEGER  PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    pertence_rmbh BOOLEAN  NOT NULL,
    populacao INTEGER,                         
    cod_risp INTEGER NOT NULL REFERENCES risp(cod_risp)
);


CREATE TABLE IF NOT EXISTS natureza (
    cod_natureza  SERIAL PRIMARY KEY,
    descricao VARCHAR(100) UNIQUE NOT NULL,
    categoria VARCHAR(50),                         
    consumado BOOLEAN        
);


CREATE TABLE IF NOT EXISTS periodo (
    id_periodo SERIAL    PRIMARY KEY,
    mes  SMALLINT  NOT NULL CHECK (mes BETWEEN 1 AND 12),
    ano  SMALLINT  NOT NULL,
    trimestre  SMALLINT  NOT NULL CHECK (trimestre BETWEEN 1 AND 4),
    UNIQUE (mes, ano)
);

CREATE TABLE IF NOT EXISTS registro (
    id SERIAL PRIMARY KEY,
    cod_municipio INTEGER NOT NULL REFERENCES municipio(cod_ibge),
    cod_natureza INTEGER NOT NULL REFERENCES natureza(cod_natureza),
    id_periodo INTEGER NOT NULL REFERENCES periodo(id_periodo),
    quantidade INTEGER NOT NULL CHECK (quantidade >= 0),
    UNIQUE(cod_municipio, cod_natureza, id_periodo)
);

CREATE INDEX idx_registro_municipio ON registro(cod_municipio);
CREATE INDEX idx_registro_natureza  ON registro(cod_natureza);
CREATE INDEX idx_registro_periodo   ON registro(id_periodo);
CREATE INDEX idx_municipio_risp     ON municipio(cod_risp);
