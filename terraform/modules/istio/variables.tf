variable "helm_chart" {
  type = object({
    repository       = optional(string, null)
    version          = optional(string, null)
    namespace        = optional(string, "istio-system")
    create_namespace = optional(bool, true)
    force_update     = optional(bool, false)
    values           = optional(list(string), [])
    set              = optional(map(string), {})
  })
}

variable "defaultRevision" {
  type = string
  default = "default"
}