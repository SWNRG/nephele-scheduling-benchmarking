from kubernetes import client, config
import logging

logger = logging.getLogger(__name__)

def parse_memory_intent (memory):
    """
    Parses memory intents and converts them to values. Intents to consider:
    'light': '500MiB',
    'small': '1GiB',
    'medium': '2GiB',
    'large': '8GiB'
    """
    try:
        if memory == "light":
            return "500Mi"
        elif memory == "small":
            return "1Gi"
        elif memory == "medium":
            return "2Gi"
        elif memory == "large":
            return "8Gi"
        else:
            return memory
    except Exception as e:
        logger.error(f"Failed to parse memory value '{memory}': {e}")
        raise


def parse_memory(memory):
    """
    Parses memory values and converts them to MiB. 
    """
    mem=parse_memory_intent(memory)
    try:
        if mem.endswith("n"):
            return int(mem[:-1]) // (1024 * 1024)
        elif mem.endswith("Ki"):
            return int(mem[:-2]) // 1024
        elif mem.endswith("Mi"):
            return int(mem[:-2])
        elif mem.endswith("Gi"):
            return int(mem[:-2]) * 1024
        elif mem.endswith("Ti"):
            return int(mem[:-2]) * 1024 * 1024
        elif mem.endswith("M"):
            return int(mem[:-1])
        else:
            return int(mem) // (1024 * 1024)
    except Exception as e:
        logger.error(f"Failed to parse memory value '{memory}': {e}")
        raise

def parse_cpu(cpu):
    """
    Parses CPU values and converts them to cores. Also, intents to support:
    'light': 0.5,
    'small': 1,
    'medium': 4,
    'large': 8
    """
    try:
        if cpu == "light":
            return 0.5
        elif cpu == "small":
            return 1
        elif cpu == "medium":
            return 4
        elif cpu == "large":
            return 8
        elif cpu.endswith("n"):
            return float(cpu[:-1]) / 1e9
        elif cpu.endswith("m"):
            return float(cpu[:-1]) / 1000
        else:
            return float(cpu)
    except Exception as e:
        logger.error(f"Failed to parse CPU value '{cpu}': {e}")
        raise

def get_cluster_metrics(context_name):
    """
    Fetches total and used resources for a cluster using the Kubernetes Metrics Server.
    Checks if cluster has GPU resources based on labels.
    """
    try:
        try:
            config.load_incluster_config() # runs inside k8s
        except config.ConfigException:
            logger.info("Falling back to local kubeconfig")
            try:
                contexts=""
                if context_name=="" or context_name==None:
                    logger.info("Looking up all existing contexts")
                    contexts, active_context = config.list_kube_config_contexts(config_file="/root/.kube/config")
                else:
                    config.load_kube_config(context="kwok-"+context_name, config_file="/root/.kube/config")
                    logger.info(f"Switched to context: {context_name}")
            except Exception as e:
                logger.error(f"Failed to load kubeconfig: {e}")
                raise

        # initialize cluster_metrics 
        cluster_metrics = {}
        if contexts=="" or contexts==None:
            calculate_cluster_metrics(cluster_metrics, context_name)
        else:
            for current_context in contexts:
                config.load_kube_config(context=current_context['name'], config_file="/root/.kube/config")
                calculate_cluster_metrics(cluster_metrics, current_context['name'])

        return cluster_metrics

    except Exception as e:
        logger.error(f"Error fetching node metrics: {e}")
        raise


