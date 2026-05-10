# Bigdata

Para clonar o repositório fazer: 
```
git clone https://github.com/pesobreiro/bigdata.git

```
Software recomendado:
* Visual Studio Code https://code.visualstudio.com/
* git https://git-scm.com/
* Pandoc https://pandoc.org/

Para lidararem com ficheiros grandes no github:
* git lfs https://git-lfs.github.com/
* git lfs install
* git lfs track "*.csv"

O primeiro comando permite instalar, o segundo inicializa o git lfs e o terceiro comando define que todos os ficheiros com a extensão .csv são tratados pelo git lfs.


## Comandos principais
Atualizar um repositório local (descarrega do git par ao computador) : `git pull`

Enviar alterações para o github:

1. Adicionar um ficheiro `git add nomeFicheiro`  ou adicionar todos os ficheiros alterados `git add .`
2. Colocar na zona de "preparação" do computador `git commit -m "nome ou descricao"`
3. Colocar as alterações no git `git push` antes era `git push origin master`

# Instalar spark

```
Instalar o Java Runtime Environment
testar com cmd
java --version

Se n├úo tiver instalado correr:
conda install -c conda-forge openjdk
```

Vantagens de instalar o Java com o anaconda:
Environment Management: Installing Java through conda keeps it nicely contained within a conda environment. This helps prevent conflicts if you need different Java versions for different projects.


1. conda create --name bigdate
2. conda activate bigdata
3. conda install -c conda-forge pyspark
4. conda install -c conda-forge findspark
4. conda install -c conda-forge jupyterlab


Uma alternativa ao anaconda mais r├ípido:
````
conda install mamba -n base -c conda-forge
````

Depois funciona tudo normalmente como com o conda. Se quiserem instalar o mamba no ambiente
onde est├úo a trabalhar basta fazer:

````
conda install mamba
````

Se quiserem utilizar o code convem instalar o ````ipykernel````

````

mamba install -c conda-forge ipykernel

# se n├úo funcionar

conda install -c conda-forge ipykernel

````

# Koalas: Pandas API on Apache Spark

Koalas supports Apache Spark 3.1 and below as it is officially included to PySpark in Apache Spark 3.2. This repository is now in maintenance mode. For Apache Spark 3.2 and above, please use PySpark directly.

Mais info [aqui](https://koalas.readthedocs.io/en/latest/index.html)

Exemplo:
````

import pyspark.pandas as ps
from pyspark.sql import SparkSession
spark = SparkSession.builder.getOrCreate() 
# If you're not in a notebook environment, you may need to create a SparkContext first
# From a Python dictionary
data = {'Name': ['Alice', 'Bob', 'Charlie'], 'Age': [25, 30, 35]}
pdf = ps.DataFrame(data)
print(pdf)
# From a pandas DataFrame (converted to pyspark.pandas DataFrame)
import pandas as pd
pandas_df = pd.DataFrame({'A': [1, 2], 'B': [3, 4]})
spark_df = ps.from_pandas(pandas_df) 
# Filtering
filtered_df = pdf[pdf['Age'] > 25]
# Selecting columns
selected_df = pdf[['Name', 'Age']]
# Group by and aggregation
grouped_df = pdf.groupby('Age').agg({'Name': 'count'})
# Sorting
sorted_df = pdf.sort_values(by='Age', ascending=False)

````
Vantagens:
* Scalability: The biggest advantage is its ability to handle datasets that are far too large to fit into the memory of a single machine. pyspark.pandas leverages the power of Apache Spark to distribute data and computations across a cluster of machines, enabling processing of massive datasets that would overwhelm pandas.
* Distributed Computing: By distributing workloads, pyspark.pandas can often achieve significantly faster processing times than pandas on large datasets. This is especially beneficial for tasks like complex aggregations, joins, or machine learning algorithms.
* Integration with Spark Ecosystem: pyspark.pandas seamlessly integrates with other components of the Spark ecosystem, such as Spark SQL for querying structured data, Spark Streaming for real-time processing, and MLlib for machine learning. This makes it easier to build end-to-end big data pipelines.
* Familiarity: The API of pyspark.pandas is intentionally designed to be very similar to pandas, making it easier for data scientists familiar with pandas to transition to big data analysis.
pyspark.pandas: The preferred choice for large-scale datasets that exceed the memory capacity of a single machine. It provides scalability, distributed computing capabilities, and integration with the broader Spark ecosystem.


