#!/bin/bash

set -e

echo "🚀 Starting Blue-Green Deployment Setup on Minikube..."

minikube start --memory=8192 --cpus=4 --kubernetes-version=v1.28.0 --addons=ingress,metrics-server

# Install ArgoCD
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

# Install Prometheus and Grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install prometheus-stack prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --set grafana.adminPassword=admin123 \
    --set grafana.service.type=NodePort \
    --set prometheus.service.type=NodePort \
    --set alertmanager.service.type=NodePort \
    --wait

# Install Jenkins
helm repo add jenkins https://charts.jenkins.io
helm repo update
kubectl create namespace jenkins --dry-run=client -o yaml | kubectl apply -f -
helm upgrade --install jenkins jenkins/jenkins \
    --namespace jenkins \
    --values ci-cd/jenkins-values.yaml \
    --wait

# Deploy applications
kubectl apply -f manifests/blue-deployment.yaml
kubectl apply -f manifests/green-deployment.yaml
kubectl apply -f manifests/services.yaml

echo "🎉 Setup complete! Access info:"
echo "ArgoCD: $(minikube service argocd-server -n argocd --url)"
echo "Grafana: $(minikube service prometheus-stack-grafana -n monitoring --url)"
echo "Prometheus: $(minikube service prometheus-stack-kube-prom-prometheus -n monitoring --url)"
echo "Jenkins: $(minikube service jenkins -n jenkins --url)"
echo "Blue Environment: $(minikube service nginx-blue-service --url)"
echo "Green Environment: $(minikube service nginx-green-service --url)"
echo "Main Service: $(minikube service nginx-service --url)"

