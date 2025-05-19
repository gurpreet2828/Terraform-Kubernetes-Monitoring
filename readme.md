
# **Monitor Kubernetes Cluster with Prometheus and Grafana**

## **Summary**

This report outlines the process of monitoring a Kubernetes cluster using Prometheus and Grafana. The deployment is performed using Terraform and Kubernetes, with the infrastructure provisioned on AWS. Key steps include setting up Terraform and AWS CLI, provisioning Kubernetes master and worker nodes, installing necessary dependencies, and deploying a React application. The monitoring stack consists of Prometheus for metrics collection and Grafana for data visualization. Helm is utilized for package management, streamlining the installation of both Prometheus and Grafana.

## **Main steps of the report, summarized:** {#main-steps-of-the-report-summarized .unnumbered}

### 1.  **Transfer Files from Windows to Linux Machine:**

- Use scp to transfer Terraform and Docker files to the Ubuntu instance.

- Set appropriate permissions using chown and chmod.

### 2.  **Install Terraform and AWS CLI:**

- Install Terraform and verify its installation.

- Install AWS CLI, create AWS account, and configure CLI with access keys.

### 3.  **Assign Elastic IP to EC2 Instance:**

- Allocate and associate an Elastic IP to ensure a consistent public IP address.

### 4.  **Provision AWS Infrastructure using Terraform:**

- Initialize, validate, and apply the Terraform configuration.

- Output displays IP addresses of Kubernetes master and worker nodes.

### 5.  **Connect to Kubernetes Master Node:**

- SSH into the Kubernetes master node using the public IP address.

### 6.  **Install and Configure Kubernetes Master Node:**

- Update the system, disable swap, install containerd, and Kubernetes components (kubeadm, kubelet, kubectl).

### 7.  **Initialize Kubernetes Cluster and Install Calico Network:**

- Create a Kubernetes configuration file and initialize the cluster.

- Install Calico network plugin and verify node status.

### 8.  **Connect and Configure Worker Node:**

- Install necessary dependencies and join the worker node to the master node using the provided join command.

### 9.  **Deploy React Application:**

- Create a YAML file for the React app deployment and expose it via NodePort.

- Access the app through the NodePort on both master and worker nodes.

### 10. **Implement Helm for Package Management:**

- Install Helm and create a role for the default service account.

### 11. **Install and Configure Prometheus:**

- Add the Prometheus Helm repository and install Prometheus using a custom YAML configuration.

- Expose Prometheus through NodePort for external access.

### 12. **Install and Configure Grafana:**

- Add Grafana Helm repository and install Grafana with custom configurations.

- Expose Grafana using NodePort and configure the Prometheus data source.

- Import pre-built Grafana dashboards for visualization.

### 13. **Clean Up Resources:**

- Destroy the provisioned infrastructure using the terraform destroy command to prevent unnecessary costs

## **Step 1: Transfer Files from Windows to Linux Machine** {#step-1-transfer-files-from-windows-to-linux-machine .unnumbered}

Use `scp` to transfer your Terraform and Docker files from your local machine to your Ubuntu instance.  
**Note:** Run the following command in Command Prompt (CMD) to copy the Terraform and Kubernetes code to your Linux machine:

```shell
scp -r -v "C:\Users\Gurpreet\OneDrive\Desktop\York Univ\Assignments\Assignment-7-Kubernetes\Terraform-Kubernetes" administrator@10.0.0.83:/home/administrator/
```

![Image1](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/aa52954a0f3867382ba343528973d727b9a48d82/Images/Image1.png)

After entering the password, you will be logged into your Ubuntu Linux machine and will see the files in your home directory as shown below

![Image2](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/aa52954a0f3867382ba343528973d727b9a48d82/Images/Image2.png)

**Note:** To avoid permission issues, please run the following commands to ensure the appropriate permissions are set:

```shell
sudo chown -R administrator:administrator /home/administrator/Terraform-Kubernetes
sudo chmod -R u+rwx /home/administrator/Terraform-Kubernetes
```

These commands will assign ownership to the administrator user and grant the necessary read, write, and execute permissions for the Terraform-Kubernetes directory.

## **Step 2: Install Terraform and AWS Command Line Interface (CLI)**

### **1. Update and install dependencies**

```shell
sudo apt update && sudo apt install -y gnupg software-properties-common curl
```

### **2. Add the HashiCorp GPG key**

