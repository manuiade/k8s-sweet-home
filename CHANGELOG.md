# ChangeLog

All changes to this repository will be documented in this file.

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