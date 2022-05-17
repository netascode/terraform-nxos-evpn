terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }

    nxos = {
      source  = "netascode/nxos"
      version = ">= 0.3.11"
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

  vnis = [
    {
      vni                 = 1001
      route_distinguisher = "1:1"
      route_target_import = ["1.1.1.1:1", "65535:1", "65536:123"]
      route_target_export = ["1.1.1.1:1", "65535:1", "65536:123"]
    },
    {
      vni                    = 1002
      route_distinguisher    = "auto"
      route_target_both_auto = true
    }
  ]

  depends_on = [
    nxos_feature_evpn.evpn,
    nxos_feature_bgp.bgp
  ]
}

data "nxos_evpn" "rtctrlL2Evpn" {
  depends_on = [module.main]
}

resource "test_assertions" "rtctrlL2Evpn" {
  component = "rtctrlL2Evpn"

  equal "admin_state" {
    description = "admin_state"
    got         = data.nxos_evpn.rtctrlL2Evpn.admin_state
    want        = "enabled"
  }
}

data "nxos_evpn_vni" "rtctrlBDEvi_1001" {
  encap      = "vxlan-1001"
  depends_on = [module.main]
}

resource "test_assertions" "rtctrlBDEvi_1001" {
  component = "rtctrlBDEvi_1001"

  equal "encap" {
    description = "encap"
    got         = data.nxos_evpn_vni.rtctrlBDEvi_1001.encap
    want        = "vxlan-1001"
  }

  equal "route_distinguisher" {
    description = "route_distinguisher"
    got         = data.nxos_evpn_vni.rtctrlBDEvi_1001.route_distinguisher
    want        = "rd:as2-nn2:1:1"
  }
}

data "nxos_evpn_vni" "rtctrlBDEvi_1002" {
  encap      = "vxlan-1002"
  depends_on = [module.main]
}

resource "test_assertions" "rtctrlBDEvi_1002" {
  component = "rtctrlBDEvi_1002"

  equal "encap" {
    description = "encap"
    got         = data.nxos_evpn_vni.rtctrlBDEvi_1002.encap
    want        = "vxlan-1002"
  }

  equal "route_distinguisher" {
    description = "route_distinguisher"
    got         = data.nxos_evpn_vni.rtctrlBDEvi_1002.route_distinguisher
    want        = "rd:unknown:0:0"
  }
}

data "nxos_evpn_vni_route_target_direction" "rtctrlRttP_1001_import" {
  encap      = "vxlan-1001"
  direction  = "import"
  depends_on = [module.main]
}

resource "test_assertions" "rtctrlRttP_1001_import" {
  component = "rtctrlRttP_1001_import"

  equal "encap" {
    description = "encap"
    got         = data.nxos_evpn_vni_route_target_direction.rtctrlRttP_1001_import.encap
    want        = "vxlan-1001"
  }

  equal "direction" {
    description = "direction"
    got         = data.nxos_evpn_vni_route_target_direction.rtctrlRttP_1001_import.direction
    want        = "import"
  }
}

data "nxos_evpn_vni_route_target_direction" "rtctrlRttP_1001_export" {
  encap      = "vxlan-1001"
  direction  = "export"
  depends_on = [module.main]
}

resource "test_assertions" "rtctrlRttP_1001_export" {
  component = "rtctrlRttP_1001_export"

  equal "encap" {
    description = "encap"
    got         = data.nxos_evpn_vni_route_target_direction.rtctrlRttP_1001_export.encap
    want        = "vxlan-1001"
  }

  equal "direction" {
    description = "direction"
    got         = data.nxos_evpn_vni_route_target_direction.rtctrlRttP_1001_export.direction
    want        = "export"
  }
}

data "nxos_evpn_vni_route_target_direction" "rtctrlRttP_1002_import" {
  encap      = "vxlan-1002"
  direction  = "import"
  depends_on = [module.main]
}

resource "test_assertions" "rtctrlRttP_1002_import" {
  component = "rtctrlRttP_1002_import"

  equal "encap" {
    description = "encap"
    got         = data.nxos_evpn_vni_route_target_direction.rtctrlRttP_1002_import.encap
    want        = "vxlan-1002"
  }

  equal "direction" {
    description = "direction"
    got         = data.nxos_evpn_vni_route_target_direction.rtctrlRttP_1002_import.direction
    want        = "import"
  }
}

data "nxos_evpn_vni_route_target_direction" "rtctrlRttP_1002_export" {
  encap      = "vxlan-1002"
  direction  = "export"
  depends_on = [module.main]
}

