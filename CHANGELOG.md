# ChangeLog

All changes to this repository will be documented in this file.

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