# ajustar minikube
minikube delete
minikube start --cpus 6 --memory 8192

# instalar airflow
versão airflow 2.10.5
```bash

kubectl create namespace airflow

helm install airflow apache-airflow/airflow \
  --version 1.16.0 \
  -f k8s/airflow/values.yaml \
  -n airflow
  ```

# abrir airflow interface
```bash
kubectl port-forward svc/airflow-webserver 8080:8080 --namespace airflow
```

# POSTGRES TARGET
## criar secret postgresql-target
```bash
kubectl create secret generic postgres-credentials \
  --from-literal=username=ESCOLHA_UM_USERNAME \
  --from-literal=password=ESCOLHA_UM_PASSWORD \
  --from-literal=dbname=banvic_dw \
  -n airflow
```

## implantar
```bash
kubectl apply -f k8s/postgres/
```