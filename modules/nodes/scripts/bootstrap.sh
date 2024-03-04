#!/bin/bash

### Dynamic vars

DATA_DIR_NAME=data
# shellcheck disable=SC2154
K8S_DEB_PACKAGES_VERSION=${k8s_deb_package_version}
KCTL_USER='ubuntu'

### Statics

echo "START: $(date)" >>/opt/bootstrap_times

AWS_HOSTNAME=$(curl http://169.254.169.254/latest/meta-data/local-hostname)

hostname "$AWS_HOSTNAME"
echo "$AWS_HOSTNAME" >/etc/hostname
echo "127.0.0.1 $AWS_HOSTNAME" >>/etc/hosts

export DEBIAN_FRONTEND="noninteractive"

# shellcheck disable=SC2154
${pre_install}

apt-get update
apt-get upgrade --assume-yes
apt-get autoremove --assume-yes
apt-get clean

locale-gen en_GB.UTF-8 # Will fix the warning when logging to the box

################################################# If it has drives

# Format drive if present
ISFORMATTED=$(file -s /dev/xvdi | grep -c '/dev/xvdi: data')
if [[ "$ISFORMATTED" == '1' ]]; then
	mkfs -t ext4 /dev/xvdi
fi

# Mount drive if present
ISFORMATTED=$(file -s /dev/xvdi | grep -c 'ext4 filesystem data')
if [[ $ISFORMATTED == '1' ]]; then
	mkdir /opt/$DATA_DIR_NAME
	cp /etc/fstab /etc/fstab.orig
	echo "/dev/xvdi       /opt/$DATA_DIR_NAME      ext4     data=writeback,relatime,nobarrier        0 0" >>/etc/fstab
	mount -a
fi

#################################################

#apt update
#apt install gnupg2 ca-certificates
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6A030B21BA07F4FB
#kubeadm config print init-defaults

# Add k8s repo
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

# You need nfs-common to use efs
apt update
apt install -y \
	apt-transport-https \
	awscli \
	jq \
	curl \
	nfs-common \
	net-tools \
	binutils \
	apparmor-utils
# This need to be synchronized
apt install -y \
	kubelet="$K8S_DEB_PACKAGES_VERSION-00" \
	kubeadm="$K8S_DEB_PACKAGES_VERSION-00" \
	kubectl="$K8S_DEB_PACKAGES_VERSION-00"

# Hold these packages back so that we don't accidentally upgrade them.
# TODO: Remove version (locking to avoid bug in kubeadm)
apt-mark hold kubelet kubeadm kubectl kubernetes-cni

# Install falco
curl -s https://falco.org/repo/falcosecurity-3672BA8F.asc | apt-key add -
echo "deb https://download.falco.org/packages/deb stable main" | tee -a /etc/apt/sources.list.d/falcosecurity.list
apt update -y
apt -y install "linux-headers-$(uname -r)"
apt install -y falco
systemctl start falco
systemctl status falco

# Set new memory limit container with high memory requirements
sysctl -w vm.max_map_count=262144

cat <<'TEOF' >"/opt/install-cri.sh"
${cri_installation}
TEOF
chmod +x /opt/install-cri.sh
/opt/install-cri.sh

# You need to filter by tag Name to find the master to connect to. You don't
# know at startup time the ip.
# Read gotchas #1
cat <<EOF >"/home/$KCTL_USER/kubeadm-join-config.yaml"
${kubeadm_join_config}
EOF
# Replacing the API_SERVER_ENDPOINT
sed -i "s/API_SERVER_ENDPOINT/${lb_dns}/g" "/home/$KCTL_USER/kubeadm-join-config.yaml"

#=======================================================================================================================
# Get a fresh join token and the CA Hash

AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
SECRET_ARN=${secret_arn}
while true; do
	TOKEN=$(aws secretsmanager get-secret-value --secret-id "$SECRET_ARN" --region "$AWS_REGION" | jq --raw-output '.SecretString' | jq --raw-output '.token')
	HASH=$(aws secretsmanager get-secret-value --secret-id "$SECRET_ARN" --region "$AWS_REGION" | jq --raw-output '.SecretString' | jq --raw-output '.hash')
	#  echo TOKEN: "$TOKEN"
	#  echo HASH: "$HASH"
	# shellcheck disable=SC2000
	if [[ $(echo "$HASH" | wc -c) == "65" ]]; then
		echo "Value found..."
		break
	else
		echo "Wait 10 seconds..."
		sleep 10
	fi
done
# Substitute the join token and hash
sed -i "s/CONTROLLERJOINTOKEN/$TOKEN/g" "/home/$KCTL_USER/kubeadm-join-config.yaml"
sed -i "s/CAHASH/$HASH/g" "/home/$KCTL_USER/kubeadm-join-config.yaml"

#=======================================================================================================================

OLD_HOME=$HOME
export HOME=/root # Fix bug: https://github.com/kubernetes/kubeadm/issues/2361
kubeadm join --config "/home/$KCTL_USER/kubeadm-join-config.yaml" --v=5
# Adding autocomplete
echo 'source /usr/share/bash-completion/bash_completion' >> $HOME/.bashrc
HOME=$OLD_HOME

# TODO: This file does not exist
# FIX CIS: [FAIL] 4.2.6 Ensure that the --protect-kernel-defaults argument is set to true (Automated)
echo 'protectKernelDefaults: true' >>/var/lib/kubelet/config.yaml

# Adding autocomplete - This helps :)
echo 'source <(kubeadm completion bash)' >> /home/$KCTL_USER/.bashrc
echo 'source <(kubectl completion bash)' >> /home/$KCTL_USER/.bashrc
echo "alias k=kubectl" >> /home/$KCTL_USER/.bashrc
echo "alias cc=clear" >> /home/$KCTL_USER/.bashrc
echo "complete -o default -F __start_kubectl k" >> /home/$KCTL_USER/.bashrc
echo 'export KUBE_EDITOR="nano"' >> /home/$KCTL_USER/.bashrc

# shellcheck disable=SC2154
${post_install}

touch /opt/bootstrap_completed
echo "END: $(date)" >>/opt/bootstrap_times
