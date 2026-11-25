# Die Listen ordnen jeder der beiden Zonen einen eigenen Adressbereich zu. Einträge an
# derselben Position gehören zusammen.
locals {
  subnet_cidrs = ["10.30.1.0/24", "10.30.2.0/24"]
  zones        = ["us-east-1a", "us-east-1b"]
}

# Die VPC umfasst den privaten Adressbereich 10.30.0.0/16 und unterstützt DNS-Auflösung
# und DNS-Hostnamen. In der Konsole trägt sie den Namen workshop-3.
resource "aws_vpc" "main" {
  cidr_block           = "10.30.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "workshop-3" }
}

# Das Internet-Gateway verbindet die VPC mit dem Internet. Beide Subnetze verwenden es
# über ihre Routing-Tabelle.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# Die Standardroute leitet IPv4-Verkehr an das Internet-Gateway, wenn für das Ziel keine
# genauere Route existiert.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

# Jede Zone bekommt ein Subnetz mit eigenem Adressbereich. Damit können die zwei Webserver
# in unterschiedlichen Zonen laufen.
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.subnet_cidrs[count.index]
  availability_zone = local.zones[count.index]
}

# Ich weise beiden Subnetzen dieselbe Routing-Tabelle zu. Damit gilt die Route zum
# Internet-Gateway in beiden Zonen.
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
