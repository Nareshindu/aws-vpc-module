variable "project_name" {
#   default = "erp"
}

variable "cidr_vpc" {
  default = "191.168.0.0/16"
}

variable "enable_dns_hostnames" {
  default = "true"
}

variable "vpc_name" {
  default = "erp"
}

variable "environment" {
    # default = "dev"
}

variable "common_tags" {
  default = {
    terrafrom = "true"
    project = "ewizard"
    environment = "dev"
  }
}

variable "public_cidr_block" {
  default = ["192.168.1.0/24", "192.168.2.0/24"]
}

variable "private_cidr_block" {
  default = ["192.168.11.0/24", "192.168.12.0/24"]
}

variable "database_cidr_block" {
  default = ["192.168.1.0/24", "192.168.2.0/24"]
}

# variable "public_subnet" {
  
# }

variable "public_subnet_names" {
#   default = ["public-subnet1", "public-subnet2"]
    validation {
      condition = length(var.public_subnet_names) == 2
      error_message = "you should give two cidrs"
    }
}

variable "private_subnet_names" {
#   default = ["public-subnet1", "public-subnet2"]
    validation {
      condition = length(var.private_subnet_names) == 2
      error_message = "you should give two cidrs"
    }
}

variable "database_subnet_names" {
#   default = ["public-subnet1", "public-subnet2"]
    validation {
      condition = length(var.database_subnet_names) == 2
      error_message = "you should give two cidrs"
    }
}

variable "is_peering_required" {
  default = "false"
}

# variable "route_peering" {
#   default = "false"
# }