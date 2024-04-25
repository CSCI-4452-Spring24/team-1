import boto3

def get_fargate_task_ip(cluster_name, service_name):
    # Create ECS and EC2 clients
    ecs_client = boto3.client('ecs')
    ec2_client = boto3.client('ec2')

    # Get the task ARN
    response = ecs_client.list_tasks(cluster=cluster_name, serviceName=service_name)
    tasks = response['taskArns']
    if not tasks:
        return "No tasks found for this service.", None

    # Describe the task to get network interface details
    task_desc = ecs_client.describe_tasks(cluster=cluster_name, tasks=tasks)
    eni_id = None
    for attachment in task_desc['tasks'][0]['attachments'][0]['details']:
        if attachment['name'] == 'networkInterfaceId':
            eni_id = attachment['value']
            break

    if not eni_id:
        return "No network interface found for this task.", None

    # Describe network interfaces to get public IP
    eni_desc = ec2_client.describe_network_interfaces(NetworkInterfaceIds=[eni_id])
    public_ip = eni_desc['NetworkInterfaces'][0].get('Association', {}).get('PublicIp', None)
    
    return "IP Address fetched successfully.", public_ip
