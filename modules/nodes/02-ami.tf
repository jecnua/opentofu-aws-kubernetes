data "aws_ami" "ami_dynamic" {
  most_recent = true
  owners      = [var.ami_owner] # Canonical
  name_regex  = var.ami_name_regex
  filter {
    name   = "name"
    values = [var.ami_name_filter_regex]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
