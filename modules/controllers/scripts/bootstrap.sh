#!/bin/bash

### Dynamic vars (from terraform)

DATA_DIR_NAME=data
# shellcheck disable=SC2154
K8S_DEB_PACKAGES_VERSION=${k8s_deb_package_version}
# shellcheck disable=SC2154
#KUBEADM_VERSION_OF_K8S_TO_INSTALL=${kubeadm_install_version}
KCTL_USER='ubuntu'

STERN_VERSION='1.11.0' # TODO: Parametric
LB_DNS_NAME=${load_balancer_dns}

### Statics

echo "START: $(date)" >>/opt/bootstrap_times

AWS_HOSTNAME=$(curl http://169.254.169.254/latest/meta-data/local-hostname)
hostname "$AWS_HOSTNAME"
echo "$AWS_HOSTNAME" >/etc/hostname
echo "127.0.0.1 $AWS_HOSTNAME" >>/etc/hosts

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
	etcd-client \
	apparmor-utils
# This need to be synchronized
apt install -y \
	kubelet="$K8S_DEB_PACKAGES_VERSION-00" \
	kubeadm="$K8S_DEB_PACKAGES_VERSION-00" \
	kubectl="$K8S_DEB_PACKAGES_VERSION-00"

# Requires js
AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)

# Install stern
wget "https://github.com/wercker/stern/releases/download/$STERN_VERSION/stern_linux_amd64"
chmod +x stern_linux_amd64
mv stern_linux_amd64 /usr/local/bin/stern

# Hold these packages back so that we don't accidentally upgrade them.
# TODO: Remove version (locking to avoid bug in kubeadm)
apt-mark hold kubelet kubeadm kubectl kubernetes-cni

# Set new memory limit container with high memory requirements
sysctl -w vm.max_map_count=262144

cat <<'TEOF' >"/opt/install-cri.sh"
${cri_installation}
TEOF
chmod +x /opt/install-cri.sh
/opt/install-cri.sh

# Adding autocomplete
echo 'source /usr/share/bash-completion/bash_completion' >>~/.bashrc
echo 'source <(kubectl completion bash)' >/etc/bash_completion.d/kubectl
echo 'source <(kubeadm completion bash)' >/etc/bash_completion.d/kubeadm

#=======================================================================================================================
# START Master logic

