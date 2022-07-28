# CRI

These modules allow you to set a specific CRI implementation on a set a nodes.

- [containerd module](containerd): Plus gvisor
- [cri-o module](cri-o)

## NOtes

No reason to override KUBELET_EXTRA_ARGS via /etc/default/kubelet like this

    MODULE_KUBELET_EXTRA_ARGS='--container-runtime remote --container-runtime-endpoint unix:///run/containerd/containerd.sock'
    echo 'KUBELET_EXTRA_ARGS=--cloud-provider=aws '$MODULE_KUBELET_EXTRA_ARGS > /etc/default/kubelet

It would result in this double configuration:

    root@ip-10-0-11-82:~# cat /etc/default/kubelet
    KUBELET_EXTRA_ARGS=--cloud-provider=aws --container-runtime remote --container-runtime-endpoint unix:///run/containerd/containerd.sock
    root@ip-10-0-11-82:~# cat /var/lib/kubelet/kubeadm-flags.env
    KUBELET_KUBEADM_ARGS="--cloud-provider=external --container-runtime=remote --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock --pod-infra-container-image=k8s.gcr.io/pause:3.7"

Kubeadm will recognise it automatically