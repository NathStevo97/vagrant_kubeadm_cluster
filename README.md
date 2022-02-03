# VMWare Kubeadm Cluster
This is a modified version of [Kodekloud's Kubeadm Cluster setup](https://github.com/kodekloudhub/certified-kubernetes-administrator-course) for VMWare Workstation rather than Oracle Virtualbox for improved performance and usability.

# Prerequisites:
- Install [Vagrant](https://www.vagrantup.com/downloads)
- Install [VMWare Workstation](https://www.vmware.com/uk/products/workstation-pro/workstation-pro-evaluation.html)
- Install the [Vagrant VMWare Desktop Utility](https://www.vagrantup.com/docs/providers/vmware/vagrant-vmware-utility)
- Install the [Vagrant VMWare Workstation Provider](https://www.vagrantup.com/docs/providers/vmware/installation)

# Getting the Nodes Setup and Kubeadm Installed
The instructions to get the Nodes set up and Kubeadm installed are unchanged, and can be referenced via the Kubernetes Documentation; found via the following link.

[Kubernetes Documentation - Install Kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/])

# Setting Up the Nodes & Joining the Cluster
Similarly, the instructions to initialise the controlplane and join worker nodes is unchanged and can be found via the following link:

[Kubernetes Documentation - Creating a Cluster with Kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)

# Troubleshooting and Notes:
To determine the Virtual Network Settings in VMWare Workstation, navigate to **Edit -> Virtual Network Preferences**

During Kubeadm Init on the ControlPlane or Kubeadm Join in the worker nodes, Kubelet may fail to start. In my case, I found this to be an issue with the CGroup Driver used by Kubeadm and Docker conflicting. The following steps can be used to resolve this ([reference StackOverFlow Thread](https://stackoverflow.com/questions/62216678/kubeadm-init-issue)):

1. Check the kubeadm environment variables defined in the config file referenced by kubelet <br> 
```
systemctl status kubelet
cat /var/lib/kubelet/kubeadm-flags.env  
```

2. Check Docker's config info
```
sudo docker info | grep Cgroup
```

3. If the Docker config requires alteration:
```
cat << EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
```

4. Update the Kubelet CGroup Driver Configuration
```
`vi /etc/systemd/system/kubelet.service.d/10-kubeadm.conf`
```
a. Add the following before ExecStart:
```
Environment="KUBELET_CGROUP_ARGS=--cgroup-driver=<cgroupfs or systemd>"
```

b. Add *$KUBELET_CGROUP_ARGS* to ExecStart in the file.

5. __Optional__ - Disable Swap:
```
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab
```

6. Reboot the machine (manually or via vagrant) and run the following before running __kubeadm init/join__ again:
```
kubeadm reset
rm -rf ~/.kube/
```