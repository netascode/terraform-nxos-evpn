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

  admin_state                      = true
  advertise_virtual_mac            = true
  hold_down_time                   = 123
  host_reachability_protocol       = "bgp"
  ingress_replication_protocol_bgp = true
  source_interface                 = "lo0"
  suppress_arp                     = true
  suppress_mac_route               = false
  vnis = [
    {
      vni           = 10
      associate_vrf = true
    },
    {
      vni           = 11
      associate_vrf = true
    },
    {
      vni             = 12
      multicast_group = "239.1.1.1"
    },
    {
      vni                          = 13
      ingress_replication_protocol = "bgp"
      suppress_arp                 = "enabled"
    },
    {
      vni                          = 14
      ingress_replication_protocol = "unknown"
    }
  ]

  depends_on = [
    nxos_feature_evpn.evpn
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
    want        = "enabled"
  }

  equal "advertise_virtual_mac" {
    description = "advertise_virtual_mac"
    got         = data.nxos_nve_interface.nvoEp.advertise_virtual_mac
    want        = true
  }

  equal "hold_down_time" {
    description = "hold_down_time"
    got         = data.nxos_nve_interface.nvoEp.hold_down_time
    want        = 123
  }

  equal "host_reachability_protocol" {
    description = "host_reachability_protocol"
    got         = data.nxos_nve_interface.nvoEp.host_reachability_protocol
    want        = "bgp"
  }

  equal "ingress_replication_protocol_bgp" {
    description = "ingress_replication_protocol_bgp"
    got         = data.nxos_nve_interface.nvoEp.ingress_replication_protocol_bgp
    want        = true
  }

  equal "multisite_source_interface" {
    description = "multisite_source_interface"
    got         = data.nxos_nve_interface.nvoEp.multisite_source_interface
    want        = "unspecified"
  }

  equal "source_interface" {
    description = "source_interface"
    got         = data.nxos_nve_interface.nvoEp.source_interface
    want        = "lo0"
  }

  equal "suppress_arp" {
    description = "suppress_arp"
    got         = data.nxos_nve_interface.nvoEp.suppress_arp
    want        = true
  }

  equal "suppress_mac_route" {
    description = "suppress_mac_route"
    got         = data.nxos_nve_interface.nvoEp.suppress_mac_route
    want        = false
  }
}

data "nxos_nve_vni" "nvoNw12" {
  vni = 12

  depends_on = [module.main]
}

resource "test_assertions" "nvoNw12" {
  component = "nvoNw12"

  equal "vni" {
    description = "vni"
    got         = data.nxos_nve_vni.nvoNw12.vni
    want        = 12
  }

  equal "associate_vrf" {
    description = "associate_vrf"
    got         = data.nxos_nve_vni.nvoNw12.associate_vrf
    want        = false
  }

  equal "multicast_group" {
    description = "multicast_group"
    got         = data.nxos_nve_vni.nvoNw12.multicast_group
    want        = "239.1.1.1"
  }

  equal "multisite_ingress_replication" {
    description = "multisite_ingress_replication"
    got         = data.nxos_nve_vni.nvoNw12.multisite_ingress_replication
    want        = "disable"
  }

  equal "suppress_arp" {
    description = "suppress_arp"
    got         = data.nxos_nve_vni.nvoNw12.suppress_arp
    want        = "off"
  }
}

data "nxos_nve_vni" "nvoNw13" {
  vni = 13

  depends_on = [module.main]
}

resource "test_assertions" "nvoNw13" {
  component = "nvoNw13"

  equal "vni" {
    description = "vni"
    got         = data.nxos_nve_vni.nvoNw13.vni
    want        = 13
  }

  equal "associate_vrf" {
    description = "associate_vrf"
    got         = data.nxos_nve_vni.nvoNw13.associate_vrf
    want        = false
  }

  equal "multicast_group" {
    description = "multicast_group"
    got         = data.nxos_nve_vni.nvoNw13.multicast_group
    want        = "0.0.0.0"
  }

  equal "multisite_ingress_replication" {
    description = "multisite_ingress_replication"
    got         = data.nxos_nve_vni.nvoNw13.multisite_ingress_replication
    want        = "disable"
  }

  equal "suppress_arp" {
    description = "suppress_arp"
    got         = data.nxos_nve_vni.nvoNw13.suppress_arp
    want        = "enabled"
  }
}

data "nxos_nve_vni_ingress_replication" "nvoIngRepl" {
  vni = 13

  depends_on = [module.main]
}

resource "test_assertions" "nvoIngRepl" {
  component = "nvoIngRepl"

  equal "protocol" {
    description = "protocol"
    got         = data.nxos_nve_vni_ingress_replication.nvoIngRepl.protocol
    want        = "bgp"
  }
}
