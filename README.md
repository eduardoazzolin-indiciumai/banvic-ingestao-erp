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
