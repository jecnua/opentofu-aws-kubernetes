data "aws_vpc" "targeted_vpc" {
  id      = "${var.vpc_id}"
  default = false
  state   = "available"
}

## TODO: count.index+1 is to avoid zone a in us-east (see readme)
resource "aws_subnet" "k8s_private" {
  count                   = 2
  vpc_id                  = "${data.aws_vpc.targeted_vpc.id}"
  availability_zone       = "${var.availability_zone[count.index]}"
  cidr_block              = "${var.subnets_cidr_block[count.index]}"
  map_public_ip_on_launch = "false"

  tags {
    Name                              = "${var.unique_identifier} ${var.environment} k8s private subnet"
    managed                           = "terraform (k8s module)"
    KubernetesCluster                 = "${var.kubernetes_cluster}"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "k8s_public" {
  count                   = 2
  vpc_id                  = "${data.aws_vpc.targeted_vpc.id}"
  availability_zone       = "${var.availability_zone[count.index]}"
  map_public_ip_on_launch = "true"
  cidr_block              = "${var.subnets_public_cidr_block[count.index]}"

  tags {
    Name                     = "${var.unique_identifier} ${var.environment} k8s public subnet"
    managed                  = "terraform (k8s module)"
    KubernetesCluster        = "${var.kubernetes_cluster}"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_route_table" "k8s_private_route_table" {
  vpc_id = "${data.aws_vpc.targeted_vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${var.nat_gateway}" #NAT Gateway
  }

  tags {
    Name              = "${var.unique_identifier} ${var.environment} k8s private route table"
    managed           = "terraform"
    KubernetesCluster = "${var.kubernetes_cluster}"
  }
}

resource "aws_route_table" "k8s_public_route_table" {
  vpc_id = "${data.aws_vpc.targeted_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${var.internet_gateway}" # Internet Gateway
  }

  tags {
    Name              = "${var.unique_identifier} ${var.environment} k8s public route table"
    managed           = "terraform"
    KubernetesCluster = "${var.kubernetes_cluster}"
  }
}

resource "aws_route_table_association" "k8s_private_route_table_assoc" {
  count          = 2
  subnet_id      = "${element(aws_subnet.k8s_private.*.id, count.index)}"
  route_table_id = "${aws_route_table.k8s_private_route_table.id}"
}

resource "aws_route_table_association" "k8s_public_route_table_assoc" {
  count          = 2
  subnet_id      = "${element(aws_subnet.k8s_public.*.id, count.index)}"
  route_table_id = "${aws_route_table.k8s_public_route_table.id}"
}
