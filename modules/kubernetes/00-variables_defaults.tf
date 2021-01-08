variable "ami_name_filter_regex" {
  type        = string
  description = "Regex to find the ami to use"
  default     = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
}

variable "ami_owner" {
  type        = string
  description = "ID of the owner of the ami (example 099720109477 for Canonical)"
  default     = "099720109477"
}

variable "ami_name_regex" {
  type        = string
  description = "The name regex"
  default     = "^.*"
}

variable "ami_id_controller" {
  type        = string
  description = "The id of the AMI to use for the controller. If empty, the latest ubuntu will be user."
  default     = ""
}

variable "ami_id_worker" {
  type        = string
  description = "The id of the AMI to use for the workers. If empty, the latest ubuntu will be user."
  default     = ""
}

variable "availability_zone" {
  type        = list(string)
  description = "The availability zone to use. r4.2xlarge are still not available in C"
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "region" {
  type        = string
  description = "The region to use with the aws cli in the bootstrap (region you are spinning k8s in)"
  default     = "us-east-1"
}

variable "k8s_controllers_instance_root_device_size_seconds" {
  type        = string
  description = "root device size (GB) for the controllers"
  default     = "40"
}

variable "k8s_controllers_instance_root_device_size" {
  type        = string
  description = "root device size (GB) for the nodes"
  default     = "40"
}

variable "k8s_controllers_lb_timeout_seconds" {
  type        = string
  description = "lb timeout in seconds for the controllers"
  default     = "60"
}

variable "k8s_workers_lb_timeout_seconds" {
  type        = string
  description = "lb timeout in second for the nodes"
  default     = "60"
}

variable "k8s_worker_additional_lbs" {
  type        = list(string)
  description = "List of additional ELBs to attach to the AG for nodes (workers)"
  default     = []
}

variable "sns_topic_notifications" {
  type        = string
  description = "The SNS topic to notify when the system autoscale. If empty no notification will be sent"
  default     = ""
}

variable "k8s_deb_package_version" {
  type        = string
  description = "The version of the deb package to install in ubuntu (i.e. 1.18.2)"
  default     = "1.20.1"
}

variable "kubeadm_install_version" {
  type        = string
  description = "The version to install in the syntax expected by kubeadm (i.e. stable-1.18)"
  default     = "stable-1.20"
}

variable "userdata_pre_install" {
  description = "User-data that will be applied before everything else is installed"
  type        = string
  default     = ""
}

# By default will install calico as CNI but you can override it to use what you want
# Example of weave as alternative (remember to escape the "):
# su "$KCTL_USER" -c "kubectl apply -f https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
variable "userdata_cni_install" {
  description = "User-data script that will be applied only in master"
  type        = string
  default     = "su \"$KCTL_USER\" -c \"kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml\""
}

variable "userdata_post_install" {
  description = "User-data that will be applied on every node after everything else"
  type        = string
  default     = ""
}

variable "enable_ssm_access_to_nodes" {
  description = "If set to true the nodes will register to AWS SSM"
  type        = bool
  default     = true
}

variable "ec2_key_name" {
  type        = string
  description = "The key name to associate to the new ec2 servers. Not needed if you use SSM or want no access"
  default     = ""
}

variable "enable_admission_plugins" {
  type        = string
  description = "The comma separated list of admission plugin to enable"
  default     = "NodeRestriction" # Def for 1.19
}