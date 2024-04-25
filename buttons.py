import subprocess
from pathlib import Path

def start_minecraft_server():
    """Starts a new Minecraft server on AWS EC2 using Terraform."""
    try:
        # Define init path for Terraform initialize MC Server
        print("Server start code initialized a new fresh Minecraft Server will be deployed for you on AWS")

#Pathlib to construct this
        terraform_dir = Path(r"C:\Users\treyh\PycharmProjects\DCSGUI1") 
        # Initialize Terraform (if needed)
        #subprocess.run(['terraform', 'init'], cwd=terraform_dir, check=True)
        subprocess.run(['terraform', 'init'], cwd=str(terraform_dir), check=True)
        # Apply the Terraform configuration
        subprocess.run(['terraform', 'apply', '-auto-approve'], cwd=terraform_dir, check=True)
        return True, "Server starting process initiated."
    except subprocess.CalledProcessError as e:
        return False, f'An error occurred: {str(e)}'