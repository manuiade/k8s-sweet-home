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

Ubuntu server pre-built images are used in order to speed up the installation process. The first script also provides instructions to download the image

Use the following command to prepare everything for nodes configuration

```
./00_requirements.sh
```

## Step 1 - Node configuration

You can now configure your node files, including network information, hostname, SSH keys and everything else needed to have your nodes immediately ready when the RaspberryPi boards are powered on.

<b>IMPORTANT</b>

<b>---------</b>

Note that in the 01_node_configuration.sh script <b>YOU</b> need to substitute the 2 offset value of the /boot sector and / sector with the specific value of your downloaded image (lines 4 and 5 of the script).
You can use the command:

```
fdisk -l <IMAGE_FILE.img>
```

to get the partition sector, then multiply the Start column value by the block size (usually 512bytes).

Image mount (via mount command) also requires root privileges in order to be executed (local mnt folder will be used).

A more elegant solution will be soon provided (note that the preset values should work with all the ubuntu images)

<b>---------</b>

The script creates the custom configuration files for each node and recompress the images to make them ready to be flashed on SD cards:

Launch the script to create the custom OS images for each node:
```
./01_node_configuration.sh
```

### Boot your raspberry

- Use your favourite tool to flash the OS images generated from previous step into your SD cards
- Insert your cards into the raspberry and power them on
- The first boot could require up to 5 minutes 
- You can test connectivity to each of your boards just by pinging them (if ping to the boards does not work try to reboot them), and if everything is ok, you can now procede to install Kubernetes on your nodes


## Step 2 - Install Kubernetes

We will proceed by installing k8s via kubeadm, using one master node and any number of worker nodes.

An Ansible playbook will take care of all the operations needed, so you just need to execute the following command:

```
./02_install_k8s.sh
```

After the playbook has completed you'll already have a fully functioning k8s cluster, with containerd as container engine and kubernetes with calico as CNI plugin.

You will find the kubeconfig file needed to access the cluster at ./ansible/static/kubeconfig

Check you master and worker nodes are ready (you need to wait a few minutes to see them as Ready):

```
kubectl --kubeconfig ./ansible/static/kubeconfig get nodes
```

<b> Now you are ready to deploy your workloads to kubernetes!! </b>


## Cluster Management

Some ansible playbooks are also provided to easily manage operations on the raspberry boards

### Reboot cluster

```
cd ansible
ansible-playbook reboot-cluster.yaml
```

### Reset Kubeadm

If something get screwed up with your k8s cluster, you can just use the kubeadm reset command to clean up your master and worker nodes, and re-installing kubernetes again with the following script:

```
./reset_cluster.sh
```


# TODO

## Step 3 (Extra) - Install additional Kubernetes components

## Local binaries

In the future support for using these tools will also be added:

- <b>Terraform</b> to manage the additional component installation
- <b>Helm</b> to manage kubernetes applications repositories
- <b>Lens</b> to easily connect to your cluster and manage workloads using a GUI

## k8s Tools

- [ ] Kubernetes Dashboard setup

- [ ] Metal load balancer setup

- [ ] Traefik setup as Ingress Controller

- [ ] NFS Volumes

- [ ] Metric server, Prometheus and Grafana as monitoring tools (with Slack notifications)

- [ ] Istio as Service Mesh (with Kiali and Jaeger)

- [ ] Tekton, for GitOps

- [ ] Backup and restore plan for etcd