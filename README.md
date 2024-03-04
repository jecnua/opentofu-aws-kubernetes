# Terraform module for kubernetes on AWS

[![Actions Status](https://github.com/jecnua/terraform-aws-kubernetes/workflows/Tests/badge.svg)](https://github.com/jecnua/terraform-aws-kubernetes/actions)
![https://github.com/opentffoundation/manifesto](https://img.shields.io/badge/OpenTF-1.6.0-blue.svg?style=flat)
![https://www.terraform.io/](https://img.shields.io/badge/terraform-<=v1.5.5-red.svg?style=flat)
[![License: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![](https://img.shields.io/maintenance/yes/2023.svg)

# Disclaimer - OpenTF support

- [https://github.com/opentffoundation/manifesto](https://github.com/opentffoundation/manifesto)

    I support OpenTF. As soon as the first version of OpenTF is available this repo will switch to it and 
    any "direct" support of terraform will be dropped. I will tag the last commit tested on 1.5.5 for people 
    that wants to use terraform or fork from there. Realistically the fork will not diverge immediately anyway.

# Module

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

## Terraform

### Supported terraform versions

This module will only support up to terraform 1.5.5 (due to the change of licence).

### Providers

Unfortunately for now is tested manually. Last tested with:

```
$ terraform version
Terraform v1.5.5
on linux_amd64
+ provider registry.terraform.io/hashicorp/aws v5.14.0
+ provider registry.terraform.io/hashicorp/external v2.3.1
+ provider registry.terraform.io/hashicorp/http v3.4.0
+ provider registry.terraform.io/hashicorp/null v3.2.1
+ provider registry.terraform.io/hashicorp/random v3.5.1
+ provider registry.terraform.io/hashicorp/template v2.2.0
```