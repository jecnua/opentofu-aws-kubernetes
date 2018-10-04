variable "ami_name_filter_regex" {
  type        = "string"
  description = "Regex to find the ami to use"
  default     = "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"
}

variable "ami_owner" {
  type        = "string"
  description = "ID of the owner of the ami (example 099720109477 for Canonical)"
  default     = "099720109477"
}

variable "ami_name_regex" {
  type        = "string"
  description = "The name regex"
  default     = "^.*"
}

variable "ami_id_controller" {
  type        = "string"
  description = "The id of the AMI to use for the controller. If empty, the latest ubuntu will be user."
  default     = ""
}

variable "ami_id_worker" {
  type        = "string"
  description = "The id of the AMI to use for the workers. If empty, the latest ubuntu will be user."
  default     = ""
}

variable "availability_zone" {
  type        = "list"
  description = "r4.2xlarge are still not available in C"
  default     = ["us-east-1b", "us-east-1d"]
}

variable "region" {
  default = "us-east-1"
}

variable "controller_region" {
  default = "us-east-1"
}

variable "node_region" {
  default = "us-east-1"
}

variable "ec2_k8s_controllers_instance_root_device_size" {
  type    = "string"
  default = "40"
}

variable "ec2_k8s_workers_instance_root_device_size" {
  type    = "string"
  default = "40"
}

variable "k8s_controllers_elb_timeout" {
  type    = "string"
  default = "60"
}

variable "k8s_workers_elb_timeout" {
  type    = "string"
  default = "60"
}

##
variable "k8s_worker_additional_elbs" {
  type        = "list"
  description = "List of additional ELBs to attach to the AG for nodes (workers)"
  default     = []
}

variable "sns_topic_notifications" {
  type        = "string"
  description = "The SNS topic to use when the system autoscale. If empty no notification will be sent"
  default     = ""
}
