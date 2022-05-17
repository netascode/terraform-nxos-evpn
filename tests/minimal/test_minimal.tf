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
