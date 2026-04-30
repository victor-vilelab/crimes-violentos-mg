# Crimes Violentos em Minas Gerais — Análise com Banco de Dados Relacional

> Trabalho da disciplina de **Banco de Dados** explorando dados abertos de segurança pública do estado de Minas Gerais. Modela, importa e consulta o dataset oficial de crimes violentos via PostgreSQL.

---

## 📌 Sobre o Projeto

Este repositório contém a modelagem, importação e análise do dataset **Crimes Violentos** publicado pelo Observatório de Segurança Pública (SEJUSP-MG), alimentado pelo sistema **REDS — Registro de Evento de Defesa Social**.

O trabalho está dividido em duas entregas:

| Etapa | Prazo | Conteúdo |
|---|---|---|
| **Versão parcial** | 04/05/2026 | Modelagem ER preliminar + banco **não-normalizado** em PostgreSQL + **5 consultas** em SQL e álgebra relacional |
| **Versão final** | 08/06/2026 | Schema normalizado em 3FN + enriquecimento com dados externos (IBGE) + relatório completo em Jupyter Notebook |

---

## 📊 Dataset

| Atributo | Valor |
|---|---|
| **Fonte** | [Portal de Dados Abertos MG — Crimes Violentos](https://dados.mg.gov.br/dataset/crimes-violentos) |
| **Órgão produtor** | Observatório de Segurança Pública — SEJUSP-MG |
| **Sistema de origem** | REDS (Registro de Evento de Defesa Social) |
| **Cobertura geográfica** | 853 municípios de Minas Gerais |
| **Cobertura temporal** | Janeiro/2025 a Março/2026 (15 meses) |
| **Granularidade** | Município × Natureza do crime × Mês |
| **Formato bruto** | CSV separado por `;`, codificação UTF-8 |

### Estrutura do CSV bruto

| Coluna | Tipo | Descrição |
|---|---|---|
| `registros` | inteiro | Quantidade de crimes registrados na combinação |
| `natureza` | texto | Tipo do crime (ex: `HOMICIDIO CONSUMADO`, `ESTUPRO TENTADO`) |
| `municipio` | texto | Nome do município |
| `cod_municipio` | inteiro | Código IBGE do município |
| `mes` | inteiro | Mês (1–12) |
| `ano` | inteiro | Ano (2025, 2026) |
| `risp` | texto | Região Integrada de Segurança Pública |
| `rmbh` | texto | `SIM` se o município pertence à Região Metropolitana de Belo Horizonte |

### Volume de dados

- **191.925 linhas** na tabela bruta (`853 municípios × 15 naturezas × 15 meses`)
- **31.620 ocorrências** somadas (`SUM(registros)`)
- **11.414 combinações únicas** com pelo menos um crime registrado
- **15 naturezas** distintas
- **19 RISPs** distintas

> 📝 **Observação importante:** o dataset bruto é uma **matriz completa** — para toda combinação de município × natureza × mês existe uma linha, **mesmo quando `registros = 0`**. Essa decisão preserva a informação de que houve coleta (ausência de crime ≠ ausência de dado). Por isso, consultas que perguntam "ocorreu" ou "registrou crime" precisam filtrar `WHERE registros > 0`.

---

## 🗂️ Estrutura do Repositório

```
crimes_violentos/
├── README.md                     # Este arquivo
├── crimes_violentos_2025.csv     # Dados brutos — ano 2025
├── crimes_violentos_2026.csv     # Dados brutos — janeiro a março de 2026
├── criar_tabela_inicial.sql      # CREATE TABLE da tabela bruta crimes_raw
├── arquivo.sql                   # Entrega parcial: banco não-normalizado + 5 consultas SQL
└── (em breve)
    ├── schema_normalizado.sql    # Entrega final: schema 3FN
    └── relatorio_final.ipynb     # Entrega final: relatório com gráficos
```

---

## 🧱 Modelagem

### Banco não-normalizado (entrega parcial)

A tabela `crimes_raw` é uma cópia direta da estrutura do CSV. Serve como base para as 5 consultas da versão parcial.

```sql
CREATE TABLE crimes_raw (
    id            SERIAL PRIMARY KEY,
    registros     INTEGER,
    natureza      VARCHAR(100),
    municipio     VARCHAR(100),
    cod_municipio INTEGER,
    mes           INTEGER,
    ano           INTEGER,
    risp          VARCHAR(100),
    rmbh          VARCHAR(10)
);
```

### Modelo Entidade-Relacionamento preliminar (para entrega final)

A análise dos dados identificou **5 entidades** que serão materializadas no schema normalizado da entrega final:

| Entidade | Cardinalidade | Papel | Atributos principais |
|---|---|---|---|
| **Município** | 853 | Dimensão | `cod_ibge` (PK), `nome`, `população`, `pertence_rmbh`, `cod_risp` (FK) |
| **RISP** | 19 | Dimensão | `cod_risp` (PK), `nome_sede` |
| **Natureza** | 15 | Dimensão | `cod_natureza` (PK), `descrição`, `categoria`, `consumado` (booleano) |
| **Período** | 15 | Dimensão | `id_periodo` (PK), `mês`, `ano`, `trimestre` |
| **Registro** | 191.925 | Fato | `id` (PK), `cod_municipio` (FK), `cod_natureza` (FK), `id_periodo` (FK), `quantidade` |

#### Relacionamentos

- `Município` **pertence a** `RISP` — N:1 (cada município pertence a uma única RISP, validado empiricamente)
- `Registro` **refere-se a** `Município` — N:1
- `Registro` **é do tipo** `Natureza` — N:1
- `Registro` **ocorre em** `Período` — N:1
- `Município` **registra** `Natureza` — N:M (relacionamento derivado, materializado pela tabela `Registro`)

#### Atributos enriquecidos (entrega final)

- `Município.população` → IBGE (Estimativas Populacionais)
- `Natureza.categoria` → classificação manual (ex: "Crimes contra a vida", "Crimes contra a dignidade sexual", "Crimes contra o patrimônio")
- `Natureza.consumado` → derivável do nome via parsing (todas as naturezas terminam em `CONSUMADO` ou `TENTADO`)

> 📐 **Diagrama ER:** será adicionado nesta seção quando finalizado.

---

## 📈 Consultas

As **5 consultas analíticas** da entrega parcial estão implementadas em `arquivo.sql` e expressas a seguir tanto em **SQL** quanto em **álgebra relacional** (notação clássica de Codd).

### Notação de álgebra relacional usada

| Símbolo | Operador |
|---|---|
| **π** | Projeção (selecionar colunas) |
| **σ** | Seleção (filtrar linhas) |
| **∪** | União |
| **−** | Diferença |

---

### Consulta 1 — Naturezas de crime distintas

**Pergunta:** Quais são as naturezas de crime distintas registradas?

**SQL:**
```sql
SELECT DISTINCT natureza FROM crimes_raw ORDER BY natureza;
```

**Álgebra relacional:**
```
π_natureza (crimes_raw)
```

---

### Consulta 2 — Municípios e naturezas na RMBH

**Pergunta:** Listar os municípios e as naturezas dos crimes que ocorreram na Região Metropolitana de Belo Horizonte em 2025.

**SQL:**
```sql
SELECT DISTINCT municipio, natureza
FROM crimes_raw
WHERE rmbh = 'SIM' AND ano = 2025 AND registros > 0;
```

**Álgebra relacional:**
```
π_(municipio, natureza) ( σ_(rmbh = 'SIM' ∧ ano = 2025 ∧ registros > 0) (crimes_raw) )
```

---

### Consulta 3 — Municípios com registros em dezembro de 2025

**Pergunta:** Listar os municípios que tiveram pelo menos um crime registrado em dezembro de 2025.

**SQL:**
```sql
SELECT DISTINCT municipio
FROM crimes_raw
WHERE ano = 2025 AND mes = 12 AND registros > 0;
```

**Álgebra relacional:**
```
π_municipio ( σ_(ano = 2025 ∧ mes = 12 ∧ registros > 0) (crimes_raw) )
```

---

### Consulta 4 — Municípios com registros em janeiro de 2025 ou janeiro de 2026

**Pergunta:** Quais municípios registraram crimes no mês 1 de 2025 ou no mês 1 de 2026?

**SQL:**
```sql
SELECT DISTINCT municipio, mes, ano
FROM crimes_raw
WHERE mes = 1 AND ano IN (2025, 2026) AND registros > 0;
```

**Álgebra relacional (forma com união explícita):**
```
π_municipio ( σ_(mes = 1 ∧ ano = 2025 ∧ registros > 0) (crimes_raw) )
∪
π_municipio ( σ_(mes = 1 ∧ ano = 2026 ∧ registros > 0) (crimes_raw) )
```

---

### Consulta 5 — Municípios SEM registros em dezembro de 2025

**Pergunta:** Quais municípios **não** registraram nenhum crime em dezembro de 2025?

**SQL:**
```sql
SELECT DISTINCT municipio FROM crimes_raw
EXCEPT
SELECT DISTINCT municipio FROM crimes_raw
WHERE ano = 2025 AND mes = 12 AND registros > 0;
```

**Álgebra relacional:**
```
π_municipio (crimes_raw)
−
π_municipio ( σ_(ano = 2025 ∧ mes = 12 ∧ registros > 0) (crimes_raw) )
```

---

### Cobertura de operadores

As 5 consultas, em conjunto, exercitam **4 operadores fundamentais** da álgebra relacional:

| Operador | Usado em |
|---|---|
| **π** (projeção) | Q1, Q2, Q3, Q4, Q5 |
| **σ** (seleção) | Q2, Q3, Q4, Q5 |
| **∪** (união) | Q4 |
| **−** (diferença) | Q5 |

> O operador **⋈** (junção) será exercitado na entrega final, quando o banco estiver normalizado em 5 tabelas.

---

## 🚀 Como Reproduzir

### Pré-requisitos

- PostgreSQL 16+
- pgAdmin 4 (ou outro cliente SQL)
- Os arquivos `crimes_violentos_2025.csv` e `crimes_violentos_2026.csv` na raiz do projeto

### Passo a passo

1. **Criar o banco de dados:**
    ```sql
    CREATE DATABASE crimes_mg;
    ```

2. **Conectar a `crimes_mg` e criar a tabela bruta:**
    ```sql
    \i criar_tabela_inicial.sql
    ```

3. **Importar os CSVs.** Há dois caminhos:

    **Opção A — `\copy` (linha de comando):**
    ```sql
    \copy crimes_raw(registros, natureza, municipio, cod_municipio, mes, ano, risp, rmbh) FROM 'crimes_violentos_2025.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';', ENCODING 'UTF8');
    \copy crimes_raw(registros, natureza, municipio, cod_municipio, mes, ano, risp, rmbh) FROM 'crimes_violentos_2026.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';', ENCODING 'UTF8');
    ```

    **Opção B — Import/Export Tool do pgAdmin:**
    - Botão direito em `crimes_raw` → `Import/Export Data...`
    - General → Filename: arquivo CSV; Format: `csv`; Encoding: `UTF8`
    - Options → Header: `ON`; Delimiter: `;`
    - **Columns → desmarcar a coluna `id`** (é SERIAL e não está no CSV)

4. **Verificar a importação:**
    ```sql
    SELECT ano, COUNT(*) AS linhas FROM crimes_raw GROUP BY ano ORDER BY ano;
    -- 2025 → 153.540 linhas
    -- 2026 →  38.385 linhas
    ```

5. **Rodar as consultas da entrega parcial:**
    ```sql
    \i arquivo.sql
    ```

---

## 🛠️ Ferramentas

- **PostgreSQL 16.13** — SGBD relacional
- **pgAdmin 4** — interface gráfica para administração e consultas
- **Python 3 + pandas** — pré-processamento e enriquecimento (entrega final)
- **Jupyter Notebook** — relatório final com gráficos
- **Git** — controle de versão

---

## 📅 Cronograma da Disciplina

| Data | Entrega | Status |
|---|---|---|
| 2026-04-24 | Proposta do tema | ✅ Concluído |
| 2026-05-04 | Versão parcial (ER preliminar + banco não-normalizado + 5 consultas) | ✅ Concluído |
| 2026-06-08 | Relatório final (`.ipynb` + `.pdf`) | ⏳ Em planejamento |
| 2026-06-12 / 06-15 / 06-19 | Apresentação | ⏳ |

---

## ✅ Status do Projeto

### Entrega parcial
- [x] Escolha e aprovação do dataset
- [x] Download dos arquivos CSV (2025 e 2026)
- [x] Análise exploratória dos dados
- [x] Criação do banco PostgreSQL `crimes_mg`
- [x] Importação dos CSVs (191.925 linhas) na tabela `crimes_raw`
- [x] Validação preliminar do modelo ER (5 entidades identificadas)
- [x] 5 consultas SQL implementadas e testadas
- [x] 5 consultas traduzidas para álgebra relacional
- [ ] Diagrama ER preliminar (visual)

### Entrega final
- [ ] Schema normalizado em 3FN (5 tabelas com PKs e FKs)
- [ ] Integração com dados de população (IBGE)
- [ ] Classificação manual de categorias de naturezas
- [ ] Consultas analíticas com JOINs
- [ ] Relatório final (Jupyter Notebook + PDF)
- [ ] Apresentação

---

## 👥 Autores

_A preencher com os membros do grupo._

---

## 📚 Referências

- [Portal de Dados Abertos MG](https://dados.mg.gov.br/)
- [Dataset Crimes Violentos](https://dados.mg.gov.br/dataset/crimes-violentos)
- [Documentação PostgreSQL](https://www.postgresql.org/docs/)
- [Documentação pgAdmin](https://www.pgadmin.org/docs/)
- [IBGE — Estimativas Populacionais](https://www.ibge.gov.br/estatisticas/sociais/populacao.html)

---

## 📄 Licença

Os dados originais são de domínio público (Portal de Dados Abertos MG). O código deste repositório é distribuído sob a licença MIT.
