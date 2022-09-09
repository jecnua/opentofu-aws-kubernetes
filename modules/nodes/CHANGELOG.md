# CHANGELOG

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
