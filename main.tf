resource "aws_vpc" "vpc" {
    cidr_block = var.cidr_block
    enable_dns_hostnames = true

    tags = merge(
        var.tags,
        {
            "Name" = "javaperks-vpc-${var.unit_prefix}"
        }
    )
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = merge(
        var.tags,
        {
            "Name" = "javaperks-igw-${var.unit_prefix}"
        }
    )
}

resource "aws_subnet" "public-subnet" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.public_subnet.cidr_block
    availability_zone = "${var.region}${var.public_subnet.az}"
    map_public_ip_on_launch = true
    depends_on = [aws_internet_gateway.igw]

    tags = merge(
        var.tags,
        {
            "Name" = "javaperks-public-subnet-${var.unit_prefix}"
        }
    )
}

resource "aws_subnet" "private-subnets" {
    for_each = var.private_subnets

    vpc_id = aws_vpc.vpc.id
    cidr_block = each.value.cidr_block
    availability_zone = "${var.region}${each.value.az}"

    tags = merge(
        var.tags,
        {
            "Name" = "javaperks-private-subnet-${index(var.private_subnets, each.key)+1}-${var.unit_prefix}"
        }
    )
}

resource "aws_route" "public-routes" {
    route_table_id = aws_vpc.vpc.default_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}

resource "aws_eip" "nat-ip" {
    vpc = true

    tags = merge(
        var.tags,
        {
            "Name" = "javaperks-eip-${var.unit_prefix}"
        }
    )
}

resource "aws_nat_gateway" "natgw" {
    allocation_id   = aws_eip.nat-ip.id
    subnet_id       = aws_subnet.public-subnet.id
    depends_on      = [aws_internet_gateway.igw, aws_subnet.public-subnet]

    tags = merge(
        var.tags,
        {
            "Name" = "javaperks-natgw-${var.unit_prefix}"
        }
    )
}

resource "aws_route_table" "natgw-route" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.natgw.id
    }

    tags = merge(
        var.tags,
        {
            "Name" = "javaperks-natgw-route-${var.unit_prefix}"
        }
    )
}

resource "aws_route_table_association" "route-out" {
    subnet_id = aws_subnet.private-subnet.id
    route_table_id = aws_route_table.natgw-route.id
}


