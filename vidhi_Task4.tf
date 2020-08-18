provider "aws" {
  region  ="ap-south-1"
  profile  ="vidhi"
}
resource "aws_instance" "vidhiins"{
  ami = "ami-000cbce3e1b899ebd"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  key_name = "vidhikey"
  vpc_security_group_ids = [aws_security_group.vidhi_sg1.id]
  subnet_id = aws_subnet.mypublicsubnet1.id

  tags = {
    Name = "wordpress"
  }
}

resource "aws_instance" "vidhiins1"{
  ami = "ami-0019ac6129392a0f2"
  instance_type = "t2.micro"
  key_name = "vidhikey"
  vpc_security_group_ids = [aws_security_group.vidhi_sg2.id]
  subnet_id = aws_subnet.myprivatesubnet2.id

  tags = {
    Name = "mysql"
  }
}

resource "aws_security_group" "vidhi_sg1"{
  name = "vidhi_sg1"
  vpc_id = "${aws_vpc.main.id}" 

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress { 
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "wordpressSG4"
 }
}
resource "aws_security_group" "vidhi_sg2"{
  name = "vidhi_sg2"
  vpc_id = "${aws_vpc.main.id}" 

  ingress {
    description = "MYSQL"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.vidhi_sg1.id]
  }
  
  egress { 
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "mysqlSG4"
  }

}

resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "lwvpc4"
  }
}

resource "aws_route_table" "myvidhirt" {
  vpc_id = "${aws_vpc.main.id}" 

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.myvidhiig.id}"
  }

  tags = {
    Name = "lwrtigw4"
  }   
}

resource "aws_route_table_association" "mya1" {
  subnet_id = aws_subnet.mypublicsubnet1.id
  route_table_id = aws_route_table.myvidhirt.id
}

resource "aws_eip" "myvidhinat" {
  vpc= true
}

resource "aws_nat_gateway" "myvidhinatgw" {
  allocation_id = "${aws_eip.myvidhinat.id}"
  subnet_id = "${aws_subnet.mypublicsubnet1.id}"
  depends_on = [aws_internet_gateway.myvidhiig]

  tags = {
    Name = "lwrtnatgw4"
  }
}

resource "aws_route_table" "myvidhirt1" {
  vpc_id = "${aws_vpc.main.id}" 

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.myvidhinatgw.id}"
  }

  tags = {
    Name = "lwrt41"
  }   
}

resource "aws_route_table_association" "mya2" {
  subnet_id = aws_subnet.myprivatesubnet2.id
  route_table_id = aws_route_table.myvidhirt1.id
}

resource "aws_subnet" "mypublicsubnet1" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "192.168.0.0/24"
  availability_zone = "ap-south-1a"
  
  tags = {
    Name = "lwpublicsubnet" 
  }
}  


resource "aws_subnet" "myprivatesubnet2" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "192.168.1.0/24"
  availability_zone = "ap-south-1b"
  
  tags = {
    Name = "lwprivatesubnet" 
  }
}  

resource "aws_internet_gateway" "myvidhiig" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "lwigw4"
  }
}