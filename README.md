## instalação

### 1. Ambiente base

#### 1.1. Iniciar Minikube

```bash
minikube start --cpus 6 --memory 8192
```


### 3. Configurar servidor SFTP (source)

#### 3.1. Configurar namespace e secrets

Substitua "INSIRA_SENHA_SEGURA" por uma senha de sua preferência.

```bash
kubectl create namespace sftp

kubectl create secret generic sftp-credentials \
  --from-literal=password=INSIRA_SENHA_SEGURA \
  --from-literal=username=banvic_erp \
  -n sftp
```

#### 3.2. Implantar servidor SFTP

```bash
kubectl apply -f ./k8s/sftp-server/sftp-server.yaml
```

#### 3.3. Copiar arquivos

```bash
kubectl cp ./data/ $(kubectl get pods -n sftp -l app=sftp-server -o jsonpath='{.items[0].metadata.name}'):/home/banvic_erp/upload -n sftp
```

### 4. Configurar banco PostgreSQL (target)

#### 4.1. Configurar namespace e secrets

Substitua "INSIRA_SENHA_SEGURA" por uma senha de sua preferência.

```bash
kubectl create namespace dw

kubectl create secret generic postgres-credentials \
  --from-literal=password=INSIRA_SENHA_SEGURA \
  --from-literal=username=banvic_dw_user \
  --from-literal=dbname=banvic_dw \
  -n dw
```

#### 4.2. Implantar PostgreSQL

```bash
kubectl apply -f k8s/postgres/
```

### 2. Configurar Airflow

#### 2.1. Configurar namespace e secrets

Substitua "INSIRA_SENHA_SEGURA" por uma senha de sua preferência.

```bash
kubectl create namespace airflow

kubectl create secret generic airflow-webserver-password \
  --from-literal=password=INSIRA_SENHA_SEGURA \
  -n airflow
```

#### 2.2. Implantar Airflow

Versão airflow 2.10.5

```bash
helm install airflow apache-airflow/airflow \
  --version 1.16.0 \
  -f k8s/airflow/values.yaml \
  -n airflow
```

#### 2.3. Criar Connections


**1. Conexão com o Data Warehouse (PostgreSQL):**
Substitua "INSIRA_SENHA_SEGURA" pela mesma senha definida na criação do secret do DW.

```bash
kubectl exec -it airflow-scheduler-0 -n airflow -- airflow connections add 'dw_postgres' \
  --conn-type 'postgres' \
  --conn-host 'postgres-target.dw.svc.cluster.local' \
  --conn-login 'banvic_dw_user' \
  --conn-password 'INSIRA_SENHA_SEGURA' \
  --conn-schema 'banvic_dw' \
  --conn-port '5432'
```

**2. Conexão com a Origem (SFTP):**
Substitua "INSIRA_SENHA_SEGURA" pela mesma senha definida na criação do secret do SFTP.

```bash
kubectl exec -it airflow-scheduler-0 -n airflow -- airflow connections add 'sftp_erp' \
  --conn-type 'sftp' \
  --conn-host 'sftp-server.sftp.svc.cluster.local' \
  --conn-login 'banvic_erp' \
  --conn-password 'INSIRA_SENHA_SEGURA' \
  --conn-port '22'
```


#### Copiar DAGs
Em produção utilizaria um gitsync
```bash
# 1. Copia para o Scheduler (para o código rodar)
kubectl cp ./dags airflow-scheduler-0:/opt/airflow -n airflow

# 2. Copia para o Webserver dinamicamente (para o código aparecer na tela)
kubectl cp ./dags $(kubectl get pods -n airflow -l component=webserver -o jsonpath='{.items[0].metadata.name}'):/opt/airflow -n airflow

kubectl exec -it airflow-scheduler-0 -n airflow -- airflow dags reserialize
```

#### Criar Connections




#### 5. Configurar o Embulk

#### 5.1. Gerar imagem do embulk

```bash
eval $(minikube docker-env)
docker build -t embulk-ingestion:latest ./ingestion
```

### Acessar os serviços

```bash
killall kubectl
# airflow
kubectl port-forward svc/airflow-webserver 8080:8080 --namespace airflow > /dev/null 2>&1 &

# postgres target
kubectl port-forward svc/postgres-target 5432:5432 --namespace dw > /dev/null 2>&1 &

# parar port-forward
```

