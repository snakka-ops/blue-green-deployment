
# Blue-Green Deployment on Minikube with Jenkins, ArgoCD, Prometheus & Grafana

## Overview

This repository contains Kubernetes manifests, CI/CD pipelines, and monitoring configurations for implementing blue-green deployments on a Minikube cluster.

## Prerequisites

- Docker
- Minikube (>=v1.28)
- kubectl
- Helm
- Git

## Setup Instructions

1. Start Minikube:
./scripts/setup-minikube.sh


2. Access ArgoCD, Jenkins, and Monitoring Dashboards using URLs output by the setup script.

3. Commit changes to your repo trigger deployment pipelines in Jenkins.

4. Switch traffic between blue and green environments using:

./scripts/switch-traffic.sh blue|green|status


## Repository Structure

- `manifests/`: Kubernetes manifests for applications and ArgoCD.
- `monitoring/`: Prometheus and Grafana configs.
- `ci-cd/`: Jenkins pipeline and Helm config.
- `scripts/`: Helper scripts for environment setup and traffic switching.

## Monitoring & Alerts

Configure Prometheus alerting as per the rules in `monitoring/alerting-rules.yml`.

## License


This complete set of files will help you manage, version, and deploy your blue-green environment seamlessly with CI/CD, GitOps, and monitoring all integrated.
