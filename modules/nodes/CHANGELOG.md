# CHANGELOG

## 9.0.0

### Features & Changes

- Moved to opentofu. The last version tested on terraform (1.5.5) is v8.0.0.

### Bugfixes

### Known bugs/issues

## 8.0.0

DO NOT USE 7.0.0. Use this version instead.

### Breaking changes

- New variable private_subnets_cidr is required. This list contains all the CIDR controllers and nodes MAY be spinned into to allow access to ports. Temporary until I find a better way which works with datasources outputs.

### Features & Changes

- Creating a new configmap in kube-system to allow the configuration of metric-server https://github.com/kubernetes-sigs/metrics-server/blob/master/KNOWN_ISSUES.md#incorrectly-configured-front-proxy-certificate
- Port 10250 is now open on all nodes to the internal subnets CIDR to allow metric server to work

### Bugfixes

### Known bugs/issues

## 7.0.0 (DO NOT USE THIS VERSION)

I left in a temporary workaround to make the node register but it give too much power to anonymous.
Use the next version in which the correct fix is implemented.

### Breaking changes

- The nodes no longer take the token as a parameter (since it expires) and instead will retrieve it from a secret
- Updated terraform version to <= 1.5.5 (last version I will support. Next one will be opentofu)

### Features & Changes

- Updated default ami

### Bugfixes

### Known bugs/issues

## 6.0.0

### Breaking changes

- Updated minimum terraform version to 1.2
- Updated kubeadm config to kubeadm.k8s.io/v1beta3
- Updated terraform version used to 1.2.x

### Features & Changes

- Explicitly setting the cgroupDriver to systemd

### Bugfixes

- Fixed falco installation

### Known bugs/issues

## 5.0.0

### Features & Changes

- Moved node management to this module
- Created 2 modules to allow installation of docker or containerd/gvisor
- Moved from aws_launch_configuration to aws_launch_template
- Default on spot as node type
- EBS default is now GP3
- Added falco to base installation
- Removed LBs from nodes asg (not used)

### Bugfixes

### Known bugs/issues
