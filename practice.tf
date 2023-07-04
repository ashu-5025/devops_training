terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.4.0"
    }
  }
  backend "s3" {
    bucket = "terraform-backend-ashu-pr"
    key    = "practice.tf"
    region = "ap-south-1"
  }
}

provider "aws" {
  # Configuration options
}

# creating instance under subnet Mumbai01

resource "aws_instance" "Mumbai_instance" {
  ami                         = "ami-057752b3f1d6c4d6c"
  instance_type               = var.mumbai_instance_type
  subnet_id                   = aws_subnet.Mumbai_01a.id
  key_name                    = aws_key_pair.Mumbai_keypair.key_name
  associate_public_ip_address = "true"
  vpc_security_group_ids      = [aws_security_group.mumbai_sg.id]
  tags = {
    Name = "Ashu"
    #   env = "dev"
  }
}

resource "aws_instance" "Mumbai_instance_2" {
  ami                         = "ami-0183cfdb895e0ff29"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.Mumbai_01a.id
  key_name                    = aws_key_pair.Mumbai_keypair.key_name
  associate_public_ip_address = "true"
  vpc_security_group_ids      = [aws_security_group.mumbai_sg.id]
  tags = {
    Name = "Ashu"
    #   env = "dev"
  }
}
#creating security group

resource "aws_security_group" "mumbai_sg" {
  name        = "Mumbai_SG"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.mumbai_vpc.id
  ingress {

    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }
  ingress {

    description = "SSH from pc"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" //allowing all port traffic
    cidr_blocks = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "mumbai_SG"
  }

}

# creating the key pair
resource "aws_key_pair" "Mumbai_keypair" {
  key_name   = "Mumbai-keypair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC08g8lsNKZq3zZneGxBA4ArI1HzMdHvFMu+WQ0Ck4Wc8brn4JhWwZOjRW0U5SNRPUIlS8bHPc3trav7Jn7rriqorEUkJ7YnCl0TB+8RbYtdZ1BZtpjOKPgvKR/3a9RdgMwHLS22PF4+DswPFaVm8Yez+jWbuAu+S1GJdCEJ8eIfSY9v/izFyv+1c1biDX62Lp4vKklouIuW/iMLruWyT38DAgCdtg6c0HtnCvzCU0XqElLI/I55188tuaGMnXbjcxwFcvWdNIg7g9taCywTUoSocL894nvVSYZJtsmA7mjpsCCK+8QvlKZK3z++0s7JnNhsie+DtJ+AH4waAuRz/YN8jZxBZ3lHtU4/OB2XyiQrQ+fSgrKDUJlrzJaVpcOtJ6nPV/y1sGu6cfTQ0nP+7W5OZEbYVbno/PeaCps360UbpCHf0ptjZufRYukm4of+fkcbo+I+hsSZ3YWzk9HztyS0nC+UVfSnxT1QFzj8RoBAIDKTd47URvS/RRJS9kk0Gc= rajes@LAPTOP-PTQL0PKB"
}
# resource "aws_eip" "lb" {
#   instance = aws_instance.web.id
#   domain   = "vpc"
# }

resource "aws_vpc" "mumbai_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Mumbai_VPC"
  }
}

resource "aws_subnet" "Mumbai_01a" {
  vpc_id            = aws_vpc.mumbai_vpc.id
  availability_zone = "ap-south-1a"
  cidr_block        = "10.0.1.0/24"
  #   map_public_ip_on_launch = "true"
  tags = {
    Name = "Mumbai_01a"
  }
}

resource "aws_subnet" "Mumbai_01b" {
  vpc_id            = aws_vpc.mumbai_vpc.id
  availability_zone = "ap-south-1b"
  cidr_block        = "10.0.2.0/24"
  tags = {
    Name = "Mumbai_01b"
  }
}

resource "aws_subnet" "Mumbai_01c" {
  vpc_id            = aws_vpc.mumbai_vpc.id
  availability_zone = "ap-south-1c"
  cidr_block        = "10.0.3.0/24"
  tags = {
    Name = "Mumbai_01c"
  }
}

#creating IG

resource "aws_internet_gateway" "Mumbai_IG" {
  vpc_id = aws_vpc.mumbai_vpc.id
  tags = {
    Name = "mumbai_IG"
  }
}

