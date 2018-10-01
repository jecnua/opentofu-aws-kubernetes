# Terraform module for kubernetes on AWS

![https://www.terraform.io/](https://img.shields.io/badge/terraform-v0.9.4-blue.svg?style=flat)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

*NOTE*: This module is now opensource but the version of k8s it installs is very old.
I will work on updating it but in the meantime use this repo just to see another possible
implementation of k8s on AWS but don't use it.

This repo contains the module to install a kubernetes cluster in your
environment. More informations can be found at its own repo:

- [Kubernetes module](modules/kubernetes/README.md)

## Regenerate docs

The script "regenerate.sh" is used to refresh the dependencies and the params file. It should be run it after any parameter change or when new resources are added.

    ./regenerate.sh
    elasticsearch: params regenerated

You need to install _terraform-docs_:

    go get github.com/segmentio/terraform-docs

## Maintainers

[Module maintainers](MAINTAINERS.md)
