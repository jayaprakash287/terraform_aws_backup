#elastic ip - nat gateway - using nat gateway for ec2 in a private vpc subnet.
resource "aws_eip" "customvpc-nat" {
#   instance = aws_instance.web.id
  vpc = true
  tags = {
    Name = "custon-ip"
  }
}

resource "aws_nat_gateway" "customvpc-nat-gw" {
  allocation_id = aws_eip.customvpc-nat.id
  subnet_id     = aws_subnet.devops-subnet-public-1.id
  depends_on = [aws_internet_gateway.devops-igw]

  tags = {
    Name = "gw NAT"
  }
}

resource "aws_route_table" "customvpc-private" {
    vpc_id = "${aws_vpc.devops-vpc.id}"
    
    route {
        //associated subnet can reach everywhere
        cidr_block = "0.0.0.0/0" 
        //uses this nat to reach internet
        nat_gateway_id = "${aws_nat_gateway.customvpc-nat-gw.id}" 
    }
    
    tags = {
        Name = "devops-private-routetable"
    }
}
#private route association
resource "aws_route_table_association" "devops-crta-public-subnet-1"{
    subnet_id = "${aws_subnet.devops-subnet-private-1.id}"
    route_table_id = "${aws_route_table.customvpc-private.id}"
}