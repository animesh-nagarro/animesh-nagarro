variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "public_subnet_id" {
  type = string
}

variable "ssh_key_name" {
  type = string
}

variable "common_tags" {
  type = map(string)
}