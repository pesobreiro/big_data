# Elementos de Apoio - Processamento de Big Data

Repositório de recursos educativos.

## 📁 Estrutura

```
big_data/
├── data/               # Dados de exemplo (cryptomoedas)
├── install/            # Scripts de instalação por plataforma
├── notebooks/          # Notebooks Jupyter com exemplos práticos
└── README.md           # Este ficheiro
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

### Opção 1: Docker (recomendado — funciona em Mac, Windows e Linux)

O Docker resolve automaticamente todos os problemas de Java e configuração do PySpark.
É a forma mais fiável de ter um ambiente idêntico em qualquer sistema operativo.

**Passo 1 — Instalar o Docker Desktop:**

**Mac (via Homebrew):**
```bash
brew install --cask docker
```
Ou fazer download direto em [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/). Após instalar, abrir o Docker Desktop pela primeira vez para completar a configuração.

**Windows (via winget):**
```powershell
winget install --id Docker.DockerDesktop -e --source winget
```
Durante a instalação, aceitar a opção **WSL 2** quando solicitado. Reiniciar o computador após a instalação e abrir o Docker Desktop.

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker $USER
newgrp docker
```

**Linux (verificar instalação):**
```bash
docker run hello-world
```

**Passo 2 — Clonar o repositório e iniciar:**
```bash
git clone <url-do-repositorio>
cd big_data
docker compose up
```

**Passo 3 — Abrir o JupyterLab:**

