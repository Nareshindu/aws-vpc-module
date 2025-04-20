resource "aws_vpc" "main" {
  cidr_block       = local.cidr_vpcs
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
        var.common_tags,
    {
         Name = local.resource_name
    }
  )
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
        Name = local.resource_name
    }
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_names)  
  vpc_id     = aws_vpc.main.id
  map_public_ip_on_launch = true
  cidr_block = var.public_cidr_block[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge(
    var.common_tags,
    {
        Name = "${local.resource_name}-public-${local.az_names[count.index]}"
    }
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_names)  
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_cidr_block[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge(
    var.common_tags,
    {
        Name = "${local.resource_name}-private-${local.az_names[count.index]}"
    }
  )
}

resource "aws_subnet" "database" {
  count = length(var.database_subnet_names)  
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_cidr_block[count.index]
  availability_zone = local.az_names[count.index]

  tags = merge(
    var.common_tags,
    {
        Name = "${local.resource_name}-database-${local.az_names[count.index]}"
    }
  )
}


resource "aws_db_subnet_group" "default" {
  name       = local.resource_name
  subnet_ids = aws_subnet.database[*].id

  tags = merge(
    var.common_tags,
    {
        Name = "${local.resource_name}"
    }
  )
}

resource "aws_eip" "eip" {
  vpc = true
  
  tags = merge(
    var.common_tags,
    {
        Name = "${local.resource_name}"
    }
  )
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    var.common_tags,

    {
      Name = "${local.resource_name}"
    }
  )
  
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
        Name = "${local.resource_name}-public"
    }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
        Name = "${local.resource_name}-private"
    }
  )
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.common_tags,
    {
        Name = "${local.resource_name}-database"
    }
  )
}

resource "aws_route" "public_route" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}

resource "aws_route" "private_route" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

resource "aws_route" "database_route" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_cidr_block)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_cidr_block)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_cidr_block)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}

resource "aws_vpc_peering_connection" "foo" {
  count = var.is_peering_required ? 1 : 0 
  peer_vpc_id   = data.aws_vpc.selected.id #acceptor
  vpc_id        = aws_vpc.main.id #requestor
  auto_accept = true 

  tags = merge(
    var.common_tags,
    {
        Name = "${local.resource_name}-default"
    }
  )
}

resource "aws_route" "public_route_expense" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.selected.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.foo[0].id
}

resource "aws_route" "private_route_expense" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.aws_vpc.selected.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.foo[0].id
}

resource "aws_route" "database_route_expense" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = data.aws_vpc.selected.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.foo[0].id
}

resource "aws_route" "default_route_peering" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = data.aws_route_table.name.id
  destination_cidr_block    = aws_vpc.main.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.foo[0].id
}


