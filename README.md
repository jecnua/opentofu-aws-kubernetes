# Terraform module for kubernetes on AWS

[![Build Status](https://travis-ci.com/jecnua/terraform-aws-kubernetes.svg?branch=master)](https://travis-ci.com/jecnua/terraform-aws-kubernetes)
![https://www.terraform.io/](https://img.shields.io/badge/terraform-v0.11.8-blue.svg?style=flat)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This repo contains the module to install a kubernetes cluster in your
environment. More informations can be found at its own repo:

- [Kubernetes module](modules/kubernetes/README.md)
- - [Module maintainers](MAINTAINERS.md)

## Gotchas

This module is not ready for a production workload. The first thing you want to do if going in that direction is to separate etcd in it's own external cluster or run it with the operator platoform.

The second thing you want to do is add autoscaling to the workers nodes and diversify the set of ec2 server to give different combination of CPU/RAM.

As it is now there is no path to upgrade aside moving the workload to another cluster. It is not a big problem if you run everything stateless, but keep it in mind.

### Implementation choices

At the moment I wanted to avid dependencies to external tools like ansible, so the installation happens in bash with cloud-init. This means some architectural choices are defined in there and they can't be modified. One example is I am using weave as overlay network implementation and swapping it with flannel is not possible.

Obviously this can be fixed, just fork and PR into this :)

## Regenerate docs

The script "regenerate.sh" is used to refresh the dependencies and the params file. It should be run it after any parameter change or when new resources are added.

    ./regenerate.sh
    k8s: params regenerated

You need to install _terraform-docs_:

    go get github.com/segmentio/terraform-docs
