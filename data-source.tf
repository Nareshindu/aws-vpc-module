data "aws_availability_zones" "example" {
  state = "available"
}

# data "default_vpc_info" {
#   default = true
# }

data "aws_vpc" "selected" {
  default = true
}

data "aws_route_table" "name" {
  vpc_id = data.aws_vpc.selected.id
  filter {
    name = "association.main"
    values = ["true"]
  }
}


# filter {
#     name   = "association.main"
#     values = ["true"]
#   }