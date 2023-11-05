#!/bin/bash

source <(grep = ./config.ini)

read -p "Setup NFS client and server on host nodes using the Ansible playbook? [Y/n]: " yn
case $yn in
  [Yy]) ow=0 ;;  
  [Nn]) echo "Nothing else to do.." ; ow=1 ;;
  *) echo "Unknown option.." ; ow=2 ;;
esac


if [[ $ow == 0 ]]; then
    echo "Setting up NFS on host nodes..."
    cd ansible
    ansible-playbook setup-nfs.yaml --tags nfs --extra-vars "nfs_device_path=${nfs_device_path}"
    cd ..
    echo "NFS client and server setup successfully on your cluster!!"
fi