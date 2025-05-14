# Nephele-Scheduling-Benchmarking

This repository contains MCBench, an experimentation framework that simulates large-scale multi-cluster Kubernetes deployments, while maintaining a real control-plane. MCBench is suitable for the experimentation of NEPHELE scheduling algorithms, including both for inter- and intra-cluster levels.

## Features
The basic features of MCBench are:
1. **Flexible and Configurable Scenarios**:
   - Users can define flexible experimentation scenarios, stressing both cluster and node placement mechanisms under varying cluster resources and service graph configurations.
2. **Resource-efficient Experimentation**:
   - MCBench supports scalable Kubernetes clusters with emulated Pod deployments, empowering the simulation of distributed environments on a single laptop.
3. **Control Plane Realism**:
   - The framework is feature-rich at the control plane level, enabling the realistic evaluation of Kubernetes scheduling mechanisms.
4. **Heterogeneous Service Graphs**:
   - It supports the definition and dynamic deployment of heterogeneous service graphs, based on scheduling mechanisms exploiting real-time monitoring data.
5. **Interoperability with Real Schedulers**:
   - MCBench integrates with NEPHELE’s scheduling algorithms directly, without modification, targeting a similar behavior between simulated and real deployments.
6. **Automated Reporting**:
   - It supports configurable metrics and graphical figures for automated visualization, i.e., experiments are executed through a single command and produce a PDF report with the achieved measurements.

## Setup Instructions

### Prerequisites
Here, you can find basic installation instructions for the prerequesites, including `jq`, `curl`, `wget`, `docker`, and `kwok`.

- `jq`, `curl` and `wget`
MCBench requires some basic tools to be installed. Example installation instructions, i.e., for Ubuntu Linux, follow:
```
sudo apt-get update
sudo apt-get install jq curl wget
```

- `Docker`
You should install Docker.
  - Set up Docker's apt repository.
```
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```
  - To install the latest version, run:
```
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
  - Create appropriate permissions:
```
sudo groupadd docker
sudo usermod -aG docker $USER
```
  - Log out and log back in so that your group membership is re-evaluated.
  - Verify that the installation is successful by running the hello-world image:
```
sudo docker run hello-world
```

- Kubernetes WithOut Kubelet (Kwok) toolkit:
The basic instructions on how to install Kwok toolkit follow.
  - Variables preparation
```
# KWOK repository
KWOK_REPO=kubernetes-sigs/kwok
# Get latest
KWOK_LATEST_RELEASE=$(curl "https://api.github.com/repos/${KWOK_REPO}/releases/latest" | jq -r '.tag_name')
```
  - Install `kwokctl`
```
wget -O kwokctl -c "https://github.com/${KWOK_REPO}/releases/download/${KWOK_LATEST_RELEASE}/kwokctl-$(go env GOOS)-$(go env GOARCH)"
chmod +x kwokctl
sudo mv kwokctl /usr/local/bin/kwokctl
Install kwok #
```
  - Install `kwok`
```
wget -O kwok -c "https://github.com/${KWOK_REPO}/releases/download/${KWOK_LATEST_RELEASE}/kwok-$(go env GOOS)-$(go env GOARCH)"
chmod +x kwok
sudo mv kwok /usr/local/bin/kwok
```

---

### Installation of MCBench
You should clone MCBench's gitlab repository first:

```
git clone https://gitlab.eclipse.org/eclipse-research-labs/nephele-project/nephele-scheduling-benchmarking.git
```
Then you can move to the directory `nephele-schedulink-benchmarking` and start executing experiments, after configuring them.


## Configuring experiments
A user can configure experiments in two ways, corresponding to a single experimental run or an experimentation scenario (i.e., ranging a particular configuration parameter).

### Execution of a single experimental run

Basic configuration parameters:

```
# service placement period (in secs) - only if it is not already set
: "${placement_period:=120}"

