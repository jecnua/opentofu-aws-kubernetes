# Terraform module for kubernetes on AWS

[![Actions Status](https://github.com/jecnua/terraform-aws-kubernetes/workflows/Tests/badge.svg)](https://github.com/jecnua/terraform-aws-kubernetes/actions)
![https://www.terraform.io/](https://img.shields.io/badge/terraform-v1.2.x-blue.svg?style=flat)
[![License: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![](https://img.shields.io/maintenance/yes/2022.svg)
[![Average time to resolve an issue](http://isitmaintained.com/badge/resolution/jecnua/terraform-aws-kubernetes.svg)](http://isitmaintained.com/project/jecnua/terraform-aws-kubernetes "Average time to resolve an issue")
[![Percentage of issues still open](http://isitmaintained.com/badge/open/jecnua/terraform-aws-kubernetes.svg)](http://isitmaintained.com/project/jecnua/terraform-aws-kubernetes "Percentage of issues still open")

This repository contains a set of modules that will allow you to install a kubernetes cluster in your own AWS environment.
No other cloud provider is supported.

This module *is not* intended to be used for production workload, but only as a personal and short-lived cluster where
you can test new setups and play with technology. This is one of the reason this repository is only terraform and bash.
There is no ansible or tools used in the configuration: nothing between you and the underlying technology.

Play, learn and have fun.

More information on each module can be found at the following links:

- [controller module](modules/controllers/): Spin up a single master to be used as control plane. No HA is supported.
- [nodes module](modules/nodes/): Spin up a set of nodes to act as nodes for the cluster (require a cri module as parameter)
- [cri modules](modules/cri/): Choose which container engine to use for your nodes
    - [containerd module](modules/cri/containerd): containerd with gvisor support
    - [cri-o module](modules/cri/cri-o): cri-o
    - [docker module](modules/cri/docker): vanilla docker engine

[Module maintainers](MAINTAINERS.md)

## Supported terraform versions

*NOTE*: It only supports Terraform 1.2.x onward

For older Terraform version please use:

- For 0.11 the tag _v0.11.x-last-supported-code_
- For 0.12 the tag _v0.12.x-last-supported-code_
- For 0.13 the tag _v0.13.x-last-supported-code_
- For 0.14 the tag _v0.14.x-last-supported-code_

*DISCLAIMER*: The code on these branches is not updated.

## Tests

Unfortunately for now is tested manually. I do however test it weekly :)
Last tested with:

```
$ terraform version
Terraform v1.2.6
on linux_amd64
+ provider registry.terraform.io/hashicorp/aws v4.23.0
+ provider registry.terraform.io/hashicorp/http v3.0.1
+ provider registry.terraform.io/hashicorp/null v3.1.1
+ provider registry.terraform.io/hashicorp/random v3.3.2
+ provider registry.terraform.io/hashicorp/template v2.2.0
```