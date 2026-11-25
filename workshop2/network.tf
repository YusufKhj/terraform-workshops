# Die Listen ordnen jeder Zone einen Adressbereich zu. Workshop 2 nutzt nur den ersten
# Eintrag.
locals {
  subnet_cidrs = ["10.20.1.0/24", "10.20.2.0/24"]
  zones        = ["us-east-1a", "us-east-1b"]
}

# Meine VPC bekommt den privaten Adressbereich 10.20.0.0/16. AWS stellt darin DNS bereit. Am
# Namen workshop-2 erkenne ich das Netz in der Konsole.
resource "aws_vpc" "main" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "workshop-2" }
}

# Ich verbinde das Internet-Gateway mit meiner VPC, damit der Webserver über seine öffentliche
# IP erreichbar sein kann.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# Die Standardroute 0.0.0.0/0 schickt IPv4-Verkehr zum Internet-Gateway, wenn keine genauere
# Route passt.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

# Für den Server lege ich in us-east-1a ein Subnetz mit dem Adressbereich 10.20.1.0/24 an.
resource "aws_subnet" "public" {
  count             = 1
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.subnet_cidrs[count.index]
  availability_zone = local.zones[count.index]
}

# Ich ordne die Routing-Tabelle meinem Subnetz zu. Damit gilt dort der Weg über das Internet-
# Gateway.
resource "aws_route_table_association" "public" {
  count          = 1
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
