import logging
from math import sqrt


logger = logging.getLogger(__name__)

def heuristic(worker_nodes, services, graph_descriptor=None):
    """
    Heuristic algorithm to map services to worker nodes, considering CPU, memory, and GPU requirements.
    """
    try:
        logger.info("Starting heuristic algorithm for service placement...")
        logger.info(f"Worker nodes received: {worker_nodes}")
        logger.info(f"Services received: {services}")

        # Validate and clean worker_nodes
        valid_nodes = []
        for node_name, resources in worker_nodes.items():
            if isinstance(resources, dict):
                if 'available_cpu' in resources and 'available_memory' in resources:
                    valid_nodes.append((node_name, resources))
                else:
                    logger.error(f"Missing keys in worker node '{node_name}': {resources}")
            else:
                logger.error(f"Invalid format for worker node '{node_name}': {resources}")

        if not valid_nodes:
            logger.error("No valid worker nodes available.")
            return {"error": "No valid worker nodes available."}

        # Sort nodes and services
        sorted_nodes = sorted(valid_nodes, key=lambda x: (
            x[1].get('available_cpu', 0), x[1].get('available_memory', 0)), reverse=True)
        logger.info(f"Sorted nodes: {sorted_nodes}")

        sorted_services = sorted(services, key=lambda x: (x.get('gpu', 0), x['cpu'], x['memory']), reverse=True)
        logger.info(f"Sorted services: {sorted_services}")

        # Track temporary resource usage
        temporary_load = {node[0]: {'cpu': 0, 'memory': 0, 'gpu': 0} for node in sorted_nodes}
        service_mapping = {}

        # Map services to nodes
        for service in sorted_services:
            requires_gpu = service.get("gpu", 0) == 1
            service_mapped = False

            for node_name, resources in sorted_nodes:
                node_has_gpu = resources.get("gpu", 0) > 0
                if (
                    temporary_load[node_name]['cpu'] + service['cpu'] <= resources['available_cpu'] and
                    temporary_load[node_name]['memory'] + service['memory'] <= resources['available_memory'] and
                    (not requires_gpu or node_has_gpu)  # GPU validation
                ):
                    # Map the service to this node
                    service_mapping[service['id']] = node_name
                    temporary_load[node_name]['cpu'] += service['cpu']
                    temporary_load[node_name]['memory'] += service['memory']
                    if requires_gpu:
                        temporary_load[node_name]['gpu'] += 1
                    service_mapped = True
                    logger.info(f"Service '{service['id']}' mapped to node '{node_name}'")
                    break

            if not service_mapped:
                logger.error(f"Service '{service['id']}' cannot be mapped to any node.")
                return {"error": f"Insufficient resources for service '{service['id']}'"}

        logger.info("All services successfully placed.")
        logger.info(f"Service mapping: {service_mapping}")
        return service_mapping

    except Exception as e:
        logger.error(f"Error in heuristic: {e}")
        raise

def cosine_similarity(vector1, vector2):
    """
    Calculate cosine similarity between two vectors.
    """
    try:
        dot_product = sum(v1 * v2 for v1, v2 in zip(vector1, vector2))
        magnitude1 = sqrt(sum(v**2 for v in vector1))
        magnitude2 = sqrt(sum(v**2 for v in vector2))
        if magnitude1 == 0 or magnitude2 == 0:
            return 0  # Avoid division by zero
        return dot_product / (magnitude1 * magnitude2)
    except Exception as e:
        logger.error(f"Error in cosine similarity calculation: {e}")
        return 0


def cosine_similarity_placement(service, worker_nodes):
    """
    Calculate cosine similarity between a request and cluster's nodes.
    """
    try:
        service_vector = [service.get('cpu', 0), service.get('memory', 0), service.get('gpu', 0)]
        placement_scores = {}

        for node_name, resources in worker_nodes.items():
            available_vector = [
                resources.get('available_cpu', 0),
                resources.get('available_memory', 0),
                resources.get('gpu', 0)
            ]
            similarity = cosine_similarity(service_vector, available_vector)
            placement_scores[node_name] = similarity
            logger.info(f"Cosine similarity for service and node '{node_name}': {similarity}")

        return placement_scores

    except Exception as e:
        logger.error(f"Error in cosine similarity calculation for nodes: {e}")
        raise


def manhattan_distance(vector1, vector2):
    """
    Calculate Manhattan Distance between two vectors.
    """
    try:
        return sum(abs(v1 - v2) for v1, v2 in zip(vector1, vector2))
    except Exception as e:
        logger.error(f"Error in Manhattan distance calculation: {e}")
        return float('inf')


def manhattan_distance_placement(service, worker_nodes):
    """
    Calculate cosine similarity between a request and cluster's nodes.
    """
    try:
        service_vector = [service.get('cpu', 0), service.get('memory', 0), service.get('gpu', 0)]
        distance_scores = {}

        for node_name, resources in worker_nodes.items():
            available_vector = [
                resources.get('available_cpu', 0),
                resources.get('available_memory', 0),
                resources.get('gpu', 0)
            ]
            distance = manhattan_distance(service_vector, available_vector)
            distance_scores[node_name] = distance
            logger.info(f"Manhattan distance for service '{service['id']}' and node '{node_name}': {distance}")

        return distance_scores

    except Exception as e:
        logger.error(f"Error in Manhattan distance calculation for nodes: {e}")
        raise