def calculate_cluster_metrics(cluster_metrics, context_name):
    """
    Calculates cluster metricts for provided contexts or for active k8s
    config if contexts is empty.
    """
    try:
        v1_client = client.CoreV1Api()
        metrics_client = client.CustomObjectsApi()

        nodes = v1_client.list_node()
        #acluster_metrics = {}
        gpu_nodes = []

        total_cpu = 0
        total_memory = 0
        gpu = False
        used_cpu = 0
        used_memory = 0
        available_cpu = 0
        available_memory = 0

        for node in nodes.items:
            node_name = node.metadata.name
            labels = node.metadata.labels

            logger.info("Checking node "+node_name)

            # Skip master/control-plane and unschedulable nodes
            if "node-role.kubernetes.io/master" in labels or "node-role.kubernetes.io/control-plane" in labels:
                continue
            #if node.spec.unschedulable:
            #    continue

            logger.info("Go on...")

            capacity = node.status.capacity
            total_cpu = total_cpu + parse_cpu(capacity.get("cpu"))
            total_memory = total_memory + parse_memory(capacity.get("memory"))

            # Check if the node has GPU resources via labels
            if "nvidia.com/gpu.present" in labels or labels.get("accelerator", "") in ["nvidia-gpu", "gpu"]:
                gpu_nodes.append(node_name)
                gpu = True
            try:
                metrics = metrics_client.get_cluster_custom_object(
                    group="metrics.k8s.io",
                    version="v1beta1",
                    plural="nodes",
                    name=node_name,
                )

                used_cpu = used_cpu + parse_cpu(metrics["usage"]["cpu"])
                used_memory = used_memory + parse_memory(metrics["usage"]["memory"])
            except client.exceptions.ApiException as e:

                if e.status == 404:
                    #continue
                    used_cpu = 0
                    used_memory = 0
                else:
                    raise

            available_cpu = total_cpu - used_cpu
            available_memory = total_memory - used_memory

            cluster_metrics[context_name] = {
                "total_cpu": total_cpu,
                "total_memory": total_memory,
                "used_cpu": used_cpu,
                "used_memory": used_memory,
                "available_cpu": available_cpu,
                "available_memory": available_memory,
                "gpu": gpu,  
            }

        return cluster_metrics
    except Exception as e:
        logger.error(f"Error fetching cluster metrics: {e}")
        raise

def get_node_metrics(context_name):
    """
    Fetches total and used resources for all nodes using the Kubernetes Metrics Server.
    Checks if nodes have GPU resources based on labels.
    """
    try:
        try:
            config.load_incluster_config() # runs inside k8s
        except config.ConfigException:
            logger.info("Falling back to local kubeconfig")
            try:
                if context_name=="" or context_name==None:
                    config.load_kube_config(config_file="/root/.kube/config")
                    logger.info("Loaded default context from local kubeconfig")
                else:
                    config.load_kube_config(context="kwok-"+context_name, config_file="/root/.kube/config")
                    logger.info(f"Switched to context: {context_name}")
            except Exception as e:
                logger.error(f"Failed to load kubeconfig: {e}")
                raise

        v1_client = client.CoreV1Api()
        metrics_client = client.CustomObjectsApi()

        nodes = v1_client.list_node()
        node_metrics = {}
        gpu_nodes = []

        for node in nodes.items:
            node_name = node.metadata.name
            labels = node.metadata.labels

            logger.info("Checking node "+node_name)

            # Skip master/control-plane and unschedulable nodes
            if "node-role.kubernetes.io/master" in labels or "node-role.kubernetes.io/control-plane" in labels:
                continue
            #if node.spec.unschedulable:
            #    continue
 
            capacity = node.status.capacity
            total_cpu = parse_cpu(capacity.get("cpu"))
            total_memory = parse_memory(capacity.get("memory"))

            # Check if the node has GPU resources via labels
            if "nvidia.com/gpu.present" in labels or labels.get("accelerator", "") in ["nvidia-gpu", "gpu"]:
                gpu_nodes.append(node_name)

            try:
                metrics = metrics_client.get_cluster_custom_object(
                    group="metrics.k8s.io",
                    version="v1beta1",
                    plural="nodes",
                    name=node_name,
                )

                used_cpu = parse_cpu(metrics["usage"]["cpu"])
                used_memory = parse_memory(metrics["usage"]["memory"])
            except client.exceptions.ApiException as e:
                if e.status == 404:
                    #continue
                    used_cpu = 0
                    used_memory = 0
                else:
                    raise

            available_cpu = total_cpu - used_cpu
            available_memory = total_memory - used_memory

            node_metrics[node_name] = {
                "total_cpu": total_cpu,
                "total_memory": total_memory,
                "used_cpu": used_cpu,
                "used_memory": used_memory,
                "available_cpu": available_cpu,
                "available_memory": available_memory,
                "gpu": True if node_name in gpu_nodes else False,  
            }

        logger.info(f"GPU-enabled nodes: {gpu_nodes}")

        return node_metrics
    except Exception as e:
        logger.error(f"Error fetching node metrics: {e}")
        raise