```shell
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

### **3. Add the HashiCorp repo**

```shell
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
```

```shell
sudo tee /etc/apt/sources.list.d/hashicorp.list
```

### **4. Update and install Terraform**

```shell
sudo apt update
```

```shell
sudo apt install terraform -y
```

### **5. Verify installation**

```shell
terraform -v
```

![Image3](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/aa52954a0f3867382ba343528973d727b9a48d82/Images/Image3.png)

## AWSCLI Install

To install the AWS CLI, run the following command

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

Run the following command to check if AWS CLI is installed correctly:

```shell
aws –version
```

You see the following output

![Image4](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/aa52954a0f3867382ba343528973d727b9a48d82/Images/Image4.png)

## **Create AWS account**

After Creating

Click on account name - Select Security Credentials

![Image50](https://github.com/gurpreet2828/jenkins-cicd-terraform-aws/blob/51d4f14a4001b6679c4c4977191cf7a04ea76768/Images/Image50.png)

Click **Create access key**.

![Image51](https://github.com/gurpreet2828/Jenkins-CICD/blob/47b28cca86aff817a0d18ae3a7d99cb69b7591f3/Images/Image51.png)

**Note:** Download the key file or copy the Access Key ID & Secret Access Key (Secret Key is shown only once!).

After install and creating AWS account configure the AWS

Configure AWS CLI with the New Access Key

```shell
aws configure
```

It will prompt you for:

**1. AWS Access Key ID**: Your access key from AWS IAM.

**2. AWS Secret Access Key**: Your secret key from AWS IAM.

**3. Default region name**: (e.g., us-east-1, us-west-2).

**4. Default output format**: (json, table, text --- default is json).

***Enter access key and secret key which you will get from aws account***

**Check credentials added to aws configure correctly**:

```shell
aws sts get-caller-identity
```

If your AWS CLI is properly configured, you\'ll see a response like this:

![Image9](https://github.com/gurpreet2828/Terraform-Kubernetes/blob/9bc9affe2c6baf0846cd729b516f49e255c59c1e/Images/Image9.png)

## **Step 4: Provisioning AWS Infrastructure using Terraform**

1.  Terraform init

- prepares your environment and configures everything Terraform needs to
  interact with your infrastructure.

![A screenshot of a computer program AI-generated content may be
incorrect.](media/image9.png){width="7.5in"
height="4.134722222222222in"}

2.  terraform fmt

- used to **automatically format** your Terraform configuration files to
  a standard style. It ensures that your code is consistently formatted,
  making it easier to read and maintain.

3.  Terraform validate

- used to **check the syntax and validity** of your Terraform
  configuration files. It helps you catch errors in the configuration
  before you attempt to run other Terraform commands, like terraform
  plan or terraform apply.

![](media/image10.png){width="7.5in" height="0.5861111111111111in"}

4.  terraform plan

- used to **preview the changes** Terraform will make to your
  infrastructure based on the current configuration and the existing
  state. It shows what actions will be taken (such as creating,
  modifying, or deleting resources) when you apply the configuration

- Before running terraform apply to check exactly what changes Terraform
  will make.

> ***Before Running Terraform Plan must update the location of public
> and private ssh keys under modules -compute - variables.tf***
>
> ***As shown in following image***

![A screen shot of a computer AI-generated content may be
incorrect.](media/image11.png){width="7.5in" height="4.21875in"}

**After applying the Terraform plan, you will see the following
output:**

![A computer screen shot of a computer screen AI-generated content may
be incorrect.](media/image12.png){width="7.5in" height="4.21875in"}

**5:** Terraform apply

Provision terraform managed infrastructure. You must confirm by trying
**yes** if you would like to continue and perform the actions described
to provision your infrastructure resources

After successfully applying the Terraform configuration, you will see
the public IP addresses assigned to your Kubernetes master and node
instances as output.

![A computer screen shot of a computer screen AI-generated content may
be incorrect.](media/image13.png){width="7.5in" height="3.625in"}

**k8s-master-Public-IP**: The public IP address assigned to the
Kubernetes master node.

**k8s-node-Public-IP**: A list of public IP addresses assigned to the
Kubernetes worker nodes.

**You can log in to your AWS account to view the infrastructure
resources that have been provisioned.**

![A screenshot of a computer AI-generated content may be
incorrect.](media/image14.png){width="7.5in" height="4.21875in"}

##  {#section .unnumbered}

## **Step 5: Connect to K8s Master (Control Plane) Node**  {#step-5-connect-to-k8s-master-control-plane-node .unnumbered}

Using the public IP address provided in the Terraform output, connect to
the EC2 instance by executing the following command in your terminal:

ssh -i /root/.ssh/docker ec2-user@54.227.118.240

![A screenshot of a computer screen AI-generated content may be
incorrect.](media/image15.png){width="7.5in"
height="3.558333333333333in"}

## **Step 6: Install and Configure Kubernetes Master (Control Plane) Node** {#step-6-install-and-configure-kubernetes-master-control-plane-node .unnumbered}

**Follow these steps to set up the Kubernetes Control Plane node
effectively:**

**Update the System and Install Dependencies**

Run the following commands to update the system and install essential
packages:

sudo yum update -y

sudo yum install -y curl wget git

**Disable Swap**

Kubernetes disables swap to prevent unpredictable latency and ensure
consistent memory management across nodes. Swapping can bypass
Kubernetes\' memory limits, leading to instability and performance
degradation.

Kubernetes requires swap to be disabled. Execute:

sudo swapoff -a

sudo sed -i \'/ swap / s/\^\\.\*\\\$/#\1/g\' /etc/fstab

verify swap is disable

free -h

![](media/image16.png){width="7.5in" height="0.8381944444444445in"}

swapon --show

**Note:** If swap is disabled, this command will produce no output.

**Load Modules for containerd:**

Following commands are used to **load kernel modules** necessary for
container networking and filesystem overlay in a containerized
environment like **containerd** or **Kubernetes**.

Run the following commands

**sudo modprobe overlay**

\# Enables the overlay filesystem, which allows container runtimes to
layer filesystems efficiently.

**sudo modprobe br_netfilter**

\# Enables bridging between containers for networking, essential for
Kubernetes networking components like kube-proxy.

**Set Up sysctl Parameters for Kubernetes Networking**

cat \<\<EOF \| sudo tee /etc/sysctl.d/99-kubernetes-cri.conf

net.bridge.bridge-nf-call-iptables = 1

net.ipv4.ip_forward = 1

net.bridge.bridge-nf-call-ip6tables = 1

EOF

**Apply changes by running the following command**

sudo sysctl \--system

![A screen shot of a computer screen AI-generated content may be
incorrect.](media/image17.png){width="7.5in" height="4.21875in"}

**Verify Modules:**

Verify that the modules are loaded, by running the following command

lsmod \| grep overlay

lsmod \| grep br_netfilter

![A screen shot of a computer code AI-generated content may be
incorrect.](media/image18.png){width="6.233333333333333in"
height="1.2583333333333333in"}

**Download and Install the Latest cri-tools RPM:**

cd \~

curl -LO
https://download.opensuse.org/repositories/isv:/kubernetes:/core:/stable:/v1.30/rpm/x86_64/cri-tools-1.30.0-150500.1.1.x86_64.rpm

sudo yum localinstall -y cri-tools-1.30.0-150500.1.1.x86_64.rpm

sudo sysctl ---system

crictl \--version

![A screen shot of a computer AI-generated content may be
incorrect.](media/image19.png){width="7.5in" height="4.21875in"}

**Install containerd**

**Update the system:**

sudo yum update -y

**Install containerd:**

sudo yum install -y containerd

![A computer screen with white text AI-generated content may be
incorrect.](media/image20.png){width="7.5in"
height="3.7583333333333333in"}

**Create the configuration directory:**

sudo mkdir -p /etc/containerd

**Generate containerd configuration:**

containerd config default \| sudo tee /etc/containerd/config.toml

![A computer screen shot of a black screen AI-generated content may be
incorrect.](media/image21.png){width="7.5in" height="4.21875in"}

**Enable Conatinerd**

sudo systemctl enable containerd \--now

**Restart containerd:**

sudo systemctl restart containerd

**Verify containerd status:**

sudo systemctl status containerd

**Verify Version**

containerd \--version

![A computer screen with many text AI-generated content may be
incorrect.](media/image22.png){width="7.5in" height="4.21875in"}

**Install Kubernetes Components (kubeadm, kubelet, kubectl**

**Add Kubernetes repository:**

cat \<\<EOF \| sudo tee /etc/yum.repos.d/kubernetes.repo

\[kubernetes\]

name=Kubernetes

baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/

enabled=1

gpgcheck=1

gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key

exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni

EOF

![A screen shot of a computer screen AI-generated content may be
incorrect.](media/image23.png){width="7.5in"
height="3.183333333333333in"}

**Set SELinux in Permissive Mode**

sudo setenforce 0

sudo sed -i \'s/\^SELINUX=enforcing\$/SELINUX=permissive/\'
/etc/selinux/config

**Install kubeadm, kubelet, and kubectl**

sudo yum install -y kubelet kubeadm kubectl
\--disableexcludes=kubernetes

![A computer screen shot of a computer screen AI-generated content may
be incorrect.](media/image24.png){width="7.5in" height="4.21875in"}

**Enable and Start kubelet**

sudo systemctl enable \--now kubelet

![](media/image25.png){width="7.5in" height="0.3888888888888889in"}

## **Step 7: Initialize the Kubernetes Cluster and Install Calico Network** {#step-7-initialize-the-kubernetes-cluster-and-install-calico-network .unnumbered}

1.  **Create Kubeadm Config File:**

vi kube-config.yml

**Insert the following content in above yml file**

apiVersion: kubeadm.k8s.io/v1beta3

kubernetesVersion: 1.32.0

\# This is a configuration file for kubeadm to set up a Kubernetes
cluster.

kind: ClusterConfiguration

networking:

  podSubnet: 192.168.0.0/16

apiServer:

  extraArgs:

   service-node-port-range: 1024-1233

2.  **Initialize Kubernetes Cluster:**

sudo kubeadm init \--config kube-config.yml
\--ignore-preflight-errors=all

**Note:** The purpose of \--ignore-preflight-errors=all flag is to
ignore the K8s HW requirements

![A computer screen with white text on it AI-generated content may be
incorrect.](media/image26.png){width="7.5in"
height="3.908333333333333in"}

3.  **Set Up Kubernetes CLI Access:**

mkdir -p \$HOME/.kube

sudo cp -i /etc/kubernetes/admin.conf \$HOME/.kube/config

sudo chown \$(id -u):\$(id -g) \$HOME/.kube/config

4.  **Check Node Status:**

kubectl get nodes

![](media/image27.png){width="7.5in" height="0.7430555555555556in"}

5.  **Install Calico Network Plugin:**

kubectl apply -f <https://docs.projectcalico.org/manifests/calico.yaml>

![A computer screen with many white text AI-generated content may be
incorrect.](media/image28.png){width="7.5in" height="4.21875in"}

**Wait a few minutes, then verify the node status:** Run the following
command

kubectl get nodes

## ![A black screen with white text AI-generated content may be incorrect.](media/image29.png){width="7.5in" height="1.1in"} {#a-black-screen-with-white-text-ai-generated-content-may-be-incorrect. .unnumbered}

## **Step 8: Connect to K8s Worker Node** {#step-8-connect-to-k8s-worker-node .unnumbered}

1.  **Connect to Worker Node**

- Use the same steps as the Master node, using the worker node\'s public
  IP.

2.  **Install Kubernetes on Worker Node**

- Follow the same installation steps as for the Master Node to install
  containerd, kubeadm, kubelet, and kubectl.

## **Step 9: Join the Work Node to the Kubernetes Cluster**  {#step-9-join-the-work-node-to-the-kubernetes-cluster .unnumbered}

**Get Join Command from Master Node**

- On the master node, generate the join command by running the following
  command

kubeadm token create \--print-join-command

you will see like following

sudo kubeadm join 10.0.1.45:6443 \--token kl3rnb.gj2syfp4bjnri1xu
\--discovery-token-ca-cert-hash
sha256:0805a221754221c412c58ee47f3a38e7f2ccd9baaa3b57a3ede5fc8975de3189
\--ignore-preflight-errors=all

![A screen shot of a computer AI-generated content may be
incorrect.](media/image30.png){width="7.5in"
height="3.0416666666666665in"}

copy the above command and paste to your worker node

In the Master (Control Plane) Node, check the cluster status (It could
take few moments until the node become ready)

kubectl get nodes

![A computer screen shot of a black screen AI-generated content may be
incorrect.](media/image31.png){width="7.5in"
height="1.2166666666666666in"}

##  {#section-1 .unnumbered}

## **Step 10: Deploy React Application** {#step-10-deploy-react-application .unnumbered}

1.  **Create React Application YAML (react-app-pod.yml)**

> **Run the following command**
>
> vi react-app-pod.yml

apiVersion: v1

kind: Service

metadata:

name: react-app

spec:

type: NodePort

ports:

\- port: 80

targetPort: 80

nodePort: 1233

selector:

app: react-app

\-\--

apiVersion: apps/v1

kind: Deployment

metadata:

name: react-app

spec:

replicas: 1

selector:

matchLabels:

app: react-app

template:

metadata:

labels:

app: react-app

spec:

containers:

\- name: react-app

image: \<your-docker-hub-image\>

ports:

\- containerPort: 80

2.  **Apply the React App YAML**

kubectl create -f react-app-pod.yml

> ![A black screen with white text AI-generated content may be
> incorrect.](media/image32.png){width="7.5in"
> height="0.9381944444444444in"}

3.  **Verify Pods and Services**

> kubectl get pods
>
> ![A screenshot of a computer AI-generated content may be
> incorrect.](media/image33.png){width="7.5in"
> height="1.0819444444444444in"}
>
> kubectl get services
>
> ![A black screen with white text AI-generated content may be
> incorrect.](media/image34.png){width="7.5in"
> height="0.9722222222222222in"}

**Verify that the pod is up and running**

kubectl get pods -o wide

![](media/image35.png){width="7.5in" height="0.5326388888888889in"}

**Check communication with react-app pod**

curl \< react-app IP address\>

ex: curl 192.168.206.129

![A screen shot of a computer screen AI-generated content may be
incorrect.](media/image36.png){width="7.5in"
height="2.2534722222222223in"}

**Verify that the deployment complete**

kubectl get deployment

![A black screen with white text AI-generated content may be
incorrect.](media/image37.png){width="7.5in"
height="1.1847222222222222in"}

Go to the pubic IP of your Master server, worker node and port 1233
\<Public IP\>:1233. The sample react application should be running.

<http://54.227.118.240:1233/> \-\-- Public IP of master Node

<http://52.204.114.58:1233/> \-\-- Public of Node 1

<http://54.165.83.46:1233/> \-\-- Public Ip of Node 0

![A screenshot of a computer AI-generated content may be
incorrect.](media/image38.png){width="7.5in" height="4.21875in"}

## **Step 11: Implementing Helm: Installation and Configuration** {#step-11-implementing-helm-installation-and-configuration .unnumbered}

- **Helm** is a package manager for Kubernetes that simplifies the
  deployment, management, and scaling of applications in a Kubernetes
  cluster.

- It uses pre-configured application templates called **Charts**, which
  define the structure and configuration of Kubernetes resources.

###  {#section-2 .unnumbered}

### **Step 1: Download the Helm installation script.** {#step-1-download-the-helm-installation-script. .unnumbered}

curl -fsSL -o get_helm.sh
<https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3>

### **Step 2: Assign execute permissions to the script.** {#step-2-assign-execute-permissions-to-the-script. .unnumbered}

chmod 700 get_helm.sh

### **Step 3: Run the script to install Helm.** {#step-3-run-the-script-to-install-helm. .unnumbered}

./get_helm.sh

### **Step 4: Verify the installation.** {#step-4-verify-the-installation. .unnumbered}

helm version

![](media/image39.png){width="7.5in" height="0.6958333333333333in"}

### **Step 5: Grant a Role to the Default Service Account** {#step-5-grant-a-role-to-the-default-service-account .unnumbered}

- **What It Does:**

<!-- -->

- Creates a Cluster Role Binding named add-on-cluster-admin.

- Binds the cluster-admin role to the default service account in the
  kube-system namespace.

<!-- -->

- **Why This Step?**

<!-- -->

- Helm uses Kubernetes service accounts for access control.

- This command grants the default service account in kube-system full
  administrative access to the cluster.

<!-- -->

- **Potential Risks:**

<!-- -->

- Granting cluster-admin access is very permissive and is generally not
  recommended for production.

- Consider creating a more restrictive role with only the necessary
  permissions.

Run the following code

kubectl \--namespace=kube-system create clusterrolebinding
add-on-cluster-admin \\

\--clusterrole=cluster-admin \\

\--serviceaccount=kube-system:default

![](media/image40.png){width="7.5in" height="0.7715277777777778in"}

## **Step12: Prometheus Installation and Configuration** {#step12-prometheus-installation-and-configuration .unnumbered}

### **Add the Prometheus Helm Repository and Update**

helm repo add prometheus-community
https://prometheus-community.github.io/helm-charts

helm repo update

![A screen shot of a computer AI-generated content may be
incorrect.](media/image41.png){width="7.5in"
height="0.9638888888888889in"}

### **Create a YAML file (prometheus.yml) to Disable Persistent Volume** {#create-a-yaml-file-prometheus.yml-to-disable-persistent-volume}

vi prometheus.yml

server:

persistentVolume:

enabled: false

alertmanager:

persistentVolume:

enabled: false

**Why Disable Persistent Volume?**

- In this example, you disable persistence, so Prometheus does not store
  data permanently.

- **Warning:** In a real production environment, disabling persistence
  means you lose metrics if pods restart or are terminated.

### **Install Prometheus with the Custom YAML**

helm install -f prometheus.yml prometheus
prometheus-community/Prometheus

**What It Does:**

- Installs Prometheus using the Helm chart from the community repo.

- Applies your config from prometheus.yml (with persistence disabled
  here).

![A screen shot of a computer screen AI-generated content may be
incorrect.](media/image42.png){width="7.5in" height="4.21875in"}

Kubectl get nodes

![A screenshot of a computer screen AI-generated content may be
incorrect.](media/image43.png){width="7.5in" height="2.25in"}

### **Expose Prometheus Using NodePort**

kubectl expose service prometheus-server \--type=NodePort
\--target-port=9090 \--name=prometheus-server-np

kubectl get svc

![A screen shot of a computer screen AI-generated content may be
incorrect.](media/image44.png){width="7.5in"
height="1.6659722222222222in"}

**What It Does:**

- Creates a Kubernetes service of type NodePort to expose Prometheus
  outside the cluster.

- The Prometheus UI runs on port 9090 inside the cluster.

- kubectl get svc shows the NodePort assigned (random port in the range
  30000-32767).

**Why NodePort?**

- To access Prometheus UI from your local machine or browser via the
  node's IP address and assigned port.

### **Access Prometheus Web UI**

Open a browser and enter Public IP Address of master node or worker node

http://\<Public IP\>:\<NodePort\>

http://54.165.83.46:1213/query

To check NodePort run the following command

kubectl get svc

![A screen shot of a computer screen AI-generated content may be
incorrect.](media/image44.png){width="7.5in"
height="1.6659722222222222in"}

### **Explore Metrics and Queries**

In the Prometheus UI, use the **Expression Browser** to search metrics,
for example:

- Search for CPU or Memory metrics.

- Example query:

kubelet_http_requests_total

Click Execute

**You can also visualize your metrics by clicking the Graph tab**

![A screen shot of a computer AI-generated content may be
incorrect.](media/image45.png){width="7.5in" height="4.21875in"}

#  {#section-3 .unnumbered}

## **Step 13: Installation and Configuration of Grafana** {#step-13-installation-and-configuration-of-grafana .unnumbered}

**Grafana** is an open-source platform used for monitoring,
visualization, and data analysis. It allows you to query, visualize, and
understand your metrics from various data sources in real-time through
customizable dashboards.

**Common Use Cases:**

- **Kubernetes Monitoring:** Visualize CPU, memory, and network usage
  across clusters.

- **Application Performance Monitoring (APM):** Track application
  metrics and log data.

- **Infrastructure Monitoring:** Monitor server health, disk usage, and
  network traffic.

- **Business Metrics:** Display business KPIs like sales data,
  transaction counts, etc.

**Grafana** is a robust open-source platform used for monitoring,
visualization, and analysis of metrics from various data sources,
including **Prometheus**.

**The following steps outline the process for installing and configuring
Grafana in a Kubernetes cluster using Helm.**

1.  **Add the Grafana Repository to Helm Configuration:**

First, we need to add the official Grafana repository to our Helm
configuration. This repository contains the Helm charts necessary to
deploy Grafana.

Run the following commands:

helm repo add grafana <https://grafana.github.io/helm-charts>

helm repo update

![A black screen with white text AI-generated content may be
incorrect.](media/image46.png){width="7.5in"
height="1.3569444444444445in"}

### **Create a Grafana Values File:**

We need to create a grafana.yml file to customize our Grafana
deployment. This file will contain values that Helm will use to
configure the deployment.

Run:

vi grafana.yml

insert following

adminUser: admin

adminPassword: YUDevOps

service:

  type: NodePort

  port: 3000

### **Install Grafana Using the Provided Helm Chart:**

Now, we use Helm to deploy Grafana using the values file we created:

helm install -f grafana.yml grafana grafana/grafana

- **-f grafana.yml**: Specifies the custom configuration file.

- **grafana**: The release name.

- **grafana/grafana**: The Helm chart we are using.

After running the command, check the status of the pods to ensure
Grafana is running:

![A screenshot of a computer program AI-generated content may be
incorrect.](media/image47.png){width="7.5in" height="3.4in"}

kubectl get pods

you see grafana pod is running

![A screen shot of a computer AI-generated content may be
incorrect.](media/image48.png){width="7.5in" height="2.1375in"}

### **Expose Grafana Using NodePort Service:**

By default, the Grafana service is only accessible within the Kubernetes
cluster. To access it externally, we expose it using a NodePort service.

Run the command:

kubectl expose service grafana \--type=NodePort \--target-port=3000
\--name=grafana-np

*Verify the service and note the NodePort assigned by runnig following
command*

kubectl get svc

![A screen shot of a computer AI-generated content may be
incorrect.](media/image49.png){width="7.5in"
height="2.1993055555555556in"}

### **Access Grafana:**

Now, open a browser and navigate to:

\<Public IP\>:\<NodePort\>

Ex: **<http://54.227.118.240:1189/login> \-- Master Node**

**Access Grafana**

> Username: **admin**
>
> Password: **YUDevOps**

![A screenshot of a computer AI-generated content may be
incorrect.](media/image50.png){width="7.5in" height="4.21875in"}

**You will also see that grafana also running on worker node**

**<http://52.204.114.58:1189/login> \-\-- Worker Node1**

[**http://**
**54.165.83.46:1189/login**](http://54.227.118.240:1189/login) **\-\--
Worker Node0**

![Screens screenshot of a computer AI-generated content may be
incorrect.](media/image51.png){width="7.5in" height="4.21875in"}

**Login using the default credentials:**

- **Username:** admin

- **Password:** YUDevOps

![A screenshot of a computer AI-generated content may be
incorrect.](media/image52.png){width="7.5in" height="4.21875in"}

### **Configure Data Source:**

Grafana needs a data source to visualize metrics. We will use Prometheus
as our data source.

1.  Click on the **Connnection** icon in the left sidebar.

2.  Select **Data Sources** \> **Add data source**.

3.  Select **Prometheus**.

In the URL field, enter the following address:

<http://prometheus-server.default.svc.cluster.local>

Click **Save & Test** to verify the connection.

![A screenshot of a computer AI-generated content may be
incorrect.](media/image53.png){width="7.5in" height="4.21875in"}

The address http://prometheus-server.default.svc.cluster.local is the
**internal DNS address** of the Prometheus service within the Kubernetes
cluster. This address is automatically generated by Kubernetes when a
service is created. Let\'s break down how to get this address.

- **service-name** -- The name of the service.

- **namespace** -- The namespace where the service is running (e.g.,
  default).

- **svc** -- A subdomain used for services.

- **cluster.local** -- The default cluster domain. This can vary if
  custom DNS settings are configured.

### **Import Grafana Dashboards:**

Grafana supports pre-built dashboards that can be imported using their
unique IDs.

**Import Dashboard ID 10000:**

1.  Click the **Create** icon \> **Import**.

2.  Enter **10000** in the Import via ID field and click **Load**.

3.  Select **Prometheus** from the data source dropdown and click
    **Import**.

![A screenshot of a computer AI-generated content may be
incorrect.](media/image54.png){width="7.5in" height="4.21875in"}

**Import Dashboard ID 13770:**

Repeat the above steps with **ID 13770**.

Now, you will see two dashboards populated with Prometheus metrics.

![A screenshot of a computer AI-generated content may be
incorrect.](media/image55.png){width="7.5in" height="4.21875in"}

**Get All Resources in the Current Namespace:**

kubectl get all

![A computer screen shot of a black screen AI-generated content may be
incorrect.](media/image56.png){width="7.5in" height="4.21875in"}

##  {#section-4 .unnumbered}

## **Step 14: Destroy Terraform Resources:** {#step-14-destroy-terraform-resources .unnumbered}

Once you are done with the lab, it\'s crucial to clean up the
provisioned infrastructure to avoid unnecessary costs.

Run the command:

terraform destroy

- Terraform will list all the resources it will destroy and prompt for
  confirmation.

- Type yes to proceed with the destruction.
