# VMWare Kubeadm Cluster

This is a modified version of [Kodekloud's Kubeadm Cluster setup](https://github.com/kodekloudhub/certified-kubernetes-administrator-course) for VMWare Workstation rather than Oracle Virtualbox for improved performance and usability.

# Prerequisites

- Install [Vagrant](https://www.vagrantup.com/downloads)
- Install [VMWare Workstation](https://www.vmware.com/uk/products/workstation-pro/workstation-pro-evaluation.html)
- Install the [Vagrant VMWare Desktop Utility](https://www.vagrantup.com/docs/providers/vmware/vagrant-vmware-utility)
- Install the [Vagrant VMWare Workstation Provider](https://www.vagrantup.com/docs/providers/vmware/installation)

# Installing Container Runtime

Ref : <https://kubernetes.io/docs/setup/production-environment/container-runtimes/>

Verify that the br_netfilter module is loaded on each node by running `lsmod | grep br_netfilter`.

To load it explicitly, run `sudo modprobe br_netfilter`

In order for a Linux node's iptables to correctly view bridged traffic, verify that net.bridge.bridge-nf-call-iptables is set to 1 in your sysctl config. For example:

```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system
```

## Install Container Runtime - containerd

Ref: <https://github.com/containerd/containerd/blob/main/docs/getting-started.md>

Choosing to install via option 2 - from apt-get or dnf (<https://docs.docker.com/engine/install/ubuntu/>)

Remove any pre-existing versions of Docker

```bash
sudo apt-get remove docker docker-engine docker.io containerd runc
```

Prereqs to allow for apt to use repos over HTTPS

```bash
sudo apt-get update
sudo apt-get install \
  ca-certificates \
  curl \
  gnupg \
  lsb-release
```

Add Docker's official GPG Key

```bash
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

Set up the repository

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Install Docker Engine (containerd included!)

```bash
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

Verify installation

```bash
sudo service docker start
sudo docker run hello-world
```

# Installing Kubeadm and Kubernetes Components

As a prerequisite, Swap **MUST** be disbled for Kubelet to work; run on all nodes required:

```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab
```

Update the apt package index and install packages needed to use the Kubernetes apt repository:

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
```

Download the Google Cloud public signing key:

```bash
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
```

Add the Kubernetes apt repository:

```bash
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

Update apt package index, install kubelet, kubeadm and kubectl, and pin their version:

```bash
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

# Create a Cluster with kubeadm

Ref: <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/>

## Initializing the ControlPlane Node

Run `kubeadm init <args>`, supplying `<args>` as required based on the following steps

1. If using a HA-setup, specify `--control-plane-endpoint` to set the shared endpoint for all control plane nodes. Not applicable for what's in this repo at present (1 control-plane, 1 worker) but worth noting.
1. Specify the Pod Network CIDR depending on the Pod [Network Addon](https://kubernetes.io/docs/concepts/cluster-administration/addons/#networking-and-network-policy) chosen. Done via `--pod-network-cidr`.
1. Optional but may be required - Specify the endpoint of the container runtime via `--cri-socket-argument` [ref](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-runtime)
1. Specify the network interface for the API server via `--apiserver-advertise=` flag.

```bash
kubeadm init --pod-network-cidr=<cidr> --apiserver-advertise-address=<control plane IP> --cri-socket=unix:////run/containerd/containerd.sock
```

>**Note:** <br>
>When using `containerd`, I had to use a minor [workaround](https://stackoverflow.com/questions/72504257/i-encountered-when-executing-kubeadm-init-error-issue) to the toml config file to get kubeadm to work. I can't understand why this line would be uncommented by default, but I'm sure there was a valid reason that I'm unaware of!

Once run successfully, either:

- As a regular user, run:

```bash
 mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

- As root user:

```bash
 export KUBECONFIG=/etc/kubernetes/admin.conf
```

Then deploy a pod network to the cluster - I personally go with either Calico or Flannel.

### Calico

- [Reference](https://projectcalico.docs.tigera.io/getting-started/kubernetes/quickstart)
- Make sure to edit the following [custom resource definition file](https://raw.githubusercontent.com/projectcalico/calico/v3.24.1/manifests/custom-resources.yaml) to match up with the pod network cidr set!

### Flannel

- [Reference](https://github.com/flannel-io/flannel#deploying-flannel-manually)

Join the worker nodes by running as root:

```bash
kubeadm join 192.169.190.2:6443 --token <token> \
        --discovery-token-ca-cert-hash sha256:<hash>
```

# Troubleshooting and Notes

To determine the Virtual Network Settings in VMWare Workstation, navigate to **Edit -> Virtual Network Preferences**

During Kubeadm Init on the ControlPlane or Kubeadm Join in the worker nodes, Kubelet may fail to start. In my case, I found this to be an issue with the CGroup Driver used by Kubeadm and Docker conflicting. The following steps can be used to resolve this ([reference StackOverFlow Thread](https://stackoverflow.com/questions/62216678/kubeadm-init-issue)):

1. Check the kubeadm environment variables defined in the config file referenced by kubelet <br>

```bash
systemctl status kubelet
cat /var/lib/kubelet/kubeadm-flags.env  
```

2. Check Docker's config info

```bash
sudo docker info | grep Cgroup
```

3. If the Docker config requires alteration:

```bash
cat << EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
```

4. Update the Kubelet CGroup Driver Configuration

```bash
`vi /etc/systemd/system/kubelet.service.d/10-kubeadm.conf`
```

a. Add the following before ExecStart:

```bash
Environment="KUBELET_CGROUP_ARGS=--cgroup-driver=<cgroupfs or systemd>"
```

b. Add `$KUBELET_CGROUP_ARGS` to ExecStart in the file.

5. Reboot the machine (manually or via vagrant) and run the following before running **kubeadm init/join** again:

```bash
kubeadm reset
rm -rf ~/.kube/
```
