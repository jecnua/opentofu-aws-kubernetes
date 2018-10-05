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

variable "nat_gateway" {
  type        = "string"
  description = "temp"
  default     = ""
}

variable "availability_zone" {
  type        = "list"
  description = "The availability zone to use. r4.2xlarge are still not available in C"
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "region" {
  type        = "string"
  description = "The region to use with the aws cli in the bootstrap (region you are spinning k8s in)"
  default     = "us-east-1"
}

variable "k8s_controllers_instance_root_device_size_seconds" {
  type        = "string"
  description = "root device size (GB) for the controllers"
  default     = "40"
}

variable "k8s_controllers_instance_root_device_size" {
  type        = "string"
  description = "root device size (GB) for the nodes"
  default     = "40"
}

variable "k8s_controllers_lb_timeout_seconds" {
  type        = "string"
  description = "lb timeout in seconds for the controllers"
  default     = "60"
}

variable "k8s_workers_lb_timeout_seconds" {
  type        = "string"
  description = "lb timeout in second for the nodes"
  default     = "60"
}

variable "k8s_worker_additional_lbs" {
  type        = "list"
  description = "List of additional ELBs to attach to the AG for nodes (workers)"
  default     = []
}

variable "sns_topic_notifications" {
  type        = "string"
  description = "The SNS topic to notify when the system autoscale. If empty no notification will be sent"
  default     = ""
}
