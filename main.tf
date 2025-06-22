provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Create a VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main_vpc"
  }
}

# Public Subnet 1 (us-east-1a)
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "public_subnet"
  }
}

# Public Subnet 2 (us-east-1b)
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"

  tags = {
    Name = "public_subnet_2"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main_igw"
  }
}

# Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rt"
  }
}

# Associate Route Table to Subnets
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# Security Group
resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow SSH, HTTP"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# Key Pair
resource "aws_key_pair" "deployer" {
  key_name   = "mykey"
  public_key = file("C:/Users/vikash/$HOME/.ssh/id_rsa.pub")
}

# EC2 Instances
resource "aws_instance" "web1" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  key_name               = aws_key_pair.deployer.key_name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<html><head><title>Resume</title></head><body><h1>Ankit Maurya - Cloud DevOps Engineer</h1><p>Experienced in AWS, Terraform, CI/CD, Jenkins, Docker, and monitoring tools.</p><p>Email: ankit@example.com</p></body></html>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "WebServer1"
  }
}

resource "aws_instance" "web2" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_2.id
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  key_name               = aws_key_pair.deployer.key_name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<html><head><title>Resume</title></head><body><h1>Ankit Maurya - Cloud DevOps Engineer</h1><p>Experienced in AWS, Terraform, CI/CD, Jenkins, Docker, and monitoring tools.</p><p>Email: ankit@example.com</p></body></html>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "WebServer2"
  }
}

# Load Balancer
resource "aws_lb" "web_lb" {
  name               = "web-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_2.id]
  security_groups    = [aws_security_group.allow_web.id]

  tags = {
    Name = "web-lb"
  }
}

# Target Group
resource "aws_lb_target_group" "web_tg" {
  name     = "web-targets"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id
}

# Listener
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# Attach EC2s to Target Group
resource "aws_lb_target_group_attachment" "web1" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web2" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web2.id
  port             = 80
}

# RDS Instance
resource "aws_db_instance" "mydb" {
  identifier             = "mydb-instance"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = var.db_user
  password               = var.db_password
  db_name                = "mydb"
  publicly_accessible    = true
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
}

# RDS Subnet Group
resource "aws_db_subnet_group" "default" {
  name       = "main-db-subnet-group"
  subnet_ids = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name = "main-db-subnet-group"
  }
}
