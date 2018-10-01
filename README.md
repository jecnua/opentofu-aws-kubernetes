# Module: tf-aws-kubernetes

![https://www.terraform.io/](https://img.shields.io/badge/terraform-v0.9.4-blue.svg?style=flat)
![](https://img.shields.io/badge/preferred-branch-blue.svg?style=flat)

This repo contains the module to install a kubernetes cluster in your
environment. More informations can be found at it's own repo:

[Kubernetes module](modules/kubernetes/README.md)

## Regenerate docs

The script "regenerate.sh" is used to refresh the dependencies and the params file. It should be run it after any parameter change or when new resources are added.

    ./regenerate.sh
    elasticsearch: params regenerated

You need to install _terraform-docs_:

    go get github.com/segmentio/terraform-docs

## Maintainers

[Module maintainers](MAINTAINERS.md)
