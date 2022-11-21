module "nxos_evpn" {
  source  = "netascode/evpn/nxos"
  version = ">= 0.2.0"

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
}