resource "test_assertions" "rtctrlRttP_1002_export" {
  component = "rtctrlRttP_1002_export"

  equal "encap" {
    description = "encap"
    got         = data.nxos_evpn_vni_route_target_direction.rtctrlRttP_1002_export.encap
    want        = "vxlan-1002"
  }

  equal "direction" {
    description = "direction"
    got         = data.nxos_evpn_vni_route_target_direction.rtctrlRttP_1002_export.direction
    want        = "export"
  }
}

data "nxos_evpn_vni_route_target" "rtctrlRttEntry_import_65535_1" {
  encap        = "vxlan-1001"
  direction    = "import"
  route_target = "route-target:as2-nn2:65535:1"
  depends_on   = [module.main]
}

resource "test_assertions" "rtctrlRttEntry_import_65535_1" {
  component = "rtctrlRttEntry_import_65535_1"

  equal "encap" {
    description = "encap"
    got         = data.nxos_evpn_vni_route_target.rtctrlRttEntry_import_65535_1.encap
    want        = "vxlan-1001"
  }

  equal "direction" {
    description = "direction"
    got         = data.nxos_evpn_vni_route_target.rtctrlRttEntry_import_65535_1.direction
    want        = "import"
  }

  equal "route_target" {
    description = "route_target"
    got         = data.nxos_evpn_vni_route_target.rtctrlRttEntry_import_65535_1.route_target
    want        = "route-target:as2-nn2:65535:1"
  }
}

data "nxos_evpn_vni_route_target" "rtctrlRttEntry_import_65536_123" {
  encap        = "vxlan-1001"
  direction    = "import"
  route_target = "route-target:as4-nn2:65536:123"
  depends_on   = [module.main]
}

resource "test_assertions" "rtctrlRttEntry_import_65536_123" {
  component = "rtctrlRttEntry_import_65536_123"

  equal "encap" {
    description = "encap"
    got         = data.nxos_evpn_vni_route_target.rtctrlRttEntry_import_65536_123.encap
    want        = "vxlan-1001"
  }

  equal "direction" {
    description = "direction"
    got         = data.nxos_evpn_vni_route_target.rtctrlRttEntry_import_65536_123.direction
    want        = "import"
  }

  equal "route_target" {
    description = "route_target"
    got         = data.nxos_evpn_vni_route_target.rtctrlRttEntry_import_65536_123.route_target
    want        = "route-target:as4-nn2:65536:123"
  }
}

data "nxos_evpn_vni_route_target" "rtctrlRttEntry_import_1111_1" {
  encap        = "vxlan-1001"
  direction    = "import"
  route_target = "route-target:ipv4-nn2:1.1.1.1:1"
  depends_on   = [module.main]
}

resource "test_assertions" "rtctrlRttEntry_import_1111_1" {
  component = "rtctrlRttEntry_import_1111_1"

  equal "encap" {
    description = "encap"
    got         = data.nxos_evpn_vni_route_target.rtctrlRttEntry_import_1111_1.encap
    want        = "vxlan-1001"
  }

  equal "direction" {
    description = "direction"
    got         = data.nxos_evpn_vni_route_target.rtctrlRttEntry_import_1111_1.direction
    want        = "import"
  }

  equal "route_target" {
    description = "route_target"
    got         = data.nxos_evpn_vni_route_target.rtctrlRttEntry_import_1111_1.route_target
    want        = "route-target:ipv4-nn2:1.1.1.1:1"
  }
}

data "nxos_evpn_vni_route_target" "rtctrlRttEntry_import_auto" {
  encap        = "vxlan-1002"
  direction    = "import"
  route_target = "route-target:unknown:0:0"
  depends_on   = [module.main]
}

resource "test_assertions" "rtctrlRttEntry_import_auto" {
  component = "rtctrlRttEntry_import_1111_1"

  equal "encap" {
    description = "encap"
    got         = data.nxos_evpn_vni_route_target.rtctrlRttEntry_import_auto.encap
    want        = "vxlan-1002"
  }

  equal "direction" {
    description = "direction"
    got         = data.nxos_evpn_vni_route_target.rtctrlRttEntry_import_auto.direction
    want        = "import"
  }

  equal "route_target" {
    description = "route_target"
    got         = data.nxos_evpn_vni_route_target.rtctrlRttEntry_import_auto.route_target
    want        = "route-target:unknown:0:0"
  }
}
