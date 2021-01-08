# Terraform module for kubernetes on AWS

[![Actions Status](https://github.com/jecnua/terraform-aws-kubernetes/workflows/Tests/badge.svg)](https://github.com/jecnua/terraform-aws-kubernetes/actions)
![https://www.terraform.io/](https://img.shields.io/badge/terraform-v0.14.x-blue.svg?style=flat)
[![License: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![](https://img.shields.io/maintenance/yes/2021.svg)
[![Average time to resolve an issue](http://isitmaintained.com/badge/resolution/jecnua/terraform-aws-kubernetes.svg)](http://isitmaintained.com/project/jecnua/terraform-aws-kubernetes "Average time to resolve an issue")
[![Percentage of issues still open](http://isitmaintained.com/badge/open/jecnua/terraform-aws-kubernetes.svg)](http://isitmaintained.com/project/jecnua/terraform-aws-kubernetes "Percentage of issues still open")

This repo contains the module to install a kubernetes cluster in your
environment. More informations can be found at its own repo:

- [Kubernetes module](modules/kubernetes/)
- - [Module maintainers](MAINTAINERS.md)

*NOTE*: It only supports Terraform 0.14.x onward

For older Terraform version please use:

- For 0.11 the tag _v0.11.x-last-supported-code_
- For 0.12 the tag _v0.12.x-last-supported-code_
- For 0.13 the tag _v0.13.x-last-supported-code_

## Connect to the cluster

You can follow the guide here:

- [Utilities](utilities/)

## AWS EKS

If you are interested in AWS EKS I can advice to read the following link:

- [https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html](https://www.terraform.io/docs/providers/aws/guides/eks-getting-started.html)

The code is already implemented here:

- [https://github.com/terraform-providers/terraform-provider-aws/tree/master/examples/eks-getting-started](https://github.com/terraform-providers/terraform-provider-aws/tree/master/examples/eks-getting-started)

AWS also released a quickstart here:

- [https://aws.amazon.com/quickstart/architecture/amazon-eks/](https://aws.amazon.com/quickstart/architecture/amazon-eks/)
- [https://github.com/aws-quickstart/quickstart-amazon-eks](https://github.com/aws-quickstart/quickstart-amazon-eks)

## Gotchas

This module is not ready for a production workload. The first thing you want to do if going in that direction is to separate etcd in it's own external cluster or run it with the operator platoform.

The second thing you want to do is add autoscaling to the workers nodes and diversify the set of ec2 server to give different combination of CPU/RAM.

As it is now there is no path to upgrade aside moving the workload to another cluster. It is not a big problem if you run everything stateless, but keep it in mind.

### Implementation choices

At the moment I wanted to avid dependencies to external tools like ansible, so the installation happens in bash with 
cloud-init. This means some architectural choices are defined in there and they can't be modified.

Obviously this can be fixed, just fork and PR into this :)

## Regenerate docs

The script "regenerate.sh" is used to refresh the dependencies and the params file. It should be run it after any parameter change or when new resources are added.

    ./regenerate.sh
    k8s: params regenerated

You need to install _terraform-docs_:

    go get github.com/segmentio/terraform-docs
