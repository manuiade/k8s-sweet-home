#!/bin/bash


boot_offset=1048576
root_offset=537919488

### ------------------------------------------- START FUNCTIONS DEFINITION -------------------------------------------

function node_configuration {

  echo "Creating the node configuration files..."

  # SSH key-pair generation for Ansible access to all machines
  if [ ! -d "ansible/ssh/" ]; then
    mkdir ansible/ssh
    echo "Generating SSH key for Ansible.."
    ssh-keygen -t rsa -f ansible/ssh/ansible
  fi

  ansible_key=$(cat ansible/ssh/ansible.pub)

  if [ ! -d "nodes/" ]; then
    mkdir nodes
  fi

  # This loop will iterate on master and workers list to compile the ansible inventory file
  # Then templates file are used to prepare each node image to have the network configuration alrewady built-in
  # Images once configured are then compressed in order to be flashed to SD cards.
  i=0
  while read p; do

    node=$(echo $p | cut -f1 -d=)
    ip=$(echo $p | cut -f2 -d=)

    if [[ $i -eq 0 ]]; then
      echo "[master]" > ansible/inventory
    fi

    echo $node@$ip >> ansible/inventory

    if [[ $i -eq 0 ]]; then
      echo "[workers]" >> ansible/inventory
    fi
    
    ow=0

    if [ -d "nodes/${node}/" ]; then
      echo "The 'nodes/${node}' folder is already present, do you want to overwrite it? [Y/n]: "
      read -u 3 yn
      case $yn in
        [Yy]) ow=0  ;;  
        [Nn]) ow=1  ;;
      esac
    fi

    if [[ $ow == 1 ]]; then
      i+=1
      continue
    fi

    echo "Configuring node ${node}.."

    # Configure network templates
    rm -rf nodes/$node
    mkdir -p nodes/$node
    echo $node > nodes/$node/hostname

    cp templates/hosts-template nodes/$node/hosts
    sed -i "s/<YOUR_HOSTNAME>/$node/g" nodes/$node/hosts

    cp templates/network-config-template nodes/$node/network-config
    sed -i "s/<YOUR_IP_ADDRESS>/$ip\/24/g" nodes/$node/network-config
    sed -i "s/<YOUR_GATEWAY_ADDRESS>/$gateway_ip/g" nodes/$node/network-config
    sed -i "s/<YOUR_NETWORK_SSID>/$ssid_name/g" nodes/$node/network-config
    sed -i "s/<YOUR_WIFI_PASSWORD>/$ssid_password/g" nodes/$node/network-config

    cp templates/user-data-template nodes/$node/user-data
    sed -i "s/<YOUR_HOSTNAME>/$node/g" nodes/$node/user-data

    echo "Generating SSH key for node ${node}"
    mkdir nodes/${node}/ssh/
    ssh-keygen -t rsa -f nodes/${node}/ssh/${node}

    host_key=$(cat nodes/${node}/ssh/${node}.pub)

    echo "      - $host_key" >> nodes/${node}/user-data
    echo "      - $ansible_key" >> nodes/${node}/user-data

    # Decompress the OS image
    #if [ ! -f "os/$node-image.img.xz" ]; then
    echo "Decompressing the image for node $node.. This should take a few seconds.."
    cp os/ubuntu-${ubuntu_image}-server-rpi-original.img.xz os/$node-image.img.xz
    xz --decompress os/$node-image.img.xz
    echo "New image for $node extracted successfully!"
    #fi

    echo "Preparing OS image for node ${node}.."
    # Mount the /boot sector (512 byte * 2048 sector)
    sudo mkdir mnt
    sudo mount -o offset=$boot_offset os/$node-image.img mnt/
    cd nodes/$node

    # Copy the user configuration
    sudo cp user-data ../../mnt/user-data
    echo "Copied user-data file to destination."
    cd ../../
    sleep 60s

    # Umount the image
    sudo umount mnt
    sudo rm -rf mnt

    # Mount the / sector (512 byte * 1050624)
    sudo mkdir mnt
    sudo mount -o offset=$root_offset os/$node-image.img mnt/
    cd nodes/$node

    # Copy the network configuration
    sudo cp network-config ../../mnt/etc/netplan/network-config.yaml
    sudo cp hostname ../../mnt/etc/hostname
    sudo cp hosts ../../mnt/etc/hosts
    echo "Copied network configuration files to destination."
    cd ../../
    sleep 60s

    # Umount the image
    sudo umount mnt
    sudo rm -rf mnt

    # Recompress the image
    echo "Compressing the image... This could take several minutes.."
    xz --compress os/$node-image.img

    i+=1

    echo "Successfully configured files and os image for node ${node}."

  done 3<&0 <nodes.txt

  echo "All nodes have been configured successfully!"
}

### ------------------------------------------- END FUNCTIONS DEFINITION -------------------------------------------



### PARSING CONFIGURATION ###

# Parse config.ini file to get information about k8s version used to install client kubectl and k8s cluster
source <(grep = ./config.ini)

# Dynamically assign master and worker IPs to a list to better iterate on successive steps
awk '/^\[.*\]$/{obj=$0}/=/{print obj $0}' config.ini | grep '^\['MASTER-NODE'\]' | sed 's/.*]//' > nodes.txt
awk '/^\[.*\]$/{obj=$0}/=/{print obj $0}' config.ini | grep '^\['WORKER-NODES'\]' | sed 's/.*]//' > workers.txt

if [ $(wc -l <nodes.txt) -ne 1 ] || [ $(wc -l <workers.txt) -lt 1 ]; then
  echo "Need exactly one master node and at least one worker node to continue..."
	exit 1
fi

cat workers.txt >> nodes.txt
rm workers.txt


### NODE_CONFIGURATION ###

ow=0

if [ -d "nodes/" ]; then
  read -p "The 'nodes' folder is already present, do you want to overwrite it? \
  This will also overwrite the SSH used by Ansible and the ansible inventory! [Y/n]: " yn
  case $yn in
    [Yy]) ow=0  ;;  
    [Nn]) ow=1  ;;
  esac
fi

if [[ $ow == 0 ]]; then
  rm -rf ansible/ssh
  rm -rf nodes
fi

node_configuration

rm nodes.txt

echo "All done! You can now flash your images to SD cards!"
