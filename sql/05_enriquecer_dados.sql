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

