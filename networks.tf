resource "aws_vpc" "cts_network" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name        = "Private_Network_cts-${var.infra_env}-vpc"
    Project     = var.project_name
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}

resource "aws_subnet" "cts_network_public_subnet" {
  vpc_id                  = aws_vpc.cts_network.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "subnet 1 - 10.0.1.0/24"
  }
}

resource "aws_internet_gateway" "cts_network_default_gateway" {
  vpc_id = aws_vpc.cts_network.id
  tags = {
    "Name" = "cts_network_default_gateway"
  }
}


# Routing tables to route traffic for Public Subnet
resource "aws_route_table" "cts_network_routing_public" {
  vpc_id = aws_vpc.cts_network.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cts_network_default_gateway.id
  }

  tags = {
    Name = "routable for cts acces form public"
  }
}

resource "aws_route_table_association" "cts_network_routing_associate" {
  subnet_id      = aws_subnet.cts_network_public_subnet.id
  route_table_id = aws_route_table.cts_network_routing_public.id
}


## Security Groups
resource "aws_security_group" "cts_network_firewall" {
  name        = "cm_server_sg"
  description = "Allow inbound and outbound traffic for EC2 instances"
  vpc_id      = aws_vpc.cts_network.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "SSH to server"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

   ingress {
    description = "NAE_KMIP to server"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "NAE_KMIP CUSTOM to server"
    from_port   = 9005
    to_port     = 9005
    protocol    = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "cts-manager-ACL"
  }
}