#create route table

resource "aws_route_table" "Mumbai_Routetable" {
  vpc_id = aws_vpc.mumbai_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Mumbai_IG.id
  }

  tags = {
    Name = "Mumbai_RT"
  }
}

#route table association

resource "aws_route_table_association" "mumbai_01a_asso" {
  subnet_id      = aws_subnet.Mumbai_01a.id
  route_table_id = aws_route_table.Mumbai_Routetable.id
}

resource "aws_route_table_association" "mumbai_01b_asso" {
  subnet_id      = aws_subnet.Mumbai_01b.id
  route_table_id = aws_route_table.Mumbai_Routetable.id
}

resource "aws_route_table_association" "mumbai_01c_asso" {
  subnet_id      = aws_subnet.Mumbai_01c.id
  route_table_id = aws_route_table.Mumbai_Routetable.id
}

# creating targategroup
resource "aws_lb_target_group" "mumbai-tg" {
  name     = "card-website-terraform"
  port     = 80
  protocol = "HTTP"
  #   target_type = "ip"
  vpc_id = aws_vpc.mumbai_vpc.id
}

resource "aws_lb_target_group_attachment" "mumbai_tg-attach1" {
  target_group_arn = aws_lb_target_group.mumbai-tg.arn
  target_id        = aws_instance.Mumbai_instance.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "mumbai_tg-attach2" {
  target_group_arn = aws_lb_target_group.mumbai-tg.arn
  target_id        = aws_instance.Mumbai_instance_2.id
  port             = 80
}

resource "aws_lb_listener" "mumbai_listner" {
  load_balancer_arn = aws_lb.mumbai_LB.arn
  port              = "80"
  protocol          = "HTTP"
  #   ssl_policy        = "ELBSecurityPolicy-2016-08"
  #   certificate_arn   = "arnawsiam:187416307283server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mumbai-tg.arn
  }
}

resource "aws_lb" "mumbai_LB" {
  name               = "mumbaiLB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mumbai_sg.id]
  subnets            = [aws_subnet.Mumbai_01a.id, aws_subnet.Mumbai_01b.id]

  enable_deletion_protection = true

  #   access_logs {
  #     bucket  = aws_s3_bucket.lb_logs.id
  #     prefix  = "test-lb"
  #     enabled = true
  #   }

  tags = {
    Environment = "production"
  }
}

# aws launch template
resource "aws_launch_template" "mumbai_LT" {
  name = "MumbaiLT"

  #   iam_instance_profile {
  #     name = "test"
  #   }

  image_id = "ami-0183cfdb895e0ff29"

  instance_type = "t2.micro"

  key_name = aws_key_pair.Mumbai_keypair.id

  monitoring {
    enabled = true
  }

  #   network_interfaces {
  #     associate_public_ip_address = true
  #   }

  placement {
    availability_zone = "ap-south-1a"
  }

  vpc_security_group_ids = [aws_security_group.mumbai_sg.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "ASG_Instance"
    }
  }

  user_data = filebase64("userdata.sh")
}

#aws ASG creating

resource "aws_autoscaling_group" "Mumbai_ASG" {
  vpc_zone_identifier = [aws_subnet.Mumbai_01a.id, aws_subnet.Mumbai_01b.id]
  #   availability_zones  = ["ap-south-1a", "ap-south-1b"]
  desired_capacity  = 2
  max_size          = 3
  min_size          = 1
  target_group_arns = [aws_lb_target_group.mumbai-TG-1.arn]
  launch_template {
    id      = aws_launch_template.mumbai_LT.id
    version = "$Latest"
  }
}


resource "aws_lb_target_group" "mumbai-TG-1" {
  name     = "Mumbai-TG-1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.mumbai_vpc.id
}

resource "aws_lb_listener" "Mumbai-listener-1" {
  load_balancer_arn = aws_lb.Mumbai-LB-1.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mumbai-TG-1.arn
  }

}

resource "aws_lb" "Mumbai-LB-1" {
  name               = "Mumbai-LB-1"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mumbai_sg.id]
  subnets            = [aws_subnet.Mumbai_01a.id, aws_subnet.Mumbai_01b.id]
  tags = {
    Environment = "Production"
  }
}