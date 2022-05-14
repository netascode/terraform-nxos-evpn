<!-- BEGIN_TF_DOCS -->
[![Tests](https://github.com/netascode/terraform-nxos-evpn/actions/workflows/test.yml/badge.svg)](https://github.com/netascode/terraform-nxos-evpn/actions/workflows/test.yml)

# Terraform NX-OS EVPN Module

Manages NX-OS EVPN

Model Documentation: [Link](https://developer.cisco.com/docs/cisco-nexus-3000-and-9000-series-nx-api-rest-sdk-user-guide-and-api-reference-release-9-3x/#!configuring-vxlan-bgp-evpn)

## Examples

```hcl
module "nxos_evpn" {
  source  = "netascode/evpn/nxos"
  version = ">= 0.1.0"

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
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_nxos"></a> [nxos](#requirement\_nxos) | >= 0.3.8 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_nxos"></a> [nxos](#provider\_nxos) | 0.3.8 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_device"></a> [device](#input\_device) | A device name from the provider configuration. | `string` | `null` | no |
| <a name="input_vnis"></a> [vnis](#input\_vnis) | EVPN VNI List.<br>  Allowed formats `route_distinguisher`: `auto`, `1.1.1.1:1`, `65535:1`."<br>  Allowed formats `route_target_import`: `auto`, `1.1.1.1:1`, `65535:1`."<br>  Allowed formats `route_target_export`: `auto`, `1.1.1.1:1`, `65535:1`." | <pre>list(object({<br>    vni                    = number<br>    route_distinguisher    = optional(string)<br>    route_target_both_auto = optional(bool)<br>    route_target_import    = optional(list(string))<br>    route_target_export    = optional(list(string))<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dn"></a> [dn](#output\_dn) | Distinguished name of the object. |

## Resources

| Name | Type |
|------|------|
| [nxos_evpn.rtctrlL2Evpn](https://registry.terraform.io/providers/netascode/nxos/latest/docs/resources/evpn) | resource |
| [nxos_evpn_vni.rtctrlBDEvi](https://registry.terraform.io/providers/netascode/nxos/latest/docs/resources/evpn_vni) | resource |
| [nxos_evpn_vni_route_target.rtctrlRttEntry](https://registry.terraform.io/providers/netascode/nxos/latest/docs/resources/evpn_vni_route_target) | resource |
| [nxos_evpn_vni_route_target_direction.rtctrlRttP](https://registry.terraform.io/providers/netascode/nxos/latest/docs/resources/evpn_vni_route_target_direction) | resource |
<!-- END_TF_DOCS -->