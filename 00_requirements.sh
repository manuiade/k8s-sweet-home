#!/bin/bash



### ------------------------------------------- START FUNCTIONS DEFINITION -------------------------------------------

function local_requirements_installation {

  # K8s cluster version downloaded from ansible playbook
  sed -i "2s/.*/k8s_version: $k8s_version-00/g" ../ansible/roles/k8s-containerd/vars/main.yaml

  # Local ansible installation (required Python 3 and pip binaries)
  echo "Installing Ansible on local machine..."
  pip3 install ansible

  # Local kubectl client installation (based on provided version)
  echo "Installing kubectl ${k8s_version} on local machine..."
  curl -LO "https://dl.k8s.io/release/v${k8s_version}/bin/linux/amd64/kubectl"
  chmod +x kubectl

  # FOR FUTURE USAGE
  
  # # Local Terraform installation (based on provided version)
  # echo "Installing terraform ${terraform_version} on local machine..."
  # wget https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip
  # unzip terraform_${terraform_version}_linux_amd64.zip
  # rm terraform_${terraform_version}_linux_amd64.zip

  # # Local Helm installation (based on provided version)
  # echo "Installing helm ${helm_version} on local machine..."
  # wget https://get.helm.sh/helm-v${helm_version}-linux-amd64.tar.gz
  # tar -zxvf helm-v${helm_version}-linux-amd64.tar.gz
  # rm helm-v${helm_version}-linux-amd64.tar.gz
  # mv linux-amd64/helm .
  # rm -rf linux-amd64

  echo "All prerequisites have been succesfully installed!"

}


function os_download {

  echo "Downloading ubuntu ${ubuntu_image} image from official repository.."
  wget "${ubuntu_download_url}" -O "os/ubuntu-${ubuntu_image}-server-rpi-original.img.xz"
  echo "Downloaded ubuntu image!"
  
}

### ------------------------------------------- END FUNCTIONS DEFINITION -------------------------------------------



### PARSING CONFIGURATION ###

# Parse config.ini file to get information about k8s version used to install client kubectl and k8s cluster
source <(grep = ./config.ini)

### INSTALL LOCAL REQUIREMENTS ###

echo "----------------- LOCAL REQUIREMENTS INSTALLATION -----------------"

# Decide if create a new local-requirements folder (overwriting existing one) or not
# The local-requirements folder is used to put binaries downloaded from this script

ow=0

if [ -d "local-requirements/" ]; then
  read -p "The 'local-requirements' folder is already present, do you want to overwrite it? [Y/n]: " yn
  case $yn in
    [Yy]) ow=0  ;;  
    [Nn]) echo "Moving to next step.." ; ow=1 ;;
    *) echo "Unknown option.." ; ow=2 ;;
  esac
fi

if [[ $ow == 0 ]]; then
  rm -rf local-requirements
  mkdir local-requirements
  cd local-requirements
  local_requirements_installation
  cd ../
fi



### DOWNLOAD OS IMAGE ###

echo "----------------- DOWNLOAD OS IMAGE -----------------"

# Decide if create the os folder on which download the Ubuntu image (version specified in config)

ow=0

if [ -d "os/" ]; then
  read -p "The 'os' folder is already present, do you want to overwrite it? [Y/n]: " yn
  case $yn in
    [Yy]) ow=0  ;;  
    [Nn]) echo "Moving to next step.." ; ow=1 ;;
    *) echo "Unknown option.." ; ow=2 ;;
  esac
fi

if [[ $ow == 0 ]]; then
  rm -rf os
  mkdir os
  os_download
fi

echo "All done! You can now move on to configure images!"