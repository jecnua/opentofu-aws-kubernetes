############# CONTAINERD #############

#CRICTL_VERSION="v1.20.0"

# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd
cat <<EOF | tee /etc/modules-load.d/containerd.conf
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

##

# Installing containerd from Ubuntu repos and not the docker one
apt-get update
apt install -y containerd # It will also install runc

# Configure it
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml # https://github.com/containerd/containerd/issues/4581#issuecomment-733704174

# Now we need to add the shim to use also gvisor
# https://gvisor.dev/docs/user_guide/install/
(
  set -e
  ARCH=$(uname -m)
  URL=https://storage.googleapis.com/gvisor/releases/release/latest/$ARCH
  wget "$URL/runsc" "$URL/runsc.sha512" \
    "$URL/containerd-shim-runsc-v1" "$URL/containerd-shim-runsc-v1.sha512"
  sha512sum -c runsc.sha512 \
    -c containerd-shim-runsc-v1.sha512
  rm -f *.sha512
  chmod a+rx runsc containerd-shim-runsc-v1
  mv runsc containerd-shim-runsc-v1 /usr/local/bin
)

# Configure the toml
# https://gvisor.dev/docs/user_guide/containerd/quick_start/
#cat <<CRIEOF | tee /etc/containerd/config.toml
#disabled_plugins = ["restart"]
#[plugins.linux]
#  shim_debug = true
#[plugins.cri.containerd.runtimes.runsc]
#  runtime_type = "io.containerd.runsc.v1"
#CRIEOF

#######################################################

# Install crictl
# https://gvisor.dev/docs/user_guide/containerd/quick_start/
#wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$CRICTL_VERSION/crictl-$CRICTL_VERSION-linux-amd64.tar.gz
#tar zxvf crictl-$CRICTL_VERSION-linux-amd64.tar.gz -C /usr/local/bin
#rm -f crictl-$CRICTL_VERSION-linux-amd64.tar.gz

# crictl use containerd as default
cat <<CRIEOF | tee /etc/crictl.yaml
runtime-endpoint: unix:///var/run/containerd/containerd.sock
image-endpoint: unix:///var/run/containerd/containerd.sock
timeout: 10
debug: false
CRIEOF

#######################################################

systemctl daemon-reload
systemctl restart containerd
systemctl restart kubelet

############# CONTAINERD #############