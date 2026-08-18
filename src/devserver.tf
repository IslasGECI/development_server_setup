resource "aws_vpc" "devserver" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "devserver-vpc"
  }
}

resource "aws_internet_gateway" "devserver" {
  vpc_id = aws_vpc.devserver.id
  tags = {
    Name = "devserver-igw"
  }
}

resource "aws_subnet" "devserver" {
  vpc_id            = aws_vpc.devserver.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "devserver-subnet"
  }
}

resource "aws_security_group" "devserver" {
  name        = "devserver-sg"
  description = "Security group for devserver"
  vpc_id      = aws_vpc.devserver.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_network_interface" "devserver" {
  subnet_id       = aws_subnet.devserver.id
  security_groups = [aws_security_group.devserver.id]

  tags = {
    Name = "devserver-nic"
  }
}

resource "aws_eip" "devserver" {
  domain            = "vpc"
  network_interface = aws_network_interface.devserver.id
  depends_on        = [aws_vpc.devserver]

  tags = {
    Name = "devserver-public-ip"
  }
}

resource "aws_route_table" "devserver" {
  vpc_id = aws_vpc.devserver.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devserver.id
  }
  tags = {
    Name = "devserver-rt"
  }
}

resource "aws_route_table_association" "devserver" {
  subnet_id      = aws_subnet.devserver.id
  route_table_id = aws_route_table.devserver.id
}

resource "aws_key_pair" "devserver" {
  public_key = file("~/.ssh/id_rsa.pub")
  tags = {
    Name = "devserver-key"
  }
}

resource "aws_instance" "devserver" {
  ami           = "ami-02ebdb11bae1b2486"
  instance_type = "t3.xlarge"
  key_name      = aws_key_pair.devserver.id

  network_interface {
    network_interface_id = aws_network_interface.devserver.id
    device_index         = 0
  }

  tags = {
    Name = "devserver"
  }

  root_block_device {
    volume_size = 128
    volume_type = "gp3"
  }
}

output "devserver_ip_aws" {
  value = aws_eip.devserver.public_ip
}
