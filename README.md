# Elementos de Apoio - Processamento de Big Data

Repositório de recursos educativos.

## 📁 Estrutura

```
big_data/
├── data/               # Dados de exemplo (cryptomoedas)
├── notebooks/          # Notebooks Jupyter com exemplos práticos
└── README.md          # Este ficheiro
```

## 📊 Dados

A pasta `data/` contém uma amostra de dados históricos de cryptomoedas (BTC, ETH, ADA) em formato Parquet, com timeframe de 4 horas.

**Para aceder ao dataset completo (7.4GB+):**
- Usar a API da Binance para obter dados atualizados
- Ou contactar o docente da UC

### Formatos disponíveis
- `btc_04h_usdt_binance.parquet` - Bitcoin/USDT (4h)
- `eth_04h_usdt_binance.parquet` - Ethereum/USDT (4h)
- `ada_04h_usdt_binance.parquet` - Cardano/USDT (4h)

## 📓 Notebooks

| Notebook | Descrição |
|----------|-----------|
| `00_estrutura_trabalho.ipynb` | Template para o projeto de avaliação |
| `01_introducao_pyspark.ipynb` | Introdução ao PySpark |
| `02_dataframes_operacoes.ipynb` | Operações com DataFrames |
| `03_leitura_dados.ipynb` | Leitura de diferentes formatos |
| `04_transformacoes.ipynb` | Transformações de dados |
| `05_machine_learning.ipynb` | ML com PySpark MLlib |
| `06_ml_bitcoin.ipynb` | ML aplicado a Bitcoin |
| `07_logistic_regression_decision_tree.ipynb` | Algoritmos de classificação |
| `08_backtesting.ipynb` | Backtesting de estratégias |
| `09_feature_selection.ipynb` | Seleção de features |
| `10_parquet_delta_lake.ipynb` | Formatos Parquet e Delta Lake |
| `11_structured_streaming.ipynb` | Streaming estruturado |
| `12_dados_reais_crypto.ipynb` | Exemplo com dados reais |

## 🚀 Como usar

### Instalar ferramentas base (Windows)

Se ainda não tens estas ferramentas instaladas, podes obtê-las facilmente via **winget**:

**Git:**
```powershell
winget install --id Git.Git -e --source winget
```

**Miniconda:**
```powershell
winget install --id Anaconda.Miniconda3 -e --source winget
```

> Nota: O `winget` já vem incluído no Windows 10 (20H2+) e Windows 11. Após a instalação, reinicia o terminal para garantir que os comandos fiquem disponíveis.

### Opção 1: Google Colab (recomendado para iniciantes)
1. Aceder a [colab.research.google.com](https://colab.research.google.com)
2. Fazer upload do notebook desejado
3. Executar `!pip install pyspark` na primeira célula

### Opção 2: Ambiente Local
```bash
# Criar ambiente virtual
python -m venv venv_bigdata
source venv_bigdata/bin/activate  # Linux/Mac
# venv_bigdata\Scripts\activate   # Windows

# Instalar dependências
pip install pyspark pandas numpy matplotlib jupyterlab

# Iniciar Jupyter
jupyter lab
```

### Opção 3: Conda (recomendado)
```bash
conda create -n bigdata python=3.11
conda activate bigdata
conda install -c conda-forge openjdk pyspark jupyterlab
jupyter lab
```

## 📝 Requisitos

- Python 3.9+
- Java 8/11 (para PySpark local)
- 4GB+ RAM recomendado

## 📚 Recursos Adicionais

- [Documentação PySpark](https://spark.apache.org/docs/latest/api/python/)
- [Slidev Aula 1](https://sli.dev) - Apresentações da UC
- [Repositório de apoio](https://github.com/) - Código fonte adicional

## 👨‍🏫 Autor

**Pedro Sobreiro**
- ORCID: 0000-0003-3971-3545
- Professor, Investigador e Consultoria

## 📄 Licença

Estes materiais são destinados a fins educativos. Os dados de cryptomoedas são obtidos via API pública da Binance.

---

*Última atualização: 2025/2026*
