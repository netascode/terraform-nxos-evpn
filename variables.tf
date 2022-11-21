variable "device" {
  description = "A device name from the provider configuration."
  type        = string
  default     = null
}

variable "vnis" {
  description = <<EOT
  EVPN VNI List.
  Allowed formats `route_distinguisher`: `auto`, `1.1.1.1:1`, `65535:1`."
  Allowed formats `route_target_import`: `auto`, `1.1.1.1:1`, `65535:1`."
  Allowed formats `route_target_export`: `auto`, `1.1.1.1:1`, `65535:1`."
  EOT
  type = list(object({
    vni                    = number
    route_distinguisher    = optional(string)
    route_target_both_auto = optional(bool, false)
    route_target_import    = optional(list(string), [])
    route_target_export    = optional(list(string), [])
  }))
  default = []

  validation {
    condition = alltrue([
      for v in var.vnis : try(v.vni >= 1 && v.vni <= 16777214, false)
    ])
    error_message = "`vni`: Minimum value: `1`. Maximum value: `16777214`."
  }

  validation {
    condition = alltrue(flatten([
      for v in var.vnis : v.route_distinguisher == null || v.route_distinguisher == "auto" || can(regex("\\d+\\.\\d+\\.\\d+\\.\\d+:\\d+", v.route_distinguisher)) || can(regex("\\d+:\\d+", v.route_distinguisher))
    ]))
    error_message = "`route_distinguisher`: Allowed formats: `auto`, `1.1.1.1:1`, `65535:1`."
  }

  validation {
    condition = alltrue(flatten([
      for v in var.vnis : v.route_target_import == null ? [true] : [
        for entry in v.route_target_import : entry == "auto" || can(regex("\\d+\\.\\d+\\.\\d+\\.\\d+:\\d+", entry)) || can(regex("\\d+:\\d+", entry))
      ]
    ]))
    error_message = "`route_target_import`: Allowed formats: `auto`, `1.1.1.1:1`, `65535:1`."
  }

  validation {
    condition = alltrue(flatten([
      for v in var.vnis : v.route_target_export == null ? [true] : [
        for entry in v.route_target_export : entry == "auto" || can(regex("\\d+\\.\\d+\\.\\d+\\.\\d+:\\d+", entry)) || can(regex("\\d+:\\d+", entry))
      ]
    ]))
    error_message = "`route_target_export`: Allowed formats: `auto`, `1.1.1.1:1`, `65535:1`."
  }
}


