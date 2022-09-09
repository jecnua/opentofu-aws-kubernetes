# CRI-O powered nodes

- https://cri-o.io/

Only supports ubuntu.  Tested on 20.04.

Versions: https://github.com/cri-o/cri-o/releases

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [template_file.bootstrap_k8s_cri_installation_docker](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_crio_version"></a> [crio\_version](#input\_crio\_version) | Version to install | `string` | `"1.25"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cri_bootstrap"></a> [cri\_bootstrap](#output\_cri\_bootstrap) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
