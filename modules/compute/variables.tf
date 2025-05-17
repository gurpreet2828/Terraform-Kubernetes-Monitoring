#-----compute/variables.tf-----
#===============================
variable "instance_type" {
  type    = string
  default = "t2.medium"
}
# This module creates a key-pair for logging into EC2 instances
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "ssh_key_public" {
  type    = string
  #Replace this with the location of you public key .pub
  default = "~/.ssh/docker.pub"
}

variable "ssh_key_private" {
  type    = string
  #Replace this with the location of you private key
  default = "~/.ssh/docker"
}

variable "public_subnet_one" {}
variable "public_subnet_two" {}

variable "security_group" {}

variable "subnet_ip_one" {}
variable "subnet_ip_two" {}
