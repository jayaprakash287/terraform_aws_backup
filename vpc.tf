#1) aws vpc
resource "aws_vpc" "devops-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = "true" #gives you an internal domain name
    enable_dns_hostnames = "true" #gives you an internal host name
    enable_classiclink = "false"
    instance_tenancy = "default" 
    tags = {
        Name = "devops-vpc"
    }
}

resource "aws_security_group" "terraform_private_sg" {
  description = "Allow limited inbound external traffic"
  vpc_id      = aws_vpc.devops-vpc.id
  name        = "terraform_ec2_private_sg"

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8080
    to_port     = 8080
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
  }

  egress {
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }

  tags = {
    Name = "ec2-private-sg"
  }
}

#2) subnets in the vpc
resource "aws_subnet" "devops-subnet-public-1" {
    vpc_id = "${aws_vpc.devops-vpc.id}"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true" //it makes this a public subnet
    availability_zone = "eu-west-2a"
    tags = {
        Name = "devops-subnet-public-1"
    }
}


resource "aws_subnet" "devops-subnet-private-1" {
    vpc_id = "${aws_vpc.devops-vpc.id}"
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = "false" //it makes this a public subnet
    availability_zone = "eu-west-2a"
    tags = {
        Name = "devops-subnet-private-1"
    }
}

resource "aws_instance" "demo-inst1" {
  ami                         = "ami-0ad8ecac8af5fc52b"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["${aws_security_group.terraform_private_sg.id}"]
  subnet_id                   = aws_subnet.devops-subnet-public-1.id
  count                       = 1
  associate_public_ip_address = true
  tags = {
    Name        = "demo-instanve-public"
    Environment = "devops"
    Project     = "DEMO-TERRAFORM"
  }
}

resource "aws_instance" "demo-inst2" {
  ami                         = "ami-0ad8ecac8af5fc52b"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["${aws_security_group.terraform_private_sg.id}"]
  subnet_id                   = aws_subnet.devops-subnet-private-1.id
  count                       = 1
  associate_public_ip_address = true
  tags = {
    Name        = "demo-instanve-private"
    Environment = "devops"
    Project     = "DEMO-TERRAFORM"
  }
}


#3)Internet gateway
resource "aws_internet_gateway" "devops-igw" {
    vpc_id = "${aws_vpc.devops-vpc.id}" 
    tags = {
        Name = "devops-igw"
    }
}
#4)route table for vpc
resource "aws_route_table" "devops-public-crt" {
    vpc_id = "${aws_vpc.devops-vpc.id}"
    
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0" 
        //CRT uses this IGW to reach internet
        gateway_id = "${aws_internet_gateway.devops-igw.id}" 
    }
    
    tags = {
        Name = "devops-public-crt"
    }
}
#5)route b/w a routebtable
resource "aws_route_table_association" "nat-subnet"{
    subnet_id = "${aws_subnet.devops-subnet-public-1.id}"
    route_table_id = "${aws_route_table.devops-public-crt.id}"
}
#6)