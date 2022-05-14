locals {
  rd_helper = {
    for value in var.vnis : value.vni => {
      "format_none" = value.route_distinguisher == null ? true : false
      "format_auto" = value.route_distinguisher == "auto" ? true : false
      "format_ipv4" = can(regex("\\.", value.route_distinguisher)) ? true : false
      "format_as2"  = !can(regex("\\.", value.route_distinguisher)) && can(regex(":", value.route_distinguisher)) ? (tonumber(split(":", value.route_distinguisher)[0]) <= 65535 ? true : false) : false
      "format_as4"  = !can(regex("\\.", value.route_distinguisher)) && can(regex(":", value.route_distinguisher)) ? (tonumber(split(":", value.route_distinguisher)[0]) >= 65536 ? true : false) : false
      "value"       = value.route_distinguisher
    }
  }
  rd_dme_format_map = {
    for k, v in local.rd_helper : k => v.format_none ? "unknown:unknown:0:0" : (
      v.format_auto ? "rd:unknown:0:0" : (
        v.format_ipv4 ? "rd:ipv4-nn2:${v.value}" : (
          v.format_as2 ? "rd:as2-nn2:${v.value}" : (
            v.format_as4 ? "rd:as4-nn2:${v.value}" : "unexpected_rd_format"
    ))))
  }


  vni_with_defaults = {
    for value in var.vnis : value.vni => {
      "route_distinguisher"    = value.route_distinguisher
      "route_target_both_auto" = value.route_target_both_auto != null ? value.route_target_both_auto : false
      "route_target_import"    = value.route_target_import != null ? value.route_target_import : []
      "route_target_export"    = value.route_target_export != null ? value.route_target_export : []
    }
  }

  # add RT "auto" to import/export lists
  vni_raw = {
    for key, value in local.vni_with_defaults : key => {
      "route_distinguisher"          = value.route_distinguisher
      "route_target_import_list_raw" = value.route_target_both_auto ? concat(["auto"], value.route_target_import) : value.route_target_import
      "route_target_export_list_raw" = value.route_target_both_auto ? concat(["auto"], value.route_target_export) : value.route_target_export
    }
  }

  vni_flat_all = flatten([
    for key, value in local.vni_raw : [
      {
        "direction" = "import"
        "vni"       = key
        "rt_set"    = toset(value.route_target_import_list_raw)
      },
      {
        "direction" = "export"
        "vni"       = key
        "rt_set"    = toset(value.route_target_export_list_raw)
      }
    ]
  ])

  # filter only import/export lists with length > 0
  # loop for resource "nxos_evpn_vni_route_target_direction"
  vni_map = {
    for entry in local.vni_flat_all :
    "${entry.vni}_${entry.direction}" => entry if length(entry.rt_set) > 0
  }


  # Route Target converter from CLI format to DME format
  rt_helper = {
    for k, v in local.vni_map : k => [
      for value in v.rt_set : {
        "format_auto" = value == "auto" ? true : false
        "format_ipv4" = can(regex("\\.", value)) ? true : false
        "format_as2"  = !can(regex("\\.", value)) && can(regex(":", value)) ? (tonumber(split(":", value)[0]) <= 65535 ? true : false) : false
        "format_as4"  = !can(regex("\\.", value)) && can(regex(":", value)) ? (tonumber(split(":", value)[0]) >= 65536 ? true : false) : false
        "value"       = value
      }
    ]
  }
  rt_dme_format_map = {
    for k, v in local.rt_helper : k => [
      for entry in v :
      entry.format_auto ? "route-target:unknown:0:0" : (
        entry.format_ipv4 ? "route-target:ipv4-nn2:${entry.value}" : (
          entry.format_as2 ? "route-target:as2-nn2:${entry.value}" : (
            entry.format_as4 ? "route-target:as4-nn2:${entry.value}" : "unexpected_rt_format"
      )))
    ]
  }

  # Add DME formatted list of RT to the vni_map
  vni_map_dme = {
    for key, value in local.vni_map : key => merge(value, { "rt_dme_format" : local.rt_dme_format_map[key] })
  }

  # loop for resource "nxos_evpn_vni_route_target"
  vni_flat_dme = {
    for entry in flatten([
      for key, value in local.vni_map_dme : [
        for rt in value.rt_dme_format : {
          "vni"       = value.vni
          "direction" = value.direction
          "rt"        = rt
          "key"       = "${key}_${rt}"
        }
      ]
  ]) : entry.key => entry }
}

resource "nxos_evpn" "rtctrlL2Evpn" {
  device      = var.device
  admin_state = "enabled"
}

resource "nxos_evpn_vni" "rtctrlBDEvi" {
  for_each            = local.rd_dme_format_map
  device              = var.device
  encap               = "vxlan-${each.key}"
  route_distinguisher = each.value

  depends_on = [
    nxos_evpn.rtctrlL2Evpn
  ]
}

resource "nxos_evpn_vni_route_target_direction" "rtctrlRttP" {
  for_each  = local.vni_map
  device    = var.device
  encap     = "vxlan-${each.value.vni}"
  direction = each.value.direction

  depends_on = [
    nxos_evpn.rtctrlL2Evpn
  ]
}

resource "nxos_evpn_vni_route_target" "rtctrlRttEntry" {
  for_each     = local.vni_flat_dme
  device       = var.device
  encap        = "vxlan-${each.value.vni}"
  direction    = each.value.direction
  route_target = each.value.rt
  depends_on = [
    nxos_evpn_vni_route_target_direction.rtctrlRttP
  ]
}
