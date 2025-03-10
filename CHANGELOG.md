# ChangeLog

All changes to this repository will be documented in this file.

## [1.6.1] - 2025-02-16

### Fixed

- Small fix on ansible playbook which installs k8s due to changes on package repository configuration

- Updated node configuration script to reflect correct block size during SD card preparation

- Small update on README


## [1.6.0] - 2023-12-10

### Added

Added the possibility to install additional kubernetes components using Terraform scripts (kubectl provider) for:

- Istio service mesh via Helm

- Tekton for CI/CD (pipelines, triggers, dashboard, interceptors)

### Fixed

- Ansible roles for k8s install do not also try to setup NFS server (done in Step 4)

- Changed kubectl TF provider from gavinbunney to alekc due to bug in TF 1.28 about state refresh

- Small fixes on other TF module resources (path change, code refactoring etc.)


## [1.5.0] - 2023-11-26

### Added

Added the possibility to install additional kubernetes components using Terraform scripts (kubectl provider) for:

- Prometheus stack via Helm (Prometheus, node-exporter, grafana, alert-manager)


## [1.4.0] - 2023-11-25

### Added

Added the possibility to install additional kubernetes components using Terraform scripts (kubectl provider) for:

- Traefik as ingress controller (with optional dashboard ingressroute)

- Cert-manager (with a sample self-signed certificate)

### Changed

- Configured TF Module to setup a hello-nginx deployment/service/ingress to test other installed modules

- Small code refactoring


## [1.3.0] - 2023-11-05

### Added

Added the possibility to setup NFS server on host machine with a dedicated ansible playbook. Usage is documented in README.md as "Step 4"

### Changed

- Master and worker roles now include tasks and vars to setup NFS client and server

- in config.ini you can now specify nfs_volume_path to mount the NFS server on master node (see README.md for details)

- Adjustments in tag definition in roles to distinguish between k8s and nfs steps


## [1.2.0] - 2023-06-11

### Added

Added the possibility to install additional components using Terraform scripts (kubectl provider) for:

- Metallb (with L2 address pools specifying address range for Service Load Balancer objects)

### Changed

- 00_requirements.sh scripts now also install specified TF version in local-requiments folder

- in config.ini you can now specify TF version to install locally

- Cilium CNI with Hubble UI installation performed via script 03_cilium_install.sh


## [1.1.0] - 2023-05-28

### Added

Installation process now supports setup for Cilium CNI:

- possible to specify on config.ini a cni flag between calico and cilium

- changed master playbook to optionally use calico or cilium (based on specification on config.ini)

- changed *00_requirements.sh* script for installing cilium cli and hubble

### Fixed

Hosts are restarted after first upgrade to ensure linux kernel headers are up to date.

## [1.0.1] - 2023-04-26

### Fixed

Changed Ansible Playbooks instruction to add the following features:

- enable promisc mode on wlan0 iface

- install extra modules to enable dummy modprobe (required to create dummy interface kube-ipvs0)

- playbook code refactoring

## [1.0.0] - 2023-02-20

### Added

- First release