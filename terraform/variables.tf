variable "metallb" {
  type = object({
    install      = bool
    manifest_url = string
    ip_range     = string
    calico_cni   = bool
  })
}

variable "traefik" {
  type = object({
    install = bool
    helm_chart = object({
      name             = string
      chart            = string
      repository       = optional(string, null)
      version          = optional(string, null)
      namespace        = optional(string, "default")
      create_namespace = optional(bool, false)
      force_update     = optional(bool, false)
      values           = optional(list(string), [])
      set              = optional(map(string), {})
    })
    expose_dashboard = optional(bool, false)
  })
}

variable "cert_manager" {
  type = object({
    install = bool
    helm_chart = object({
      name             = string
      chart            = string
      repository       = optional(string, null)
      version          = optional(string, null)
      namespace        = optional(string, "default")
      create_namespace = optional(bool, false)
      force_update     = optional(bool, false)
      values           = optional(list(string), [])
      set              = optional(map(string), {})
    })
    deploy_sample_self_signed_crt = optional(bool, false)
  })
}

variable "hello_nginx" {
  type = object({
    deployment = optional(bool, false)
    service = optional(bool, false)
    ingress_https = optional(bool, false)
  })
  default = {}
}