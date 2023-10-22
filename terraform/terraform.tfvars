calico_cni           = false

# Set to true if you want to install a specific component
install_metallb  = true
metallb_manifest_url = "https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml"
metallb_ip_range = "192.168.178.8/30"