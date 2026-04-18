"""
Verifica se o ambiente PySpark está corretamente instalado.
Uso: python install/verify_install.py
"""

import sys
import os

CHECKS = []

def check(label, fn):
    try:
        result = fn()
        CHECKS.append(("OK", label, result or ""))
    except Exception as e:
        CHECKS.append(("FAIL", label, str(e)))

# Python
check("Python >= 3.9", lambda: (
    f"{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}"
    if sys.version_info >= (3, 9) else (_ for _ in ()).throw(RuntimeError(f"Python {sys.version} — requer 3.9+"))
))

# JAVA_HOME
check("JAVA_HOME definido", lambda: os.environ.get("JAVA_HOME") or (_ for _ in ()).throw(RuntimeError("JAVA_HOME não definido")))

# Pacotes
for pkg in ["pyspark", "pyarrow", "jupyterlab"]:
    def _check(p=pkg):
        mod = __import__(p.replace("-", "_"))
        return getattr(mod, "__version__", "instalado")
    check(f"Pacote {pkg}", _check)

# SparkSession
def _spark_check():
    from pyspark.sql import SparkSession
    spark = SparkSession.builder \
        .master("local") \
        .appName("verify") \
        .config("spark.ui.showConsoleProgress", "false") \
        .getOrCreate()
    spark.sparkContext.setLogLevel("ERROR")
    df = spark.range(10)
    count = df.count()
    spark.stop()
    if count != 10:
        raise RuntimeError(f"Esperado 10 linhas, obtido {count}")
    return f"SparkSession criada, contagem={count}"

check("SparkSession funcional", _spark_check)

# ── Relatório ──────────────────────────────────────────────────────────────────
print("\n=== Verificação do ambiente PySpark ===\n")
all_ok = True
for status, label, detail in CHECKS:
    icon = "OK" if status == "OK" else "FAIL"
    line = f"  [{icon}] {label}"
    if detail:
        line += f"  ({detail})"
    print(line)
    if status != "OK":
        all_ok = False

print()
if all_ok:
    print("Ambiente OK — pode iniciar o JupyterLab com: jupyter lab")
else:
    print("Existem problemas. Consulta o README para instruções de resolução.")
    sys.exit(1)
