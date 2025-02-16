# K8s Sweet Home

A quick and automated way to setup a Kubernetes cluster with Ansible using multiple RaspberryPi boards.

This repository helps you in every step required from flashing the OS in your SD cards, configuring the network, setting the SSH keys for accessing the boards, install each component to each node, until you have a cluster fully configured (1 master and N workers)


## What you must have before continuing

- At least 2 RaspberryPi boards (one required to act as the k8s master and at least another one to act as a k8s worker node) and a respective micro SD card
- A Linux local machine to manage your configuration setup (the scripts have only been tested with Ubuntu 20/22) with Python3 installed (required for Ansible)
- A tool for flashing your OS images into the SD cards (I personally use BalenaEtcher https://www.balena.io/etcher/)


## This branch is supposed to work for Ubuntu 20/22 Server preinstalled server images (64-bit ARM)

- https://cdimage.ubuntu.com/ubuntu-server/focal/daily-preinstalled/current/focal-preinstalled-server-arm64+raspi.img.xz

- https://cdimage.ubuntu.com/ubuntu-server/jammy/daily-preinstalled/current/jammy-preinstalled-server-arm64+raspi.img.xz

## Before you begin

Before starting executing scripts to automate setup rename the *config.ini.template* file to *config.ini* and fill it with the appropriate values

## Step 0 - Requirements

We will be using the following software to manage all the installations:

- <b>Ansible</b> to execute the playbooks for configuring the cluster on master and all worker nodes
- <b>Kubectl</b> to communicate with your master endpoint (use a version >= 1.22.0)
- <b>Cilium CLI </b> to install Cilium as CNI if required
- <b>Terraform </b> to manage addons (metallb, monitoring ecc.) installed on the k8s cluster after setup

Ubuntu server pre-built images are used in order to speed up the installation process. The first script also provides instructions to download the image

Use the following command to prepare everything for nodes configuration

```bash
./00_requirements.sh
```

## Step 1 - Node configuration

You can now configure your node files, including network information, hostname, SSH keys and everything else needed to have your nodes immediately ready when the RaspberryPi boards are powered on.

<b>IMPORTANT</b>

<b>---------</b>

Note that in the 01_node_configuration.sh script <b>YOU</b> need to substitute the 2 offset value of the /boot sector and / sector with the specific value of your downloaded image (lines 4 and 5 of the script).
You can use the command:

```bash
fdisk -l <IMAGE_FILE.img>
```

to get the partition sector, then multiply the Start column value by the block size (usually 512bytes).

Image mount (via mount command) also requires root privileges in order to be executed (local mnt folder will be used).

A more elegant solution will be soon provided (note that the preset values should work with all the ubuntu images)

<b>---------</b>

The script creates the custom configuration files for each node and recompress the images to make them ready to be flashed on SD cards:

Launch the script to create the custom OS images for each node:

```bash
./01_node_configuration.sh
```

### Boot your raspberry

- Use your favourite tool to flash the OS images generated from previous step into your SD cards, otherwise you can do that using the following Linux command:

```bash
sudo umount /dev/sdX 
xzcat os/<IMAGE>.img.xz | sudo dd of=/dev/sdX conv=fdatasync status=progress
```

- Insert your cards into the raspberry and power them on
- The first boot could require up to 5 minutes 
- You can test connectivity to each of your boards just by pinging them (if ping to the boards does not work try to reboot them), and if everything is ok, you can now procede to install Kubernetes on your nodes


## Step 2 - Install Kubernetes

We will proceed by installing k8s via kubeadm, using one master node and any number of worker nodes.

An Ansible playbook will take care of all the operations needed, so you just need to execute the following command:

```bash
./02_install_k8s.sh
```

After the playbook has completed you'll already have a fully functioning k8s cluster, with containerd as container engine and kubernetes with calico|cilium as CNI plugin.

You will find the kubeconfig file needed to access the cluster at ./ansible/static/kubeconfig

Check you master and worker nodes are ready (you need to wait a few minutes to see them as Ready):

```bash
kubectl --kubeconfig ./ansible/static/kubeconfig get nodes
```

<b> Now you are ready to deploy your workloads to kubernetes!! </b>



## [OPTIONAL] Step 3 - Cilium Installation

If you chose the Cilium CNI, after ansible setup you have to install to your cluster cilium components. In order to do so update your local kubeconfig (usually $HOME/.kube/config) to include the cluster kubeconfig (./ansible/static/kubeconfig), then run:

```bash
./03_cilium_install.sh
```


## [OPTIONAL] Step 4 - Install NFS Server

A dedicated playbook is provided to setup a NFS server and clients in the following manner:

- The playbook expects that the block device used as NFS volume is plugged into the k8s master board, which will be designed as NFS server. The playbook use a dedicated role to setup the NFS server required software, mount the disk on the /mnt/nfs mountpoint, configure /etc/exports

- N.B. The /etc/exports file will be loaded from the ansible location *ansible/roles/master/files/exports* with a sample configuration, feel free to change it based on your needs

- The other k8s worker boards will be eventually the NFS client from kubernetes workloads, and a dedicated role simply install the nfs-common packages to ensure mount via kubernetes works

Before running the playbook via the provided script, update the *config.ini* file inserting the device path of the disk inserted into the master board (simply run a lsblk command on the master board to find the path, usually /dev/sda1 for the first disk), then simply run:

```bash
./04_setup_nfs.sh
```


## [OPTIONAL] Step 5 - Cluster addons using Terraform

A terraform directory has been provided to manage installation/uninstallation of additional components on k8s cluster.
Currently the following components have been added:

- Metallb (with L2 address pools specifying address range for Service Load Balancer objects)
- Traefik ingress controlloer (with dashboard exposition via ingress-route object)
- Cert-manager (with sample self signed certificate provided)
- Hello-nginx module (deploys a nginx deployment/service/ingress to test previously installed modules)

Navigate into the terraform directory and enable flags on the *terraform.tfvars* file based on the component you want to install using Terraform:

```bash
# modify terraform.tfvars content
cd terraform
../local-requirements/terraform init
../local-requirements/terraform plan -out plan.out
../local-requirements/terraform apply plan.out
```


## Cluster Management

Some ansible playbooks are also provided to easily manage operations on the raspberry boards


### Reboot cluster

```bash
cd ansible
ansible-playbook reboot-cluster.yaml
```

### Reset Kubeadm

If something get screwed up with your k8s cluster, you can just use the kubeadm reset command to clean up your master and worker nodes, and re-installing kubernetes again with the following script:

```bash
./reset_cluster.sh
```


# TODO

## k8s Tools

- [x] Cilium as eBPF with Hubble observability

- [x] Metal load balancer setup

- [x] Traefik setup as Ingress Controller

- [ ] NFS Volumes (configure RAIDX with multiple drives)

- [x] Metric server, Prometheus and Grafana as monitoring tools

- [x] Istio as Service Mesh

- [x] Tekton, for GitOps

- [ ] Backup and restore plan for etcd