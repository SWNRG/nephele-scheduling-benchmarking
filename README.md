# Nephele-Cluster-Scheduler

This repository contains a Flask-based API for Kubernetes that retrieves node metrics, calculates resource availability, and performs service placement using a heuristic algorithm. The API exposes endpoints to retrieve node metrics and compute placement decisions for services based on their resource demands.


## Features

1. **Fetch Node Cluster Resources**:
   - Retrieves total, used, and available resources (CPU, Memory) from the Kubernetes Metrics Server and also identify if the cluster is GPU enabled.
   - Excludes control-plane nodes and unschedulable nodes.
2. **Service Placement**:
   - Accepts service resource requirements via a `POST` API.
   - Performs heuristic placement based on available resources and dependency constraints.
   - Returns placement decisions and Helm chart-compatible node affinity configurations.

3. **Exposed API Endpoints**:
   - `/metrics` - Fetches and returns node metrics.
   - `/placement` - Calculates service placement and returns placement decisions and Helm chart values.

## Setup Instructions

### Prerequisites
- A Kubernetes cluster with:
  - **Metrics Server** installed and running. You can install Metric Server using Helm. 
```
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
```
```
helm upgrade --install metrics-server metrics-server/metrics-server
```
  - The **Nephele Cluster Scheduler** helm.
- Docker installed on your local machine to build the image.

---
### Installation


```
helm package nephele-cluster-scheduler
```

```
helm install nephele-scheduler nephele-cluster-scheduler-0.1.0.tgz
```

```
helm status nephele-scheduler
```


### Test

To test the code run:

```
./request.sh

```


## Project status
This is work in progress
