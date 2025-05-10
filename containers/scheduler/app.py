from flask import Flask, request, jsonify
import logging
from getResources import get_node_metrics, get_cluster_metrics, parse_memory, parse_cpu
from nodeplacement import heuristic
from clusterplacement import calculate_naive_placement, decide_placement, create_placement_input

# Setup Flask
app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@app.route("/nodemetrics", methods=["GET"])
def node_metrics():
    """
    Fetch and return node metrics from the Kubernetes cluster.
    """
    try:
        context_name = request.args.get("context")  # Get context from query parameter

        # Fetch metrics for all nodes
        node_metrics = get_node_metrics(context_name)
        return jsonify(node_metrics), 200
    except Exception as e:
        logger.error(f"Error in /nodemetrics API: {e}")
        return jsonify({"error": str(e)}), 500

@app.route("/clustermetrics", methods=["GET"])
def cluster_metrics():
    """
    Fetch and return cluster metrics from the Kubernetes cluster.
    """
    try:
        context_name = request.args.get("context")  # Get context from query parameter

        # Fetch metrics for all nodes
        cluster_metrics = get_cluster_metrics(context_name)
        return jsonify(cluster_metrics), 200
    except Exception as e:
        logger.error(f"Error in /clustermetrics API: {e}")
        return jsonify({"error": str(e)}), 500

@app.route("/nodeplacement", methods=["POST"])
def node_placement():
    try:
        context_name = request.args.get("context")  # Get context from query parameter

        # Parse input request
        data = request.get_json()
        if not data:
            logger.error("No JSON data received in request.")
            return jsonify({"error": "No JSON data received"}), 400

        # Log the received data
        logger.info(f"Received data: {data}")

        # Extract services and graph descriptor
        services = data.get("services", [])
        graph_descriptor = data.get("graph_descriptor", {})

        # Input validation
        if not isinstance(services, list):
            logger.error("'services' must be a list.")
            return jsonify({"error": "'services' must be a list"}), 400
        if not all(isinstance(service, dict) for service in services):
            logger.error("Each service in 'services' must be a dictionary.")
            return jsonify({"error": "Each service in 'services' must be a dictionary"}), 400
        if not isinstance(graph_descriptor, dict):
            logger.error("'graph_descriptor' must be a dictionary.")
            return jsonify({"error": "'graph_descriptor' must be a dictionary"}), 400

        # Fetch worker node metrics
        logger.info("Fetching worker node metrics...")
        worker_nodes = get_node_metrics(context_name)
        logger.info(f"Worker nodes: {worker_nodes}")

        # Converting services to appropriate format (integer cpu and memory)
        for service in services:
            logger.info("Service: "+str(service))
            for key, value in service.items():
                if key == "cpu":
                    service['cpu'] = parse_cpu(service['cpu'])
                if key == "memory":
                    service['memory'] = parse_memory(service['memory'])


        # Call the heuristic algorithm for placement
        logger.info("Calling heuristic algorithm for placement...")
        placement_result = heuristic(worker_nodes, services, graph_descriptor)

        # Handle placement failure
        if "error" in placement_result:
            logger.error(f"Placement error: {placement_result['error']}")
            return jsonify({"error": placement_result["error"]}), 400

        # Transform placement result into Helm values format
        helm_values = {}
        for service_id, node_name in placement_result.items():
            helm_values[service_id] = {
                "affinity": {
                    "nodeAffinity": {
                        "requiredDuringSchedulingIgnoredDuringExecution": {
                            "nodeSelectorTerms": [
                                {
                                    "matchExpressions": [
                                        {
                                            "key": "kubernetes.io/hostname",
                                            "operator": "In",
                                            "values": [node_name]
                                        }
                                    ]
                                }
                            ]
                        }
                    }
                }
            }

        # Return Helm values response
        logger.info(f"Generated Helm values: {helm_values}")
        return app.response_class(
            response=jsonify(helm_values).get_data(as_text=True),
            status=200,
            mimetype="application/json"
        )

    except Exception as e:
        logger.error(f"Error in /nodeplacement API: {e}")
        return jsonify({"error": str(e)}), 500

@app.route("/clusterplacement", methods=["POST"])
def cluster_placement():
    try:
        # Parse input request
        data = request.get_json()
        if not data:
            logger.error("No JSON data received in request.")
            return jsonify({"error": "No JSON data received"}), 400

        # Log the received data
        logger.info(f"Received data: {data}")

        # Extract services and graph descriptor
        services = data.get("services", [])
        graph_descriptor = data.get("graph_descriptor", {})

        # Input validation
        if not isinstance(services, list):
            logger.error("'services' must be a list.")
            return jsonify({"error": "'services' must be a list"}), 400
        if not all(isinstance(service, dict) for service in services):
            logger.error("Each service in 'services' must be a dictionary.")
            return jsonify({"error": "Each service in 'services' must be a dictionary"}), 400
        if not isinstance(graph_descriptor, dict):
            logger.error("'graph_descriptor' must be a dictionary.")
            return jsonify({"error": "'graph_descriptor' must be a dictionary"}), 400

        # Fetch cluster metrics
        logger.info("Fetching cluster metrics...")
        clusters = get_cluster_metrics(None)
        logger.info(f"Clusters: {clusters}")

        # Converting services to appropriate format (integer cpu and memory)
        for service in services:
            logger.info("Service: "+str(service))
            for key, value in service.items():
                if key == "cpu":
                    service['cpu'] = parse_cpu(service['cpu'])
                if key == "memory":
                    service['memory'] = parse_memory(service['memory'])

        # create decide_placement input format
        logger.info("Create decide_placement input format")
        cluster_cpu_capacities, cluster_memory_capacities, cluster_accelerations, cpu_limits, memory_limits, accelerations, replicas, current_placement = create_placement_input(clusters, services)

        # Call the decide_placement algorithm for placement
        logger.info("Calling decide_placement algorithm for placement...")
        placement_result = decide_placement (cluster_cpu_capacities, cluster_memory_capacities, cluster_accelerations, cpu_limits, memory_limits, accelerations, replicas, current_placement)

        # Handle placement failure
        if "error" in placement_result:
            logger.error(f"Placement error: {placement_result['error']}")
            return jsonify({"error": placement_result["error"]}), 400

        # Return placement response
        return app.response_class(
            response=jsonify(placement_result).get_data(as_text=True),
            status=200,
            mimetype="application/json"
        )

    except Exception as e:
        logger.error(f"Error in /clusterplacement API: {e}")
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
