from kubernetes import client, config

def start_server():
    """Scales up the Kubernetes deployment for the Minecraft server to 1 pod."""
    try:
        # Loads the Kubernetes configuration from ~/.kube/config
        # For in-cluster configuration, use config.load_incluster_config()
        config.load_kube_config()

        # Define the namespace and deployment details
        #This is where we build in the naming convention of user#-minecraft# to determine which server to start
        #May need to build out secondary UI for server selection
        namespace = 'default'
        deployment_name = 'minecraft-server'

        # Create a Kubernetes API client
        apps_v1 = client.AppsV1Api()

        # Patch the deployment to scale up
        patch = {
            "spec": {
                "replicas": 1
            }
        }
        response = apps_v1.patch_namespaced_deployment_scale(
            name=deployment_name,
            namespace=namespace,
            body=patch
        )
        return True, "Server started successfully."
    except Exception as e:
        return False, str(e)