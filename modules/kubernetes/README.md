# Kubernetes module (STILL not suitable for everybody)

![Overview](graphs/overview.png)

This module will spin a up all you need in your infrastructure to run
a kubernetes cluster.

## Parameters

You can find them [here](params.md)

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

- Push networking routing outside the module
- Export the information needed to create a target group outside the module
- move from launch configuration to launch template
- region is hardcoded in the bash
- version is hardcoded in the bash
- separate etcd!!!
- rename all workers reference to nodes
- fix/reduce IAM roles power