# format of experiment output (e.g., json) - only if it is not alread set
: "${output_format:=json}"
```

Infrastructure configuration:

```
cluster_names=("cluster1" "cluster2" "cluster3")  
cluster_nodes=(2 2 2) 
cluster_cpu=(32 32 32)  # total cpu is 3 * 64 = 192
cluster_memory=("256Gi" "256Gi" "256Gi")  
cluster_pods=(100 100 100)   
cluster_gpus=(0 0 0)
```

Services configuration:
```
services_names_sets=("lightmemory heavymemory lightcpu mediummemory secondlightmemory" "mediumcpu secondheavymemory heavycpu secondmediumcpu secondlightcpu") 
services_dependencies_sets=("heavymemory heavymemory mediumcpu mediumcpu heavycpu" "heavycpu heavycpu heavycpu heavycpu heavycpu")
services_cpu_sets=("light light light light light" "medium light large medium light") # total cpu is 21 * 28 = 588
services_memory_sets=("light large light medium light" "light large light light light")
services_replicas_sets=("21 21 21 21 21" "21 21 21 21 21") 
services_gpus_sets=("0 0 0 0 0" "0 0 0 0 0") 
```

Basic supported intents are for CPU: (i) `light`, which corresponds to 0.5 vCPUs; (ii) `small`, means 1 vCPU; (iii) `medium`, is translated to 4 vCPUs; and (iv) `large`, which reflects 8 vCPUs. The equivalent intents for Memory are: (i) `light`, which corresponds to 500MiBs; (ii) `small`, is translated to 1GiB; (iii) `medium`, meaning 2GiB; and (iv) `large`, which is 8GiB. The user can specify both quality (i.e., intents) and qualitative values (e.g., 2 vCPUs and 8GiB Memory). 

### Execution of an experimentation scenario

Basic configuration parameters:
```
# specify run ids (check reconfigureExperiment.sh)
runs=("clusters-3" "clusters-5" "clusters-10")

# number of replications
replications_number=10

# name of experiment
experiment_name="range-clusters"

# wait time between experiments
experiment_wait_time=60

# service placement period (in secs)
placement_period=120

# format of experiment output (e.g., json)
output_format='json'
```

Configuring Metrics:
```
metrics='{
  "placement-times": {
    "values": [
      ".placements.clusterPlacementTime",
      ".placements.nodePlacementTime"
    ],
    "columns": [
      "clusters",
      "cluster-placement-time",
      "node-placement-time"
    ],
    "rows": "Cluster and Node Placement Times (s)"
  },
...
```

Configuring graphical figures:
```
graphs='[
    {
        "name": "placement-times",
        "filename": "placement-times.csv",
        "title": "",
        "striptitle": "yes",
        "transpose": "no",
        "filterkeyword": "no",
        "removekeyword": "no",
        "xlabel": "Service Replicas Number",
        "ylabel": "Time (s)",
        "xrange": "auto",
        "yrange": "auto",
        "boxvertical": "top",
        "boxhorizontal": "left",
        "boxlegend": "cluster-placement-time 2 node-placement-time 3",
        "xticksrotate": "-45 scale 0"
    },
...
```

### 🚀 Relevant Projects

We thank the following projects that we have used or inspired us for the creation of MCBench:

- **[Kubernetes WithOut Kubelet (Kwok)](https://kwok.sigs.k8s.io/)**  
  *Suitable for the deployment of lightweight Kubernetes multi-cluster infrastructures and the experimentation of control plane mechanisms.*

- **[NEPHELE](https://gitlab.eclipse.org/eclipse-research-labs/nephele-project)**  
  *The GitLab webpage of NEPHELE open-source platform.*

- **[NEPHELE inter-cluster placement mechanism](https://gitlab.eclipse.org/eclipse-research-labs/nephele-project/smo/-/blob/main/src/utils/placement.py)**  
  *The inter-cluster placement mechanism of NEPHELE.*

- **[NEPHELE intra-cluster placement mechanism](https://gitlab.eclipse.org/eclipse-research-labs/nephele-project/nephele-cluster-scheduler)**  
  *The intra-cluster placement mechanism of NEPHELE.*

- **[CODECO Experimentation Framework (CODEF)](https://gitlab.eclipse.org/eclipse-research-labs/codeco-project/experimentation-framework-and-demonstrations/experimentation-framework.git)**  
  *The CODECO Experimentation Framework (also referred to as CODEF) is an open-source solution for the rapid experimentation of K8s-based edge cloud deployments.*

- **[ClusterSlice](https://github.com/SWNRG/clusterslice)**  
  *ClusterSlice is an open-source solution for large-scale, Kubernetes-centered experimentation.*

## Contact
Contact [Lefteris Mamatas](https://sites.google.com/site/emamatas/) from the University of Macedonia, Greece.
