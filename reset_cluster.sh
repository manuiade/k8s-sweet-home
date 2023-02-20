#!/bin/bash

read -p "Reinstall kubernetes on the nodes using the Ansible playbook? [Y/n]: " yn
case $yn in
  [Yy]) ow=0 ;;  
  [Nn]) echo "Nothing else to do.." ; ow=1 ;;
  *) echo "Unknown option.." ; ow=2 ;;
esac


if [[ $ow == 0 ]]; then
    echo "Reinstalling kubernetes..."
    cd ansible
    ansible-playbook reset-k8s.yaml
    ansible-playbook install-k8s.yaml --tags k8s
    cd ..
    echo "Kubernetes reinstalled successfully on your cluster!!"
fi