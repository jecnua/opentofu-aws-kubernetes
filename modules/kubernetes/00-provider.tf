provider "aws" {
  region     = "${var.network_region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}
