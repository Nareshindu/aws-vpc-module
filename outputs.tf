output "vpc_id_naresh" {
    value = aws_vpc.main.id
}

output "internet_gateway_id" {
    value = aws_internet_gateway.gw.id
}

# output "internet_gateway_id_tags" {
#     value = aws_internet_gateway.gw.tags
# }

output "igw" {
  value = [for subnet in aws_subnet.public : subnet.id]
}

# output "az" {
#   value = data.aws_availability_zones.example
# }

output "info_vpc" {
  value = data.aws_vpc.selected
}