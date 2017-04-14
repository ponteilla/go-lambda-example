resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name = "${var.name}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.public_subnet.0.id}"

  depends_on = [
    "aws_internet_gateway.gw",
  ]
}

//private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = "${aws_vpc.default.id}"
  count             = "${length(var.public_subnet_cidr)}"
  cidr_block        = "${element(var.private_subnet_cidr, count.index)}"
  availability_zone = "${element(var.availability_zone, count.index)}"
}

resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat.id}"
  }
}

resource "aws_route_table_association" "private_route_table_association" {
  count          = "${length(var.private_subnet_cidr)}"
  subnet_id      = "${aws_subnet.private_subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}

// public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = "${aws_vpc.default.id}"
  count             = "${length(var.private_subnet_cidr)}"
  cidr_block        = "${element(var.public_subnet_cidr, count.index)}"
  availability_zone = "${element(var.availability_zone, count.index)}"
}

resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  count          = "${length(var.public_subnet_cidr)}"
  subnet_id      = "${aws_subnet.public_subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}
