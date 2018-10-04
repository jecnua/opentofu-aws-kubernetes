# Kubernetes module (STILL not suitable for everybody)

![Overview](graphs/overview.png)

This module will spin a up all you need in your infrastructure to run
a kubernetes cluster.

- provider.aws: version = "~> 1.39"
- provider.template: version = "~> 1.0"

## Parameters

You can find them [here](params.md)

## Usage

Remember to [generate a kubeadm token](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-token/#cmd-token-generate):

        kubeadm token generate

Be careful to pass the right subnets in availability_zone!

## Limitations

### K8S Versions

Due to a problem with k8s 1.6+, I am forcing k8s version to 1.5.3 in the
bootstrap file! This may one day be parametric so please branch, do it and PR :)

*THIS MODULE DOES NOT SUPPORT VERSION 1.6.x*

## AMI

The module accepts two parameters:

- ami_id_controller
- ami_id_worker

If nothing is passed, the latest ubuntu will be fetched.
Something else too can be fetched if needed passing different parameters.

Following best practices.

## Notes

The bootstrap file will create a cluster via kubeadm.

    MASTER_IP=`aws ec2 describe-instances --filters "Name=tag:k8s.io/role/master,Values=1" "Name=tag:KubernetesCluster,Values=$CLUSTER_ID" --region='us-east-1' | grep '\"PrivateIpAddress\"' | cut -d ':' -f2 | cut -d'"' -f 2 | uniq`

I use this line to find MY master (it works also if you have multiple clusters).

    $CLUSTER_ID

Must be unique per cluster.

## Gotchas

### 1) kip-preflight-checks

While configuring a new node, I was receiving the following error:

    [preflight] Some fatal errors occurred:
    /var/lib/kubelet is not empty

As a temporary fix I added

    --skip-preflight-checks

So now the new join call is:

    kubeadm join \
    --skip-preflight-checks \
    --token=$CONTROLLER_JOIN_TOKEN $MASTER_IP

## TODO

- FIX the bash
- Move the NAT outside
- Move the IGW outside
- Add a random provider to generate something flexyble to use in naming
- update k8s version to latest. Maybe try one version at the time ;)
- Add tags on resources with path to the module they are defined it
- Create a NAT if the user doesn't pass it
- Create a IGW if the user doesn't pass it
- Make the route optional of they don pass the IGW
- Make the route optional of they don pass the NAT
- Health check on the asg is done via ELB (check for using ALB)
- Push networking routing outside the module
- Export the information needed to create a target group outside the module
- move from launch configuration to launch template
- region is hardcoded in the bash
- version is hardcoded in the bash
- separate etcd!!!
- rename all workers reference to nodes
- fix/reduce IAM roles power