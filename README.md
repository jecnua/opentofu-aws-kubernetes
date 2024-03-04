# Opentofu module for kubernetes on AWS

![https://github.com/opentofu/manifesto](https://img.shields.io/badge/opentofu-1.6.2-blue.svg?style=flat)
[![License: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![](https://img.shields.io/maintenance/yes/2024.svg)

# Module

This repository contains a set of modules that will allow you to install a kubernetes cluster in your own AWS environment.
No other cloud provider is supported.

This module *is not* intended to be used for production workload, but only as a personal and short-lived cluster where
you can test new setups and play with technology. This is one of the reason this repository is only opentofu and bash.
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

## opentofu

### Supported opentofu versions

This module only support opentofu since version v9.0.0.
The last version tested on terraform (1.5.5) is v8.0.0.

### Providers

Unfortunately for now is tested manually. Last tested with:

```
$ tofu version
```