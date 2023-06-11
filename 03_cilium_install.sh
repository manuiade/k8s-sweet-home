#!/bin/bash

read -p "Install Cilium CNI on k8s cluster with Hubble UI [Y/n]: " yn
case $yn in
  [Yy]) ow=0 ;;  
  [Nn]) echo "Nothing else to do.." ; ow=1 ;;
  *) echo "Unknown option.." ; ow=2 ;;
esac


if [[ $ow == 0 ]]; then
  echo "Installing Cilium CNI and Hubble UI.."
  cd local-requirements
  ./cilium install
  ./cilium status --wait
  ./cilium hubble enable --ui
  cd ..

  echo "Cilium installed successfully!!"
fi