# Start as master (no HA)
TAG_NAME="ControllerID"
INSTANCE_ID=$(wget -qO- http://instance-data/latest/meta-data/instance-id)
TAG_VALUE=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=$TAG_NAME" --region "$AWS_REGION" --output=text | cut -f5)

if [[ $TAG_VALUE == "0" ]]; then

	echo "First controller. The others will join me!"
	# Forcing version
	# VERSION=$KUBEADM_VERSION_OF_K8S_TO_INSTALL
	cat <<EOF >"/home/$KCTL_USER/kubeadm-config.yaml"
${kubeadm_config}
EOF

	# Create the ETCD encryption file
	mkdir -p /etc/kubernetes/etcd-encryption/
	cat <<EOF >"/etc/kubernetes/etcd-encryption/etcd-enc.yaml"
${kubeadm_etcd_encryption}
EOF

	# Create audit policy file
	mkdir -p /var/log/kube-audit/
	mkdir -p /etc/kubernetes/kube-audit/
	cat <<EOF >"/etc/kubernetes/kube-audit/audit-policy.yaml"
${audit_policy}
EOF

	# When doing multimaster this secrets needs to be the same, plus if you want the ETCD
	# snapshot to make sense, you need to keep this between cluster
	# It is shared like the rest of the data via Secret Manager
	ETCD_SECRET=$(head -c 32 /dev/urandom | base64)
	sed -i "s|PLACEHOLDER|$ETCD_SECRET|g" /etc/kubernetes/etcd-encryption/etcd-enc.yaml
	chmod 600 /etc/kubernetes/etcd-encryption/etcd-enc.yaml

	OLD_HOME=$HOME
	export HOME=/root # Fix bug: https://github.com/kubernetes/kubeadm/issues/2361

	# Generate certificate key
	CERTIFICATEKEY=$(kubeadm certs certificate-key)
	sed -i "s|CERTIFICATEKEY|$CERTIFICATEKEY|g" "/home/$KCTL_USER/kubeadm-config.yaml"

	# HA Version
	# TODO: Make it optional?
	kubeadm init --config "/home/$KCTL_USER/kubeadm-config.yaml" --v=5 --upload-certs

	# TODO: Cron every 6 hours to generate a new one and upload it to the secret
	# Upload a fresh token and CA hash
	TOKEN=$(kubeadm token create)
	HASH=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')
	SECRET_NAME=${secret_name}
	aws secretsmanager update-secret \
		--secret-id "$SECRET_NAME" \
		--region "$AWS_REGION" \
		--secret-string '{"token":"'"$TOKEN"'","hash":"'"$HASH"'","certificatekey":"'"$CERTIFICATEKEY"'","etcdsecret":"'"$ETCD_SECRET"'"}'

	HOME=$OLD_HOME

	cd /home/$KCTL_USER || exit
	mkdir -p /home/$KCTL_USER/.kube
	sudo cp -i /etc/kubernetes/admin.conf /home/$KCTL_USER/.kube/config
	sudo chown "$KCTL_USER":"$KCTL_USER" -R /home/$KCTL_USER/.kube
	echo "export KUBECONFIG=/home/$KCTL_USER/.kube/config" | tee -a /home/$KCTL_USER/.bashrc

	# So now this is tricky! Sometimes when starting up, when you try to apply what follows it will fails because
	# the call through the load balancer does not go through. To fix this, I cam creating a copy of the kubeconfig file
	# which doesn't use the LB and I will use this to configure the CNI and signer
	cp /home/$KCTL_USER/.kube/config /home/$KCTL_USER/.kube/local
	sed -i "s|$LB_DNS_NAME|127.0.0.1|g" /home/$KCTL_USER/.kube/local
	sudo chown $KCTL_USER:$KCTL_USER /home/$KCTL_USER/.kube/local

	# Mabel the master
	su "$KCTL_USER" -c "KUBECONFIG=/home/$KCTL_USER/.kube/local kubectl label --overwrite no $AWS_HOSTNAME node-role.kubernetes.io/master=true"

	# The following fixed the issue with nodes not being able to join the cluster
	# https://github.com/kubernetes-sigs/kubespray/issues/4117#issuecomment-1319776085
	cat <<EOF >"/home/$KCTL_USER/auth.yaml"
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: kubeadm:bootstrap-signer-clusterinfo
  namespace: kube-public
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: kubeadm:bootstrap-signer-clusterinfo
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: system:anonymous
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: kubeadm:bootstrap-signer-clusterinfo
  namespace: kube-public
rules:
- apiGroups:
  - ""
  resourceNames:
  - cluster-info
  resources:
  - configmaps
  verbs:
  - get
EOF
	su "$KCTL_USER" -c "KUBECONFIG=/home/$KCTL_USER/.kube/local kubectl apply -f /home/$KCTL_USER/auth.yaml"

	# Install CNI plugin
	su "$KCTL_USER" -c "KUBECONFIG=/home/$KCTL_USER/.kube/local kubectl apply -f ${cni_file_location}"

else

	echo "I am NOT the first controller. I will join the first".

	# Create audit policy file
	mkdir -p /var/log/kube-audit/
	mkdir -p /etc/kubernetes/kube-audit/
	cat <<EOF >"/etc/kubernetes/kube-audit/audit-policy.yaml"
${audit_policy}
EOF

	cat <<EOF >"/home/$KCTL_USER/kubeadm-join-config.yaml"
${kubeadm_join_config}
EOF

	# Create the ETCD encryption file
	mkdir -p /etc/kubernetes/etcd-encryption/
	cat <<EOF >"/etc/kubernetes/etcd-encryption/etcd-enc.yaml"
${kubeadm_etcd_encryption}
EOF

	AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region)
	MYIP=$(curl --silent http://169.254.169.254/latest/meta-data/local-ipv4)
	MASTER_IP=$LB_DNS_NAME # TODO: Maybe change this to avoid the issue of the master calling itself or a master not ready?

	SECRET_ARN=${secret_name}
	while true; do
		# Get all the secrets which are dynamic on cluster generation
		TOKEN=$(aws secretsmanager get-secret-value --secret-id "$SECRET_ARN" --region "$AWS_REGION" | jq --raw-output '.SecretString' | jq --raw-output '.token')
		HASH=$(aws secretsmanager get-secret-value --secret-id "$SECRET_ARN" --region "$AWS_REGION" | jq --raw-output '.SecretString' | jq --raw-output '.hash')
		CERTIFICATEKEY=$(aws secretsmanager get-secret-value --secret-id "$SECRET_ARN" --region "$AWS_REGION" | jq --raw-output '.SecretString' | jq --raw-output '.certificatekey')
		ETCD_SECRET=$(aws secretsmanager get-secret-value --secret-id "$SECRET_ARN" --region "$AWS_REGION" | jq --raw-output '.SecretString' | jq --raw-output '.etcdsecret')
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
	sed -i "s/CERTIFICATEKEY/$CERTIFICATEKEY/g" "/home/$KCTL_USER/kubeadm-join-config.yaml"
	sed -i "s/MASTERIP/$MASTER_IP/g" "/home/$KCTL_USER/kubeadm-join-config.yaml" # TODO: I may know beforehand
	sed -i "s/MYADDRESS/$MYIP/g" "/home/$KCTL_USER/kubeadm-join-config.yaml"     # TODO: I may know beforehand
	#
	sed -i "s|PLACEHOLDER|$ETCD_SECRET|g" /etc/kubernetes/etcd-encryption/etcd-enc.yaml
	chmod 600 /etc/kubernetes/etcd-encryption/etcd-enc.yaml


	OLD_HOME=$HOME
	export HOME=/root # Fix bug: https://github.com/kubernetes/kubeadm/issues/2361
	kubeadm join --config "/home/$KCTL_USER/kubeadm-join-config.yaml" --v=5
	HOME=$OLD_HOME

fi
# END Master logic
#=======================================================================================================================

${post_install}

touch /opt/bootstrap_completed
echo "END: $(date)" >>/opt/bootstrap_times
