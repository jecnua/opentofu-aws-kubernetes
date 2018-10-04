#!/bin/bash
#

################################################# Dynamic vars (from terraform)

DATA_DIR_NAME=data
CONTROLLER_JOIN_TOKEN=${controller_join_token}
IS_WORKER=${is_worker}
CLUSTER_ID=${cluster_id}

################################################# Static

echo "START: "`date` >> /opt/bootstrap_times

AWS_HOSTNAME=`curl http://169.254.169.254/latest/meta-data/local-hostname`
hostname $AWS_HOSTNAME
echo $AWS_HOSTNAME > /etc/hostname
echo "127.0.0.1 $AWS_HOSTNAME" >> /etc/hosts

export DEBIAN_FRONTEND="noninteractive"

apt-get update
apt-get upgrade --assume-yes
apt-get autoremove --assume-yes
apt-get clean
locale-gen en_GB.UTF-8 # Will fix the warning when logging to the box

################################################# If it has drives

# Format drive if present
ISFORMATTED=`file -s /dev/xvdi | grep '/dev/xvdi: data' | wc -l`
if [[ $ISFORMATTED == '1'  ]]
then
  mkfs -t ext4 /dev/xvdi
fi

# Mount drive if present
ISFORMATTED=`file -s /dev/xvdi | grep 'ext4 filesystem data' | wc -l`
if [[ $ISFORMATTED == '1'  ]]
then
  mkdir /opt/$DATA_DIR_NAME
  cp /etc/fstab /etc/fstab.orig
  # As you are running Ubuntu 14.04 LTS it is important to be aware of some
  # performance bugs in the older kernel versions which can cause fsync to crash
  # the box, with the work-around being to mount the filesystem with the
  # data=writeback,relatime,nobarrier parameters. Further discussion around this
  # can be read
  # https://support.elastic.co/hc/en-us/requests/16385
  echo "/dev/xvdi       /opt/$DATA_DIR_NAME      ext4     data=writeback,relatime,nobarrier        0 0" >> /etc/fstab
  mount -a
fi

#################################################

# Add repo
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat << EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

# Update and install
# You need nfs-common to use efs
apt-get update
apt-get install -y docker.io apt-transport-https awscli jq curl nfs-common
apt-get install -y kubelet kubeadm kubectl kubernetes-cni

# Hold these packages back so that we don't accidentally upgrade them.
# TODO: Remove version (locking to avoid bug in kubeadm)
apt-mark hold kubelet kubeadm=1.7.0-00 kubectl kubernetes-cni

# Set new memory limit container with high memory requirements
sysctl -w vm.max_map_count=262144

# ISSUE: https://github.com/kubernetes/kubernetes/issues/36213
# https://github.com/kubernetes/release/pull/198
# https://github.com/kubernetes/kubeadm/issues/28
# Waiting for: https://github.com/kubernetes/kubernetes/pull/29459
# Waiting for: https://github.com/kubernetes/kubernetes/issues/27980
# HACK: https://github.com/kubernetes/release/pull/198
# My horrible bash :)
check_cloud_provider=`cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf | grep 'cloud-provider=aws' | wc -l`
line_to_add='Environment="KUBELET_EXTRA_ARGS=--cloud-provider=aws"'
if [[ $check_cloud_provider == 0 ]]
then
  sed -i "/ExecStart=/ { N; s/ExecStart=\n/$line_to_add\n&/ }" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
fi
# Do this before every other step
systemctl daemon-reload
service kubelet restart

# Adding autocomplete for ubuntu
echo 'source <(kubectl completion bash)' > /etc/bash_completion.d/kubectl

if [[ "x"$IS_WORKER == "x" ]]
then
  # Start as master (no HA)
  # Forcing version
  VERSION='stable-1.7'
  kubeadm init \
    --kubernetes-version $VERSION \
    --token $CONTROLLER_JOIN_TOKEN

  # Install kubectl for ubuntu
  KCTL_USER=ubuntu
  KCTL_HOME=/home/ubuntu
  mkdir -p $KCTL_HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $KCTL_HOME/.kube/config
  sudo chown $KCTL_USER:$KCTL_USER $KCTL_HOME/.kube/config

  # Retag for the lost tag
  # Fix bug https://github.com/kubernetes/kubeadm/issues/124
  # Also: https://github.com/kubernetes/kubernetes/pull/39112
  # Old way
  kubectl label --overwrite no $AWS_HOSTNAME kubeadm.alpha.kubernetes.io/role=master
  # New way
  kubectl label --overwrite no $AWS_HOSTNAME node-role.kubernetes.io/master=true
  # Install CNI plugin
  # kubectl apply -f https://git.io/weave-kube # Install NET
  # New way
  curl -fsSL -o weave-net.yaml "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
  kubectl apply -n kube-system -f weave-net.yaml
  mv weave-net.yaml /opt/weave-net.yaml
  # kubectl cordon $AWS_HOSTNAME
else
  # You need to filter by tag Name to find the master to connect to. You don't
  # know at startup time the ip.
  MASTER_IP=`aws ec2 describe-instances --filters "Name=tag:k8s.io/role/master,Values=1" "Name=tag:KubernetesCluster,Values=$CLUSTER_ID" --region=${region} | grep '\"PrivateIpAddress\"' | cut -d ':' -f2 | cut -d'"' -f 2 | uniq`
  # Read gotchas #1
  echo "Connecting to $MASTER_IP port 6443"
  echo "Connecting with token $CONTROLLER_JOIN_TOKEN"
  kubeadm join --token $CONTROLLER_JOIN_TOKEN $MASTER_IP:6443
fi

touch /opt/bootstrap_completed
echo "END: "`date` >> /opt/bootstrap_times
