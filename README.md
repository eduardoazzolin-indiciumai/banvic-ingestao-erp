## instalação

### 1. Ambiente base

#### 1.1. Iniciar Minikube

```bash
minikube start --cpus 6 --memory 8192
```

#### 1.2. Criar um namespace

```
kubectl create namespace airflow
```

### 2. Configurar Airflow

#### 2.1. Configurar secrets

Substitua "INSIRA_SENHA_SEGURA" por uma senha de sua preferência.

```bash
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

### 3. Configurar servidor SFTP (source)

#### 3.1. Configurar secrets

Substitua "INSIRA_SENHA_SEGURA" por uma senha de sua preferência.

```bash
kubectl create secret generic sftp-credentials \
  --from-literal=password=INSIRA_SENHA_SEGURA \
  --from-literal=username=banvic_erp \
  -n airflow
```

#### 3.2. Implantar servidor SFTP

```bash
kubectl apply -f ./k8s/sftp-server/sftp-server.yaml
```

#### 3.3. Copiar arquivos

```bash
kubectl cp ./data/ $(kubectl get pods -n airflow -l app=sftp-server -o jsonpath='{.items[0].metadata.name}'):/home/banvic_erp/upload -n airflow
```

### 4. Configurar banco PostgreSQL (target)

#### 4.1. Configurar secrets

Substitua "INSIRA_SENHA_SEGURA" por uma senha de sua preferência.

```bash
kubectl create secret generic postgres-credentials \
  --from-literal=password=INSIRA_SENHA_SEGURA \
  --from-literal=username=banvic_dw_user \
  --from-literal=dbname=banvic_dw \
  -n airflow
```

#### 4.2. Implantar PostgreSQL

```bash
kubectl apply -f k8s/postgres/
```

#### 5. Configurar o Embulk

#### 5.1. Gerar imagem do embulk

```bash
eval $(minikube docker-env)
docker build -t embulk-ingestion:latest ./ingestion
```

### Acessar os serviços

```bash
# airflow
kubectl port-forward svc/airflow-webserver 8080:8080 --namespace airflow > /dev/null 2>&1 &

# postgres target
kubectl port-forward svc/postgres-target 5432:5432 --namespace airflow > /dev/null 2>&1 &

# parar port-forward
killall kubectl
```

```bash
# 1. Copia para o Scheduler (para o código rodar)
kubectl cp ./dags airflow-scheduler-0:/opt/airflow -n airflow

# 2. Copia para o Webserver dinamicamente (para o código aparecer na tela)
kubectl cp ./dags $(kubectl get pods -n airflow -l component=webserver -o jsonpath='{.items[0].metadata.name}'):/opt/airflow -n airflow

kubectl exec -it airflow-scheduler-0 -n airflow -- airflow dags reserialize
```