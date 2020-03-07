provider "aws"{
    region = var.default_region
    access_key = var.access_key_id
    secret_key = var.secret_key_id
}

resource "aws_vpc" "production" {
  cidr_block= var.ip_address
}

resource "aws_subnet" "subnet" {
    vpc_id = aws_vpc.production.id
    cidr_block = var.subnet
    map_public_ip_on_launch = "true"
    availability_zone = "us-east-1a"
}

resource "aws_default_route_table" "route_table" {
    default_route_table_id = aws_vpc.production.default_route_table_id 

    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }
}


resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.production.id
}


resource "aws_security_group" "ssh_group" {
    name = var.sg_name
    vpc_id = aws_vpc.production.id
    dynamic "ingress"{
        for_each = var.ingress_rules
        content {
            from_port = ingress.value.from_port
            to_port = ingress.value.to_port
            protocol = ingress.value.protocol
            cidr_blocks = ingress.value.cidr_blocks
            }
    }
    dynamic "egress"{
        for_each = var.egress_rules
        content {
            from_port = egress.value.from_port
            to_port = egress.value.to_port
            protocol = egress.value.protocol
            cidr_blocks = egress.value.cidr_blocks
            }
    }
}

resource "aws_instance" "platzi_instance" {
    ami = var.ami_id
    count = var.instance_to_deploy
    instance_type = var.instance_type
    tags = var.tags
    subnet_id = aws_subnet.subnet.id
    security_groups = ["${aws_security_group.ssh_group.id}"]
    key_name = var.key_name
}