provider "aws" {
  region = "ap-south-1"   # choose your region
}

# Key pair
resource "aws_key_pair" "jenkins_key" {
  key_name   = "jenkins-key"
  public_key = file("${pathexpand("~/.ssh/id_rsa.pub")}")
}

# Security group
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-sg"
  description = "Allow SSH and Jenkins"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
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

# Jenkins EC2 instance
resource "aws_instance" "jenkins" {
  ami           = "ami-07f07a6e1060cd2a8" # Ubuntu 22.04 LTS (update for your region)
  instance_type = var.jenkins_instance_type
  key_name      = aws_key_pair.jenkins_key.key_name
  security_groups = [aws_security_group.jenkins_sg.name]
  user_data     = file("${path.module}/jenkins_user_data.sh")

  tags = {
    Name = "Jenkins-Server"
  }
}
# ==============================
# APP SERVER - Tomcat
# ==============================
resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Allow SSH and HTTP for App server"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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

# ==============================
# APP SERVER EC2 INSTANCE
# ==============================
resource "aws_instance" "app" {
  ami           = "ami-07f07a6e1060cd2a8" # ✅ Ubuntu 22.04 LTS (ap-south-1)
  instance_type = var.app_instance_type
  key_name      = aws_key_pair.jenkins_key.key_name
  security_groups = [aws_security_group.app_sg.name]

  provisioner "local-exec" {
  command = <<EOT
  echo "[app]" > ansible/hosts.ini
  echo "${self.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa" >> ansible/hosts.ini
  EOT
}
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install -y openjdk-17-jdk wget unzip
    # Install Tomcat
    cd /opt
    sudo wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.22/bin/apache-tomcat-10.1.22.zip
    sudo unzip apache-tomcat-10.1.22.zip
    sudo mv apache-tomcat-10.1.22 tomcat
    sudo chmod +x /opt/tomcat/bin/*.sh
    /opt/tomcat/bin/startup.sh
  EOF

  tags = {
    Name = "App-Server"
  }
}

output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}

output "app_server_ip" {
  description = "Public IP of the App Server"
  value       = aws_instance.app_server.public_ip
}


