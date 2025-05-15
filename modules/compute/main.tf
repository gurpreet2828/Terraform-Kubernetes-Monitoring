#-----compute/main.tf-----
#==========================
provider "aws" {
  region = var.region
}

#Get Linux AMI ID using SSM Parameter endpoint
#==============================================
data "aws_ssm_parameter" "webserver-ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#Create key-pair for logging into EC2 
#======================================
resource "aws_key_pair" "aws-key" {
  key_name   = "k8s"
  public_key = file(var.ssh_key_public)
}

#Create K8s Master
#====================
resource "aws_instance" "k8s-master" {
  instance_type               = "t2.micro"
  ami                         = data.aws_ssm_parameter.webserver-ami.value
  tags = {
  Name = "k8s_master_tf"
  }
  key_name                    = aws_key_pair.aws-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.security_group]
  subnet_id                   = var.public_subnet_one
}

#Create K8s Node
#====================
resource "aws_instance" "k8s-nodes" {
  count = 2
  instance_type               = "t2.micro"
  ami                         = data.aws_ssm_parameter.webserver-ami.value
  tags = {
    Name = "k8s_node_${count.index}"
  }
  key_name                    = aws_key_pair.aws-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.security_group]
  subnet_id                   = var.public_subnet_two
}