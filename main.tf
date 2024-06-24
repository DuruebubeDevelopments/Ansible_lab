locals {
  Name = "ansible-demo"
}

# creating VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
  tags = {
    Name = "${local.Name}-vpc"
  }
}
// creating public subnet
resource "aws_subnet" "pub1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr2
  availability_zone = "us-west-2a"
  tags = {
    Name = "${local.Name}"
  }
}
// creating internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${local.Name}-igw"
  }
}

// creating route table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.all-cidr
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${local.Name}-rt"
  }
}
// creating route table association for public subnet
resource "aws_route_table_association" "ass-pub" {
  subnet_id      = aws_subnet.pub1.id
  route_table_id = aws_route_table.rt.id
}
// creating security group
resource "aws_security_group" "sg" {
  name        = "${local.Name}-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${local.Name}-sg"
  }
}
resource "aws_security_group_rule" "rule1" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.all-cidr]
  security_group_id = aws_security_group.sg.id
}
resource "aws_security_group_rule" "rule2" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.all-cidr]
  security_group_id = aws_security_group.sg.id
}
// creating second security group
resource "aws_security_group" "sg2" {
  name        = "${local.Name}-sg2"
  description = "instance_security_group"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${local.Name}-sg2"
  }
}
resource "aws_security_group_rule" "rule3" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.all-cidr]
  security_group_id = aws_security_group.sg2.id
}
resource "aws_security_group_rule" "rule4" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.all-cidr]
  security_group_id = aws_security_group.sg2.id
}
resource "aws_security_group_rule" "rule5" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [var.all-cidr]
  security_group_id = aws_security_group.sg2.id
}
// creating a keypair
resource "aws_key_pair" "key" {
  key_name   = "${local.Name}-key"
  public_key = file(var.path_to_keypair)
}
// creating instance
resource "aws_instance" "ansible" {
  ami                         = "ami-0cf2b4e024cdb6960" //ubuntu
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.key.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = aws_subnet.pub1.id
  associate_public_ip_address = true
  user_data                   = file("./userdata.sh")
  tags = {
    Name = "${local.Name}-ansible"
  }
}

resource "aws_instance" "instance" {
  ami                         = "ami-0b20a6f09484773af" //red-hat
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.key.id
  vpc_security_group_ids      = [aws_security_group.sg2.id]
  subnet_id                   = aws_subnet.pub1.id
  associate_public_ip_address = true
  tags = {
    Name = "${local.Name}-instance"
  }
}

resource "aws_instance" "instance2" {
  ami                         = "ami-0b20a6f09484773af" //red-hat
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.key.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = aws_subnet.pub1.id
  associate_public_ip_address = true
  tags = {
    Name = "${local.Name}-instance2"
  }
}