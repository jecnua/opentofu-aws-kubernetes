#!/bin/bash

### Dynamic vars (from terraform)

DATA_DIR_NAME=data
# shellcheck disable=SC2154
CONTROLLER_JOIN_TOKEN=${controller_join_token}
# shellcheck disable=SC2154
IS_WORKER=${is_worker}
# shellcheck disable=SC2154
CLUSTER_ID=${cluster_id}
# shellcheck disable=SC2154
K8S_DEB_PACKAGES_VERSION=${k8s_deb_package_version}
# shellcheck disable=SC2154
KUBEADM_VERSION_OF_K8S_TO_INSTALL=${kubeadm_install_version}
KCTL_USER='ubuntu'

STERN_VERSION='1.11.0'

### Statics

echo "START: $(date)" >> /opt/bootstrap_times

AWS_HOSTNAME=$(curl http://169.254.169.254/latest/meta-data/local-hostname)
hostname "$AWS_HOSTNAME"
echo "$AWS_HOSTNAME" > /etc/hostname
echo "127.0.0.1 $AWS_HOSTNAME" >> /etc/hosts

export DEBIAN_FRONTEND="noninteractive"

${pre_install}

apt-get update
apt-get upgrade --assume-yes
apt-get autoremove --assume-yes
apt-get clean

locale-gen en_GB.UTF-8 # Will fix the warning when logging to the box

################################################# If it has drives

# Format drive if present
ISFORMATTED=$(file -s /dev/xvdi | grep -c '/dev/xvdi: data')
if [[ "$ISFORMATTED" == '1'  ]]
then
  mkfs -t ext4 /dev/xvdi
fi

# Mount drive if present
ISFORMATTED=$(file -s /dev/xvdi | grep -c 'ext4 filesystem data')
if [[ $ISFORMATTED == '1'  ]]
then
  mkdir /opt/$DATA_DIR_NAME
  cp /etc/fstab /etc/fstab.orig
  echo "/dev/xvdi       /opt/$DATA_DIR_NAME      ext4     data=writeback,relatime,nobarrier        0 0" >> /etc/fstab
  mount -a
fi

#################################################

#apt update
#apt install gnupg2 ca-certificates
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6A030B21BA07F4FB
#kubeadm config print init-defaults

# Add k8s repo
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat << EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

# You need nfs-common to use efs
apt update
apt install -y \
  docker.io \
  apt-transport-https \
  awscli \
  jq \
  curl \
  nfs-common \
  net-tools \
  etcd-client
# This need to be synchronized
apt install -y \
  kubelet="$K8S_DEB_PACKAGES_VERSION-00" \
  kubeadm="$K8S_DEB_PACKAGES_VERSION-00" \
  kubectl="$K8S_DEB_PACKAGES_VERSION-00"

# Install stern
wget "https://github.com/wercker/stern/releases/download/$STERN_VERSION/stern_linux_amd64"
chmod +x stern_linux_amd64
mv stern_linux_amd64 /usr/local/bin/stern

# Hold these packages back so that we don't accidentally upgrade them.
# TODO: Remove version (locking to avoid bug in kubeadm)
apt-mark hold kubelet kubeadm kubectl kubernetes-cni

# Set new memory limit container with high memory requirements
sysctl -w vm.max_map_count=262144

## Configure docker deamon
# From https://kubernetes.io/docs/setup/production-environment/container-runtimes/
# Solves [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd".
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
systemctl daemon-reload
systemctl restart docker
# Avoids [WARNING Service-Docker]: docker service is not enabled, please run 'systemctl enable docker.service'
systemctl enable docker.service
# Adding user on docker group
sudo usermod -aG docker "$KCTL_USER"

echo 'KUBELET_EXTRA_ARGS=--cloud-provider=aws' > /etc/default/kubelet

# Adding autocomplete
echo 'source <(kubectl completion bash)' > /etc/bash_completion.d/kubectl

if [[ "x"$IS_WORKER == "x" ]]
then
  # Start as master (no HA)

  # Forcing version
  VERSION=$KUBEADM_VERSION_OF_K8S_TO_INSTALL
  cat <<EOF > "/home/$KCTL_USER/kubeadm-config.yaml"
${kubeadm_config}
EOF

  # Create the ETCD encryption file
  mkdir -p /etc/kubernetes/etcd-encryption/
  cat <<EOF > "/etc/kubernetes/etcd-encryption/etcd-enc.yaml"
${kubeadm_etcd_encryption}
EOF
  # TODO: Temporary.
  # When doing multimaster this secrets needs to be the same, plus if you want the ETCD
  # snapshot to make sense, you need to keep this between cluster
  # Move it to a AWS Parameter Store or Secret Manager
  etcd_secret=$(head -c 32 /dev/urandom | base64)
  sed -i "s|PLACEHOLDER|$etcd_secret|g" /etc/kubernetes/etcd-encryption/etcd-enc.yaml
  chmod 600 /etc/kubernetes/etcd-encryption/etcd-enc.yaml

  kubeadm init --config "/home/$KCTL_USER/kubeadm-config.yaml" --v=5
  cd /home/$KCTL_USER || exit
  mkdir -p /home/$KCTL_USER/.kube
  sudo cp -i /etc/kubernetes/admin.conf /home/$KCTL_USER/.kube/config
  sudo chown "$KCTL_USER":"$KCTL_USER" -R /home/$KCTL_USER/.kube
  echo "export KUBECONFIG=/home/$KCTL_USER/.kube/config" | tee -a /home/$KCTL_USER/.bashrc
  su "$KCTL_USER" -c "kubectl label --overwrite no $AWS_HOSTNAME node-role.kubernetes.io/master=true"
  # Install CNI plugin
  ${cni_install}
else
  # You need to filter by tag Name to find the master to connect to. You don't
  # know at startup time the ip.
  # Read gotchas #1
  AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
  MASTER_IP=$(aws ec2 describe-instances --filters "Name=tag:k8s.io/role/master,Values=1" "Name=tag:KubernetesCluster,Values=$CLUSTER_ID" --region="$AWS_REGION" | grep '\"PrivateIpAddress\"' | cut -d ':' -f2 | cut -d'"' -f 2 | uniq)
  cat <<EOF > "/home/$KCTL_USER/kubeadm-join-config.yaml"
${kubeadm_join_config}
EOF
  # Replacing with the master ip
  sed -i "s/MASTERIP/$MASTER_IP/g" "/home/$KCTL_USER/kubeadm-join-config.yaml"
  kubeadm join --config "/home/$KCTL_USER/kubeadm-join-config.yaml" --v=5
  # FIX CIS: [FAIL] 4.2.6 Ensure that the --protect-kernel-defaults argument is set to true (Automated)
  echo 'protectKernelDefaults: true' >> /var/lib/kubelet/config.yaml
fi

${post_install}

touch /opt/bootstrap_completed
echo "END: $(date)" >> /opt/bootstrap_times
