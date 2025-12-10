#Amazon2023 Server Last AMI 
data "aws_ami" "latest_amazon_linux_2023" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}
#находим aws_iam_instance_profile для прикрепления прав ес2
data "aws_iam_instance_profile" "jenkins_role_profile" {
  name = "my-jenkins-project-ec2-s3-dyndb-full"
}

#VPC
resource "aws_vpc" "j_vpc" {
  cidr_block = var.j_vpc_cidr  
  
  tags = {
    Name = "${var.project_name}-j-VPC"
    Environment = "${var.environment}"
  }
}

#VPC Subnet
resource "aws_subnet" "j_pub_subnet" {
  vpc_id     = aws_vpc.j_vpc.id
  cidr_block = var.public_subnet_cidr  
  
  map_public_ip_on_launch = true  # Даёт публичный IP

  tags = {
    Name = "${var.project_name}-j-public-subnet"
    Environment = "${var.environment}"
  }
}

#VPC Internet Gsteway
resource "aws_internet_gateway" "j_gw" {
  vpc_id = aws_vpc.j_vpc.id

  tags = {
    Name = "${var.project_name}-IGW"
    Environment = "${var.environment}"
  }  
}

#VPC Route Table
resource "aws_route_table" "j_rt" {
  vpc_id = aws_vpc.j_vpc.id

  route {
    cidr_block = "0.0.0.0/0"         # Весь интернет
    gateway_id = aws_internet_gateway.j_gw.id  # → через IGW
  }

    tags = {
      Name = "${var.project_name}-j-RT"
      Environment = "${var.environment}"
  }
}

#VPC Route Table Associations
resource "aws_route_table_association" "j_rta" {
  subnet_id      = aws_subnet.j_pub_subnet.id
  route_table_id = aws_route_table.j_rt.id
}

#Security group without rules
resource "aws_security_group" "j_sg" {
  name        = "${var.project_name}-j-SG"
  description = "Security group for Jenkins server"
  vpc_id      = aws_vpc.j_vpc.id

  # Egress (исходящий трафик) - разрешаем всё
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-j-sg"
    Environment = "${var.environment}"
  }
}

locals {
    my_ip  = "0.0.0.0/0"
  # Порты для SSH и Jenkins (доступ только с my IP)
  my_ip_to_j = {
    ssh = {
      port        = 22
      description = "SSH access"
    }
    http = {
      port        = 8080
      description = "access to Flask app"
    }
  }
}

#Security group rules
# My IP → Jenkins Server (SSH, 8080)
resource "aws_security_group_rule" "my_ip_to_j" {
  for_each = local.my_ip_to_j

  type              = "ingress"
  from_port         = each.value.port
  to_port           = each.value.port
  protocol          = "tcp"
  description       = each.value.description
  security_group_id = aws_security_group.j_sg.id
  cidr_blocks       = [local.my_ip]
}

# Jenkins Instance
resource "aws_instance" "jenkins_server" {
  ami                    = data.aws_ami.latest_amazon_linux_2023.id
  instance_type          = var.j_instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.j_sg.id]
  subnet_id              = aws_subnet.j_pub_subnet.id
  iam_instance_profile   = data.aws_iam_instance_profile.jenkins_role_profile.name

# Увеличиваем размер диска, т.к. будут Docker образы
  root_block_device {
    volume_size = var.j_volume_size  # GB (дефолт 8GB может быть мало)
    volume_type = var.j_volume_type  # Современный тип диска
  }

  tags = {
    Name = "${var.project_name}-instance-server"
    Environment = "${var.environment}"
    Role = "jenkins"
    Ansible     = "managed_by_host"
  }

    # После создания запишем публичный IP в файл inventory для Ansible
  provisioner "local-exec" {
    command = "echo '[aws]' > ../ansible/inventory.ini && echo '${self.public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/${var.key_name}.pem' >> ../ansible/inventory.ini"
  }
}
