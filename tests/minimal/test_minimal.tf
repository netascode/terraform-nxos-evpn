terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }

    nxos = {
      source  = "netascode/nxos"
      version = ">= 0.3.8"
    }
  }
}

# requirement
resource "nxos_feature_bgp" "bgp" {
  admin_state = "enabled"
}

resource "nxos_feature_nv_overlay" "nvo" {
  admin_state = "enabled"
}

resource "nxos_feature_evpn" "evpn" {
  admin_state = "enabled"

  depends_on = [
    nxos_feature_nv_overlay.nvo
  ]
}

module "main" {
  source = "../.."

  depends_on = [
    nxos_feature_evpn.evpn,
    nxos_feature_bgp.bgp
  ]
}

data "nxos_nve_interface" "nvoEp" {
  depends_on = [module.main]
}

resource "test_assertions" "nvoEp" {
  component = "nvoEp"

  equal "admin_state" {
    description = "admin_state"
    got         = data.nxos_nve_interface.nvoEp.admin_state
    want        = "disabled"
  }

  equal "advertise_virtual_mac" {
    description = "advertise_virtual_mac"
    got         = data.nxos_nve_interface.nvoEp.advertise_virtual_mac
    want        = false
  }

  equal "hold_down_time" {
    description = "hold_down_time"
    got         = data.nxos_nve_interface.nvoEp.hold_down_time
    want        = 180
  }

  equal "host_reachability_protocol" {
    description = "host_reachability_protocol"
    got         = data.nxos_nve_interface.nvoEp.host_reachability_protocol
    want        = "Flood-and-learn"
  }

  equal "ingress_replication_protocol_bgp" {
    description = "ingress_replication_protocol_bgp"
    got         = data.nxos_nve_interface.nvoEp.ingress_replication_protocol_bgp
    want        = false
  }

  equal "multisite_source_interface" {
    description = "multisite_source_interface"
    got         = data.nxos_nve_interface.nvoEp.multisite_source_interface
    want        = "unspecified"
  }

  equal "source_interface" {
    description = "source_interface"
    got         = data.nxos_nve_interface.nvoEp.source_interface
    want        = "unspecified"
  }

  equal "suppress_arp" {
    description = "suppress_arp"
    got         = data.nxos_nve_interface.nvoEp.suppress_arp
    want        = false
  }

  equal "suppress_mac_route" {
    description = "suppress_mac_route"
    got         = data.nxos_nve_interface.nvoEp.suppress_mac_route
    want        = false
  }
}
