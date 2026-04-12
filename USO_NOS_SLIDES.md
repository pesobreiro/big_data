# 🎯 Como Usar este Repositório (Para Alunos)

## Quick Start

### 1. Clonar o Repositório

```bash
git clone https://github.com/pedrosobreiro/big_data.git
cd big_data
```

### 2. Usar com Google Colab (Opção Mais Fácil)

**Opção A: Upload manual**
1. Aceder a [colab.research.google.com](https://colab.research.google.com)
2. File → Upload notebook → Selecionar ficheiro `.ipynb` da pasta `notebooks/`
3. Fazer upload dos dados:
   - Clicar no ícone 📁 (Files) na barra lateral
   - "Upload to session storage"
   - Selecionar ficheiros `.parquet` da pasta `data/`

**Opção B: Montar Google Drive**
```python
from google.colab import drive
drive.mount('/content/drive')
# Depois copiar dados do Drive para o Colab
```

### 3. Usar Localmente

```bash
# Criar ambiente virtual
python -m venv venv_bigdata

# Ativar (Windows)
venv_bigdata\Scripts\activate
# Ativar (Linux/Mac)
source venv_bigdata/bin/activate

# Instalar dependências
pip install pyspark pandas numpy matplotlib jupyterlab

# Iniciar Jupyter
jupyter lab
```

### 4. Estrutura dos Notebooks

| Ordem | Notebook | Objetivo |
|-------|----------|----------|
| 1 | `00_estrutura_trabalho.ipynb` | Template para o projeto |
| 2 | `01_introducao_pyspark.ipynb` | Primeiros passos |
| 3 | `02_dataframes_operacoes.ipynb` | Operações básicas |
| 4 | `03_leitura_dados.ipynb` | Carregar os dados crypto |
| 5 | `04_transformacoes.ipynb` | Limpeza e transformação |
| 6 | `05_machine_learning.ipynb` | Algoritmos ML |
| 7 | `06_ml_bitcoin.ipynb` | Exemplo prático BTC |
| 8 | `08_backtesting.ipynb` | Validação de modelos |

### 5. Dados Disponíveis

```python
# Exemplo de leitura
from pyspark.sql import SparkSession
spark = SparkSession.builder.appName("BigData").getOrCreate()

# Ler dados
df = spark.read.parquet("data/btc_04h_usdt_binance.parquet")
df.show(5)
```

**Dados incluídos:**
- `btc_04h_usdt_binance.parquet` - Bitcoin (4 horas)
- `eth_04h_usdt_binance.parquet` - Ethereum (4 horas)
- `ada_04h_usdt_binance.parquet` - Cardano (4 horas)

**Dataset completo (7.4GB):** Contactar pesobreiro@gmail.com

---

## 📋 Checklist para o Projeto

- [ ] Clonar repositório
- [ ] Criar ambiente PySpark funcional
- [ ] Ler dados com `spark.read.parquet()`
- [ ] Implementar pipeline de ML
- [ ] Documentar no notebook
- [ ] Submeter no Moodle

---

## ❓ Problemas Comuns

**"Java not found"**
```bash
# Ubuntu/Debian
sudo apt install default-jdk

# Windows/Mac: https://adoptium.net
```

**"Module not found"**
```bash
pip install pyspark pandas numpy matplotlib
```

**Dados não carregam**
- Verificar caminho: `data/btc_04h_usdt_binance.parquet`
- Confirmar que ficheiros `.parquet` estão na pasta `data/`

---

## 📞 Suporte

- Email: pesobreiro@gmail.com
- ORCID: 0000-0003-3971-3545
- Issues: [github.com/pedrosobreiro/big_data/issues](https://github.com/pedrosobreiro/big_data/issues)
