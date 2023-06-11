variable "calico_cni" {
  type        = bool
  description = "Whether or not Calico CNI is used"
  default     = true
}

variable "metallb_manifest_url" {
  type        = string
  description = "Metallb Manifest Url"
}

variable "install_metallb" {
  type        = bool
  description = "Call metallb module to install metallb"
  default     = false
}

variable "metallb_ip_range" {
  type        = string
  description = "IP CIDR range for metallb Load Balancer IPs"
  default     = ""
}