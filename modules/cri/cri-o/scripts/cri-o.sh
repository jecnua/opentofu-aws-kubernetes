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

# Install via apt
# https://github.com/cri-o/packaging
apt-get update
apt-get install -y software-properties-common curl
KUBERNETES_VERSION=v${kubernetes_version}
PROJECT_PATH=prerelease:/main
curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/$PROJECT_PATH/deb/Release.key |
    gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://pkgs.k8s.io/addons:/cri-o:/$PROJECT_PATH/deb/ /" |
    tee /etc/apt/sources.list.d/cri-o.list
apt-get update
apt-get install -y cri-o
systemctl enable crio.service
systemctl start crio.service
systemctl status crio.service
crictl info
crio status info

# TODO: Move it to node configuration?
# Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead.
# KUBELET_EXTRA_ARGS should be sourced from this file.
echo 'KUBELET_EXTRA_ARGS= --cgroup-driver=systemd --runtime-request-timeout=5m' > /etc/default/kubelet
systemctl daemon-reload
systemctl restart kubelet

############# CRI-O #############
