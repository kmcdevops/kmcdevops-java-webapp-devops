variable "key_name" {
  default = "kmc_key"
}

variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "jenkins_instance_type" {
  default = "t2.medium"
}

variable "app_instance_type" {
  default = "t2.micro"
}
