
# Observability Lab using Kubernetes Cluster on EC2s

## Master Node & Worker Nodes

### System Config

```bash
# Disable swap (required for Kubernetes)
sudo swapoff -a 
# Comment out swap line in fstab to make it persistent
sudo sed -i '/ swap / s/^\(.*\)$/#/g' /etc/fstab

# Create containerd module configuration
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

# Load kernel modules required for containerd and networking
sudo modprobe overlay
sudo modprobe br_netfilter

# Set sysctl params required by Kubernetes networking
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

# Update system packages
sudo yum update -y
# Install containerd (container runtime)
sudo yum install -y containerd

# Create containerd configuration directory
sudo mkdir -p /etc/containerd

# Generate and save default containerd config
containerd config default | sudo tee /etc/containerd/config.toml

# Restart containerd to apply new configuration
sudo systemctl restart containerd

# Check if containerd is active and running
sudo systemctl status containerd
```

### Kubernetes Install

```bash
# Add Kubernetes repo configuration
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

# Set SELinux to permissive mode (required by Kubernetes)
sudo setenforce 0
# Make SELinux change persistent
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Install Kubernetes components
sudo yum install -y kubelet-1.28.2 kubeadm-1.28.2 kubectl-1.28.2 --disableexcludes=kubernetes

# Enable and start kubelet service
sudo systemctl enable --now kubelet
```

## Cluster Configuration

```bash
# Initialize the Kubernetes control-plane node using kubeadm
sudo kubeadm init --config kube-config.yml --ignore-preflight-errors=all

# Configure kubectl to use the admin config
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Check node status (will be NotReady until network is applied)
kubectl get nodes

# Apply Calico CNI for pod networking
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# Check node status again (should change to Ready)
kubectl get nodes

# Generate and print join command for worker nodes
kubeadm token create --print-join-command

# Check all nodes in the cluster
kubectl get nodes
```

## Configure a Worker Node

```bash
# Run the generated join command from the master on each worker node
# Example (replace with your actual join command):
# sudo kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>

# On the master node, verify worker node has joined
kubectl get nodes
```

## Deploy a Container to the Cluster

```bash
# Create pod using your React app manifest
kubectl create -f react-app-pod.yml

# Check pod status and node it's running on
kubectl get pods -o wide

# Verify deployment (if using a Deployment manifest)
kubectl get deployment
```
