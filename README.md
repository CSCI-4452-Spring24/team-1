# Author

- **Trey Hollander** - [treyhollander](https://github.com/treyhollander)
- **Shijun Jiang** - [sejohng](https://github.com/sejohng)
# Intro

The goal of this project is to create a group of users who only interface with the system through a UI to deploy different Game Servers to AWS. The idea of this would be to have a singular UI which users could log into and have a credit balance on which determines how long they can have servers deployed for. That way instead of needing to buy/provision multiple dedicated servers for each game, users could instead charge a generic run time balance and deploy whichever game they wanted.

**GUI Hosting**: Utilizes *Flask* for hosting a graphical user interface (GUI). The layout for this GUI is stored within the templates directory.

**Flask Application**: The main *Flask code* is contained in the flask_test.py file, serving as the entry point for the application.

**Terraform Interaction**: The *buttons.py* module is a Python implementation designed for initiating Terraform instances, enabling interaction between Python and Terraform.

**K8s Operations**: The *k8s_util.py* file contains logic for managing Kubernetes resources, specifically for starting or stopping servers as required by the application.

**Terraform Configuration**: A test project for Terraform is described in the *main.tf* file, representing an experimental setup to achieve integration between Python and Terraform, which is currently the primary challenge being addressed.
