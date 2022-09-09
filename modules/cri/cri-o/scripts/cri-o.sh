############# CRI-O #############

cat <<EOF | tee /etc/modules-load.d/cri-o.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sysctl --system

## Compile crio-o

DEBIAN_FRONTEND=noninteractive apt-get install -y \
  libvirt-clients \
  golang \
  libdevmapper-dev \
  lvm2 \
  make
#git clone https://github.com/cri-o/cri-o.git
#cd cri-o || exit 1
#git checkout v1.21.0
#sed -i 's/- exclude_graphdriver_devicemapper/# - exclude_graphdriver_devicemapper/g' .golangci.yml
#make install

## Install via apt

. /etc/lsb-release
OS='x'$DISTRIB_ID'_'$DISTRIB_RELEASE
VERSION=${crio_version}

echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" > "/etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list"

curl -L "https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/Release.key" | apt-key add -
curl -L "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key" | apt-key add -

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y cri-o cri-o-runc cri-tools

##

sed -i 's|conmon = ""|conmon = "/usr/bin/conmon"|g' /etc/crio/crio.conf

systemctl status crio

systemctl enable crio.service
systemctl start crio.service
systemctl status crio.service

crictl info

# TODO: Move it to node configuration?
# Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead.
# KUBELET_EXTRA_ARGS should be sourced from this file.
echo 'KUBELET_EXTRA_ARGS= --cgroup-driver=systemd --runtime-request-timeout=5m' > /etc/default/kubelet
systemctl daemon-reload
systemctl restart kubelet

############# CRI-O #############
