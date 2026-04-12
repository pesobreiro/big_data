# 🚀 Push para GitHub

## Passo 1: Criar Repositório no GitHub

1. Aceder a [github.com/new](https://github.com/new)
2. **Repository name:** `big_data`
3. **Description:** "Elementos de apoio à UC Processamento de Big Data"
4. **Visibility:** Public (ou Private se preferir)
5. **NÃO** marcar "Initialize this repository with a README"
6. Clicar em **"Create repository"**

## Passo 2: Configurar Remote (se ainda não estiver feito)

```bash
cd ~/git/teaching/big_data

# Verificar remote atual
git remote -v

# Se necessário, alterar o URL:
git remote set-url origin https://github.com/SEU_USERNAME/big_data.git
```

## Passo 3: Push dos Dados

```bash
# Garantir que estamos na branch main
git branch -m main

# Push para o GitHub
git push -u origin main
```

## Passo 4: Verificar

Abrir `https://github.com/SEU_USERNAME/big_data` no browser e confirmar que:
- [ ] README.md está visível
- [ ] Pasta `data/` com ficheiros `.parquet`
- [ ] Pasta `notebooks/` com 13 ficheiros `.ipynb`

## 🔧 Resolução de Problemas

### Erro: "Repository not found"
```bash
# Verificar se o repositório foi criado no GitHub
# Tentar com SSH em vez de HTTPS:
git remote set-url origin git@github.com:SEU_USERNAME/big_data.git
```

### Erro: "Permission denied"
```bash
# Configurar credenciais Git
git config --global user.name "Seu Nome"
git config --global user.email "seu@email.com"

# Ou usar GitHub CLI:
gh auth login
```

### Erro: "Large files"
Os ficheiros `.parquet` têm ~15MB cada (total 45MB), dentro dos limites do GitHub (100MB por ficheiro).

Se necessário, usar Git LFS:
```bash
git lfs track "*.parquet"
git add .gitattributes
git commit -m "Add Git LFS for parquet files"
git push
```

## 📋 Comandos Resumidos

```bash
# Configuração completa de uma vez:
cd ~/git/teaching/big_data
git init
git add .
git commit -m "Initial commit"
git branch -m main
git remote add origin https://github.com/pedrosobreiro/big_data.git
git push -u origin main
```

## 🔄 Atualizações Futuras

```bash
# Adicionar novos ficheiros
git add .
git commit -m "Add new notebooks"
git push

# Ou em um comando:
git add . && git commit -m "Update" && git push
```
