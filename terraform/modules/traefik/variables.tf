variable "helm_chart" {
  type = object({
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
}

variable "expose_dashboard" {
  type    = bool
  default = false
}