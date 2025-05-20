
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

## **Step 1: Transfer Files from Windows to Linux Machine**

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

## **Assigning Elastic IP to EC2-Instance**

To maintain a consistent public IP address for an EC2 instance after stopping and restarting, an Elastic IP must be associated with the instance. This ensures that the public IP remains unchanged, preventing disruptions in connectivity or configuration dependencies that rely on a stable IP address

### **Steps to Assign an Elastic IP to an EC2 Instance in AWS Console:**

#### 1.  **Navigate to the EC2 Dashboard:**

- Open the [AWS Management Console](https://console.aws.amazon.com/).
- In the **Services** menu, select **EC2**.

#### 2.  **Allocate an Elastic IP Address:**

- In the left navigation pane, click **Elastic IPs** under **Network & Security**.
- Click **Allocate Elastic IP address**.
- Choose the scope (**VPC**) and click **Allocate**.
- Note down the newly allocated Elastic IP address.

#### 3.  **Associate Elastic IP with EC2 Instance:**

- Select the allocated Elastic IP.
- Click **Actions** → **Associate Elastic IP address**.
- In the **Resource type** dropdown, select **Instance**.
- Select the desired EC2 instance from the list.
- Choose the **Private IP address** to which the Elastic IP will be associated (if the instance has multiple private IPs).
- Click **Associate**.

#### 4.  **Verify the Association:**

- Go to **Instances** in the EC2 dashboard.
- Select the instance and confirm that the **Public IPv4 address** matches the allocated Elastic IP.

![Image20](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image20.png)

## **Step 4: Provisioning AWS Infrastructure using Terraform**

### 1.  `Terraform init`

- prepares your environment and configures everything Terraform needs to interact with your infrastructure.

![Image5](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image5.png)

### 2.  `terraform fmt`

- used to **automatically format** your Terraform configuration files to a standard style. It ensures that your code is consistently formatted, making it easier to read and maintain.

### 3.  `Terraform validate`

- used to **check the syntax and validity** of your Terraform configuration files. It helps you catch errors in the configuration before you attempt to run other Terraform commands, like terraform plan or terraform apply.

![Image6](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image6.png)

### 4.  `terraform plan`

- used to **preview the changes** Terraform will make to your infrastructure based on the current configuration and the existing state. It shows what actions will be taken (such as creating, modifying, or deleting resources) when you apply the configuration

- Before running terraform apply to check exactly what changes Terraform will make.

***Before Running Terraform Plan must update the location of public and private ssh keys under modules -compute - variables.tf***

**As shown in following image:**

![Image7](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image7.png)

**After applying the Terraform plan, you will see the following output:**

![Image8](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image8.png)

## 5:  `Terraform apply`

Provision terraform managed infrastructure. You must confirm by trying **yes** if you would like to continue and perform the actions described to provision your infrastructure resources

After successfully applying the Terraform configuration, you will see the public IP addresses assigned to your Kubernetes master and node instances as output.

![Image9](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image9.png)

**k8s-master-Public-IP**: The public IP address assigned to the Kubernetes master node.

**k8s-node-Public-IP**: A list of public IP addresses assigned to the Kubernetes worker nodes.

**You can log in to your AWS account to view the infrastructure resources that have been provisioned.**

![Image10](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image10.png)

## **Step 5: Connect to K8s Master (Control Plane) Node**

Using the public IP address provided in the Terraform output, connect to the EC2 instance by executing the following command in your terminal:

```shell
ssh -i /root/.ssh/docker ec2-user@54.227.118.240
```

![Image11](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image11.png)

## **Step 6: Install and Configure Kubernetes Master (Control Plane) Node**

### **Follow these steps to set up the Kubernetes Control Plane node effectively:**

#### **Update the System and Install Dependencies**

Run the following commands to update the system and install essential packages:

```shell
sudo yum update -y
```

```shell
sudo yum install -y curl wget git
```

#### **Disable Swap**

Kubernetes disables swap to prevent unpredictable latency and ensure consistent memory management across nodes. Swapping can bypass Kubernete's memory limits, leading to instability and performance degradation.

Kubernetes requires swap to be disabled. Execute:

```shell
sudo swapoff -a

sudo sed -i \'/ swap / s/\^\\.\*\\\$/#\1/g\' /etc/fstab
```

verify swap is disable

```bash
free -h
```

![Image12](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image12.png)

swapon --show

**Note:** If swap is disabled, this command will produce no output.

### **Load Modules for containerd:**

Following commands are used to **load kernel modules** necessary for container networking and filesystem overlay in a containerized environment like **containerd** or **Kubernetes**.

Run the following commands

```bash
sudo modprobe overlay
```

\# Enables the overlay filesystem, which allows container runtimes to layer filesystems efficiently.

```bash
sudo modprobe br_netfilter
```

\# Enables bridging between containers for networking, essential for Kubernetes networking components like kube-proxy.

### **Set Up sysctl Parameters for Kubernetes Networking**

```shell
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
```

### **Apply changes by running the following command**

```shell
sudo sysctl --system
```

![Image13](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image13.png)

### **Verify Modules:**

Verify that the modules are loaded, by running the following command

```shell
lsmod | grep overlay

lsmod | grep br_netfilter
```

![Image14](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image14.png)

### **Download and Install the Latest cri-tools RPM:**

```shell
cd \~
```

```bash
curl -LO https://download.opensuse.org/repositories/isv:/kubernetes:/core:/stable:/v1.30/rpm/x86_64/cri-tools-1.30.0-150500.1.1.x86_64.rpm
```

```bash
sudo yum localinstall -y cri-tools-1.30.0-150500.1.1.x86_64.rpm
sudo sysctl ---system
crictl --version
```

![Image15](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image15.png)

### **Install containerd**

#### **Update the system:**

```shell
sudo yum update -y
```

#### **Install containerd:**

```shell
sudo yum install -y containerd
```

![Image16](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image16.png)

### **Create the configuration directory:**

```shell
sudo mkdir -p /etc/containerd
```

### **Generate containerd configuration:**

```shell
containerd config default | sudo tee /etc/containerd/config.toml
```

![Image17](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image17.png)

### **Enable Conatinerd**

```shell
sudo systemctl enable containerd \--now
```

### **Restart containerd:**

```shell
sudo systemctl restart containerd
```

### **Verify containerd status:**

```shell
sudo systemctl status containerd
```

### **Verify Version**

```shell
containerd --version
```

![Image18](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image18.png)

## **Install Kubernetes Components (kubeadm, kubelet, kubectl)**

### **Add Kubernetes repository:**

```shell
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.32/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF
```

![Image19](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image19.png)

### **Set SELinux in Permissive Mode**

```shell
sudo setenforce 0

sudo sed -i \'s/\^SELINUX=enforcing\$/SELINUX=permissive/\' /etc/selinux/config
```

### **Install kubeadm, kubelet, and kubectl**

```shell
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
```

![Image21](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image21.png)

### **Enable and Start kubelet**

```shell
sudo systemctl enable --now kubelet
```

## **Step 7: Initialize the Kubernetes Cluster and Install Calico Network**

### 1.  **Create Kubeadm Config File:**

```shell
vi kube-config.yml
```

#### **Insert the following content in above yml file**

```yml
apiVersion: kubeadm.k8s.io/v1beta3
kubernetesVersion: 1.32.0
# This is a configuration file for kubeadm to set up a Kubernetes cluster.
kind: ClusterConfiguration
networking:
  podSubnet: 192.168.0.0/16
apiServer:
  extraArgs:
   service-node-port-range: 1024-1233
```

### 2.  **Initialize Kubernetes Cluster:**

```shell
sudo kubeadm init --config kube-config.yml --ignore-preflight-errors=all
```

**Note:** The purpose of --ignore-preflight-errors=all flag is to ignore the K8s HW requirements

![Image22](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image22.png)

### 3.  **Set Up Kubernetes CLI Access:**

```shell
mkdir -p \$HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf \$HOME/.kube/config
sudo chown \$(id -u):\$(id -g) \$HOME/.kube/config
```

### 4.  **Check Node Status:**

```shell
kubectl get nodes
```

![Image23](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image23.png)

### 5.  **Install Calico Network Plugin:**

```shell
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

![Image24](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image24.png)

**Wait a few minutes, then verify the node status:** Run the following command

```shell
kubectl get nodes
```

![Image25](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image25.png)

## **Step 8: Connect to K8s Worker Node**

### 1.  **Connect to Worker Node**

- Use the same steps as the Master node, using the worker node's public IP.

### 2.  **Install Kubernetes on Worker Node**

- Follow the same installation steps as for the Master Node to install containerd, kubeadm, kubelet, and kubectl.

## **Step 9: Join the Work Node to the Kubernetes Cluster**

### **Get Join Command from Master Node**

- On the master node, generate the join command by running the following command

```shell
kubeadm token create --print-join-command
```

you will see like following

```shell
sudo kubeadm join 10.0.1.45:6443 --token kl3rnb.gj2syfp4bjnri1xu --discovery-token-ca-cert-hash sha256:0805a221754221c412c58ee47f3a38e7f2ccd9baaa3b57a3ede5fc8975de3189 --ignore-preflight-errors=all
```

copy the above command and paste to your worker node

![Image26](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image26.png)

In the Master (Control Plane) Node, check the cluster status (It could take few moments until the node become ready)

```shell
kubectl get nodes
```

![Image28](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image28.png)

## **Step 10: Deploy React Application**

### 1.  **Create React Application YAML (react-app-pod.yml)**

#### **Run the following command**

```shell
vi react-app-pod.yml
```

insert the following `yml` code

```yml
apiVersion: v1
kind: Service
metadata:
  name: react-app
spec:
  type: NodePort
  ports:
    - port: 80
      targetPort: 80
      nodePort: 1233
  selector:
    app: react-app

---
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
      - name: react-app
        image: wessamabdelwahab/react-app:latest   #docker image
        ports:
        - containerPort: 80
```

### 2.  **Apply the React App YAML**

```shell
kubectl create -f react-app-pod.yml
```

![Image27](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image27.png)

### 3.  **Verify Pods and Services**

```shell
kubectl get pods
```

![Image29](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image29.png)

```shell
kubectl get services
```

![Image30](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image30.png)

### **Verify that the pod is up and running**

kubectl get pods -o wide

![Image31](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image31.png)

### **Check communication with react-app pod**

curl \< react-app IP address\>

Example:

```shell
curl 192.168.206.129
```

![Image32](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image32.png)

### **Verify that the deployment complete**

```shell
kubectl get deployment
```

![Image33](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image33.png)

Go to the pubic IP of your Master server, worker node and port 1233 \<Public IP\>:1233. The sample react application should be running.

```shell
http://54.227.118.240:1233/  #Public IP of master Node
```

```shell
http://52.204.114.58:1233/  #Public of Node 1 (Worker Node)
```

```shell
http://54.165.83.46:1233/   #Public Ip of Node 0 (Worker Node)
```

![Image34](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/19f1cb1fabf04847c82fa00d32ad17c4ccbabc10/Images/Image34.png)

## **Step 11: Implementing Helm: Installation and Configuration**

- **Helm** is a package manager for Kubernetes that simplifies the deployment, management, and scaling of applications in a Kubernetes cluster.
- It uses pre-configured application templates called **Charts**, which define the structure and configuration of Kubernetes resources.

### **Step 1: Download the Helm installation script.**

```shell
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
```

### **Step 2: Assign execute permissions to the script.**

```shell
chmod 700 get_helm.sh
```

### **Step 3: Run the script to install Helm.**

```shell
./get_helm.sh
```

### **Step 4: Verify the installation.**

```shell
helm version
```

![Image35](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/17a95c04959781136e71332bdc96f9c1a2659c0e/Images/Image35.png)

### **Step 5: Grant a Role to the Default Service Account**

**What It Does:**

- Creates a Cluster Role Binding named add-on-cluster-admin.
- Binds the cluster-admin role to the default service account in the kube-system namespace.

**Why This Step?**

- Helm uses Kubernetes service accounts for access control.
- This command grants the default service account in kube-system full administrative access to the cluster.

**Potential Risks:**

- Granting cluster-admin access is very permissive and is generally not recommended for production.
- Consider creating a more restrictive role with only the necessary permissions.

Run the following code

```bash
kubectl --namespace=kube-system create clusterrolebinding add-on-cluster-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=kube-system:default
```

![Image36](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/17a95c04959781136e71332bdc96f9c1a2659c0e/Images/Image36.png)

## **Step12: Prometheus Installation and Configuration**

### **Add the Prometheus Helm Repository and Update**

```shell
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

```bash
helm repo update
```

![Image37](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/17a95c04959781136e71332bdc96f9c1a2659c0e/Images/Image37.png)

### **Create a YAML file (prometheus.yml) to Disable Persistent Volume**

```shell
vi prometheus.yml
```

insert the following `yml` code

```yml
server:
  persistentVolume:
    enabled: false
alertmanager:
  persistentVolume:
    enabled: false
```

**Why Disable Persistent Volume?**

- In this example, you disable persistence, so Prometheus does not store
  data permanently.

- **Warning:** In a real production environment, disabling persistence means you lose metrics if pods restart or are terminated.

### **Install Prometheus with the Custom YAML**

helm install -f prometheus.yml prometheus prometheus-community/Prometheus

**What It Does:**

- Installs Prometheus using the Helm chart from the community repo.

- Applies your config from prometheus.yml (with persistence disabled here).

![Image38](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/17a95c04959781136e71332bdc96f9c1a2659c0e/Images/Image38.png)

```shell
Kubectl get nodes
```

![Image39](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/17a95c04959781136e71332bdc96f9c1a2659c0e/Images/Image39.png)

### **Expose Prometheus Using NodePort**

```shell
kubectl expose service prometheus-server --type=NodePort --target-port=9090 --name=prometheus-server-np
```

```shell
kubectl get svc
```

![Image40](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/17a95c04959781136e71332bdc96f9c1a2659c0e/Images/Image40.png)

**What It Does:**

- Creates a Kubernetes service of type NodePort to expose Prometheus outside the cluster.

- The Prometheus UI runs on port 9090 inside the cluster.

- kubectl get svc shows the NodePort assigned (random port in the range 30000-32767).

**Why NodePort?**

- To access Prometheus UI from your local machine or browser via the node's IP address and assigned port.

### **Access Prometheus Web UI**

Open a browser and enter Public IP Address of master node or worker node

Format:

http://<Public IP>:<NodePort>

Example:

```shell
http://54.165.83.46:1213/query
```

To check NodePort run the following command

```shell
kubectl get svc
```

![Image40](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/17a95c04959781136e71332bdc96f9c1a2659c0e/Images/Image40.png)

### **Explore Metrics and Queries**

In the Prometheus UI, use the **Expression Browser** to search metrics, for example:

- Search for CPU or Memory metrics.

**Example query:**

```shell
kubelet_http_requests_total
```

Click Execute

#### **You can also visualize your metrics by clicking the Graph tab**

![Image41](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/17a95c04959781136e71332bdc96f9c1a2659c0e/Images/Image41.png)

## **Step 13: Installation and Configuration of Grafana**

**Grafana** is an open-source platform used for monitoring, visualization, and data analysis. It allows you to query, visualize, and understand your metrics from various data sources in real-time through customizable dashboards.

**Common Use Cases:**

- **Kubernetes Monitoring:** Visualize CPU, memory, and network usage across clusters.

- **Application Performance Monitoring (APM):** Track application metrics and log data.

- **Infrastructure Monitoring:** Monitor server health, disk usage, and network traffic.

- **Business Metrics:** Display business KPIs like sales data, transaction counts, etc.

**Grafana** is a robust open-source platform used for monitoring, visualization, and analysis of metrics from various data sources, including **Prometheus**.

**The following steps outline the process for installing and configuring Grafana in a Kubernetes cluster using Helm.**

### 1.  **Add the Grafana Repository to Helm Configuration:**

First, we need to add the official Grafana repository to our Helm configuration. This repository contains the Helm charts necessary to deploy Grafana.

Run the following commands:

```shell
helm repo add grafana https://grafana.github.io/helm-charts
```

```shell
helm repo update
```

![Image42](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/17a95c04959781136e71332bdc96f9c1a2659c0e/Images/Image42.png)

### **Create a Grafana Values File:**

We need to create a grafana.yml file to customize our Grafana deployment. This file will contain values that Helm will use to
configure the deployment.

Craete grafana.yml file by running following command

```shell
vi grafana.yml
```

**insert following**

```yml
adminUser: admin
adminPassword: YUDevOps
service:
  type: NodePort
  port: 3000
```

### **Install Grafana Using the Provided Helm Chart:**

Now, we use Helm to deploy Grafana using the values file we created:

```shell
helm install -f grafana.yml grafana grafana/grafana
```

- **-f grafana.yml**: Specifies the custom configuration file.

- **grafana**: The release name.

- **grafana/grafana**: The Helm chart we are using.

After running the command, check the status of the pods to ensure Grafana is running:

![Image43](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/17a95c04959781136e71332bdc96f9c1a2659c0e/Images/Image43.png)

```shell
kubectl get pods
```

you see grafana pod is running

![Image44](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/17a95c04959781136e71332bdc96f9c1a2659c0e/Images/Image44.png)

### **Expose Grafana Using NodePort Service:**

By default, the Grafana service is only accessible within the Kubernetes cluster. To access it externally, we expose it using a NodePort service.

Run the command:

```shell
kubectl expose service grafana --type=NodePort --target-port=3000 --name=grafana-np
```

*Verify the service and note the NodePort assigned by runnig following command:*

kubectl get svc

![Image45](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/17a95c04959781136e71332bdc96f9c1a2659c0e/Images/Image45.png)

### **Access Grafana:**

Now, open a browser and navigate to:

**Format:**

<Public IP\>:<NodePort\>

Example:

```shell
http://54.227.118.240:1189/login #Master Node
```

**Access Grafana**

**Username:** admin
**Password:** YUDevOps

![Image46](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/17a95c04959781136e71332bdc96f9c1a2659c0e/Images/Image46.png)

#### **You will also see that grafana also running on worker node**

```shell
http://52.204.114.58:1189/login #Worker Node1
```

```shell
http://54.165.83.46:1189/login  #Worker Node0
```

![Image47](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/17a95c04959781136e71332bdc96f9c1a2659c0e/Images/Image47.png)

#### **Login using the default credentials:**

**Username:** admin
**Password:** YUDevOps

![Image48](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/17a95c04959781136e71332bdc96f9c1a2659c0e/Images/Image48.png)

### **Configure Data Source:**

Grafana needs a data source to visualize metrics. We will use Prometheus as our data source.

#### 1.  Click on the **Connnection** icon in the left sidebar.

#### 2.  Select **Data Sources** \> **Add data source**.

#### 3.  Select **Prometheus**.

In the URL field, enter the following address:

```shell
http://prometheus-server.default.svc.cluster.local
```

Click **Save & Test** to verify the connection.

![Image49](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/17a95c04959781136e71332bdc96f9c1a2659c0e/Images/Image49.png)

The address http://prometheus-server.default.svc.cluster.local is the **internal DNS address** of the Prometheus service within the Kubernetes cluster. This address is automatically generated by Kubernetes when a service is created. Let\'s break down how to get this address.

- **service-name** -- The name of the service.

- **namespace** -- The namespace where the service is running (e.g., default).

- **svc** -- A subdomain used for services.

- **cluster.local** -- The default cluster domain. This can vary if custom DNS settings are configured.

### **Import Grafana Dashboards:**

Grafana supports pre-built dashboards that can be imported using their unique IDs.

**Import Dashboard ID 10000:**

1. Click the **Create** icon \> **Import**

2. Enter **10000** in the Import via ID field and click **Load**

3. Select **Prometheus** from the data source dropdown and click **Import**

![Image50](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/17a95c04959781136e71332bdc96f9c1a2659c0e/Images/Image50.png)

**Import Dashboard ID 13770:**

Repeat the above steps with **ID 13770**.

Now, you will see two dashboards populated with Prometheus metrics.

![Image51](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/17a95c04959781136e71332bdc96f9c1a2659c0e/Images/Image51.png)

**Get All Resources in the Current Namespace:**

```shell
kubectl get all
```

![Image52](https://github.com/gurpreet2828/Terraform-Kubernetes-Monitoring/blob/17a95c04959781136e71332bdc96f9c1a2659c0e/Images/Image52.png)

## **Step 14: Destroy Terraform Resources:**

Once you are done with the lab, it\'s crucial to clean up the provisioned infrastructure to avoid unnecessary costs.

Run the command:

```shell
terraform destroy
```

- Terraform will list all the resources it will destroy and prompt for confirmation.

- Type yes to proceed with the destruction.