Aceder a [http://localhost:8888](http://localhost:8888) no browser. Os notebooks estão na pasta `work/notebooks/`.

**Parar o ambiente:**
```bash
docker compose down
```

> **Nota Windows:** Se o comando `docker compose` não for reconhecido, usa `docker-compose` (com hífen). Certifica-te que o Docker Desktop está em execução antes de correr os comandos.

---

### Opção 2: Google Colab (sem instalação)

1. Aceder a [colab.research.google.com](https://colab.research.google.com)
2. Fazer upload do notebook desejado
3. Executar na primeira célula:
```python
!pip install pyspark
```

---

### Opção 3: Conda (instalação local)

> Scripts de instalação automática disponíveis em [`install/`](install/README.md) para Mac, Windows e Linux.

#### Instalar o Miniconda

**Mac (via Homebrew):**

```bash
brew install --cask miniconda
conda init zsh   # ou: conda init bash
```

Fechar e reabrir o terminal após este passo.

**Windows (via winget):**

```powershell
winget install --id Git.Git -e --source winget
winget install --id Anaconda.Miniconda3 -e --source winget
```

> O `winget` já vem incluído no Windows 10 (20H2+) e Windows 11. Reiniciar o terminal após a instalação. Usar o **Anaconda Prompt** ou o **PowerShell** com conda inicializado.

**Linux (Ubuntu/Debian):**

```bash
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda3
$HOME/miniconda3/bin/conda init bash
```

Fechar e reabrir o terminal após este passo.

#### Criar o ambiente PySpark

O comando seguinte é igual em Mac, Windows e Linux. O `openjdk=17` instala o Java automaticamente dentro do ambiente conda, sem necessidade de instalar Java no sistema.

**Opção A — conda (standard):**

```bash
conda create -n bigdata python=3.11 -y
conda activate bigdata
conda install -c conda-forge "openjdk=17" "pyspark>=3.5" pandas jupyterlab ipykernel pyarrow -y
jupyter lab
```

**Opção B — mamba (recomendado se conda ficar bloqueado):**

O `conda install` pode ficar preso em "Solving environment" quando a base do Anaconda tem muitos pacotes. O mamba é um substituto direto que resolve o mesmo problema em segundos.

```bash
# Instalar o solver rápido e mamba (uma única vez, no ambiente base)
conda install -n base conda-libmamba-solver --override-channels -c conda-forge -y
conda config --set solver libmamba
conda install -n base -c conda-forge mamba -y

# Criar e configurar o ambiente
conda create -n bigdata python=3.11 -y
conda activate bigdata
mamba install -c conda-forge "openjdk=17" "pyspark>=3.5" pandas jupyterlab ipykernel pyarrow -y
jupyter lab
```

#### Verificar a instalação

```bash
conda activate bigdata
python -c "import pyspark; print('PySpark', pyspark.__version__, '- OK')"
```

#### Resolução de problemas no Windows

Se o PySpark não iniciar (erro `Java gateway process exited`), verificar se o Java foi reconhecido:

```powershell
conda activate bigdata
python -c "import os; print(os.environ.get('JAVA_HOME', 'JAVA_HOME nao definido'))"
```

Se `JAVA_HOME` não estiver definido, definir manualmente na sessão:

```powershell
$env:JAVA_HOME = "$env:CONDA_PREFIX\Library"
jupyter lab
```

Ou adicionar ao início do notebook:

```python
import os
os.environ['JAVA_HOME'] = os.path.join(os.environ['CONDA_PREFIX'], 'Library')

import pyspark
```

## 📝 Requisitos e compatibilidade de versões

### Versões utilizadas neste projeto

| Componente | Versão mínima | Porquê |
|------------|--------------|--------|
| Python | 3.9 | PySpark 3.5+ requer Python 3.8+; 3.11 é a versão estável recomendada |
| Java (OpenJDK) | 17 | PySpark 3.5+ suporta Java 8, 11 e 17; Java 17 é LTS e instalável via conda |
| PySpark | 3.5 | Primeira versão compatível com pandas 2.x (ver abaixo) |
| pandas | 2.0+ | Versão atual instalada pelo conda; requer PySpark >= 3.5 |
| PyArrow | qualquer | Necessário para leitura de ficheiros Parquet |

### Porquê PySpark >= 3.5 é obrigatório

O PySpark inclui uma API chamada `pyspark.pandas` que permite usar sintaxe pandas em cima do Spark distribuído.
Nas versões 3.3 e 3.4, essa API dependia de `pandas.core.common._builtin_table`, atributo **removido no pandas 2.0**.

O PySpark 3.5+ corrigiu parcialmente o problema, mas o bug persiste em todas as versões disponíveis via pip
(incluindo 4.x). Por isso os notebooks deste projeto **não usam `pyspark.pandas`** — usam `.toPandas()` em alternativa.

**Conversão correta de Spark DataFrame para pandas:**

```python
# NÃO usar — bug com pandas 2.x em todas as versões pip:
# import pyspark.pandas as ps
# df_pandas = ps.DataFrame(df_spark)

# Usar sempre:
df_pandas = df_spark.toPandas()
```

`.toPandas()` é o método nativo do PySpark, não tem dependências externas, e funciona com qualquer versão de pandas.
A limitação é que traz todos os dados para memória — adequado para datasets que cabem numa máquina.

### Porquê Java 17 e não Java 8 ou 11

O Spark corre na JVM (Java Virtual Machine) — é obrigatório ter Java instalado.
Java 8 e 11 também funcionam com PySpark 3.5, mas:

- **Java 8** está em fim de vida e algumas funcionalidades modernas do Spark emitem avisos
- **Java 11** funciona, mas o Java 17 é a versão LTS atual e a mais testada com Spark 3.5+
- **Java 17** é instalado automaticamente pelo conda (`openjdk=17`) sem configuração manual do `JAVA_HOME`

### Porquê conda e não pip

```
pip install pyspark
```

Funciona, mas não instala o Java. O utilizador teria de instalar Java manualmente e
configurar a variável de ambiente `JAVA_HOME` — fonte frequente de erros no Windows.

Com conda (`conda install -c conda-forge openjdk=17 pyspark`), o Java fica instalado
dentro do ambiente e o `JAVA_HOME` é configurado automaticamente.

### Resumo de requisitos por opção de instalação

- **Docker** — sem requisitos adicionais; Java, Python e PySpark já incluídos na imagem
- **Conda** — Python 3.11 + Java 17 instalados automaticamente pelo script
- **RAM** — 4GB mínimo recomendado para correr o Spark localmente

## VS Code

Para abrir os notebooks diretamente no VS Code, instalar as extensões:

```bash
code --install-extension ms-python.python
code --install-extension ms-toolsai.jupyter
code --install-extension ms-toolsai.jupyter-keymap
code --install-extension ms-toolsai.jupyter-celltags
```

Depois abrir um `.ipynb`, clicar em **Select Kernel** (canto superior direito) e escolher o ambiente **bigdata**.

Ver [install/README.md](install/README.md) para instruções detalhadas de seleção de kernel e ligação a servidor JupyterLab externo (incluindo Docker).

## Assistente de IA para instalação e resolução de problemas

Para agilizar a configuração do ambiente e resolver erros, recomenda-se usar o **Gemini CLI** — um assistente de IA gratuito que corre diretamente no terminal e tem acesso ao contexto do sistema.

### Instalar o Gemini CLI

```bash
npm install -g @google/gemini-cli
gemini
```

Na primeira execução pede login com conta Google. Após autenticação fica disponível no terminal como `gemini`.

### Exemplos de uso durante a instalação

Descrever o erro diretamente no terminal e pedir ajuda:

```bash
gemini
```

```
> conda install está bloqueado em "Solving environment". Como resolver?
> Erro: JAVA_HOME is not set. O que significa e como corrigir no Windows?
> Como verificar se o ambiente bigdata está correto e o PySpark funciona?
```

O Gemini CLI tem acesso ao sistema de ficheiros e ao terminal, pelo que pode analisar
logs de erro, verificar versões instaladas e sugerir comandos específicos para a situação.

### Alternativas

- **Claude Code** — `npm install -g @anthropic-ai/claude-code` — alternativa ao Gemini CLI
- **GitHub Copilot** no VS Code — integrado no editor, útil para erros nos notebooks

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
