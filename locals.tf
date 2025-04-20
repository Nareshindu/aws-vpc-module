locals {
  project_name = "ewizard"
  cidr_vpcs = "192.168.0.0/16"
  resource_name = "${var.project_name}-${var.environment}"
  az_names = slice(data.aws_availability_zones.example.names, 0, 3)
}