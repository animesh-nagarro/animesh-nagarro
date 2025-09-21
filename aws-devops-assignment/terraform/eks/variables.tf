variable "cluster_name" {
  type    = string
  default = "eks-gitops"
}

variable "cluster_version" {
  type    = string
  default = "1.27"
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "system_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "app_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "app_node_count" {
  type    = number
  default = 2
}

variable "common_tags" {
  type = map(string)
}