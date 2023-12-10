#!/bin/bash

read -p "Install k8s on all nodes using the Ansible playbook? [Y/n]: " yn
case $yn in
  [Yy]) ow=0 ;;  
  [Nn]) echo "Nothing else to do.." ; ow=1 ;;
  *) echo "Unknown option.." ; ow=2 ;;
esac


if [[ $ow == 0 ]]; then
  echo "Running ansible playbook.."
  cd ansible
  ansible-playbook install-k8s.yaml  --tags setup,k8s
fi