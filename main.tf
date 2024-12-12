   resource "aws_instance" "switchhub" {
  ami           = "ami-0166fe664262f664c" 
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  key_name = aws_key_pair.deployer.key_name
  user_data = file("install.sh")

  tags = {
    Name = "switchhhub"
  }
}

 resource "aws_security_group" "allow_tls" {
  name        = "switchhub_web_security_group"
  description = "Allow TLS inbound traffic and all outbound traffic"
 
  tags = {
    Name = "allow_tls"
  }
}

resource "aws_vpc_security_group_ingress_rule" "port_443" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}
resource "aws_vpc_security_group_ingress_rule" "port_80" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_ingress_rule" "port_22" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDf84GuuIK/sLwVWncQjUX0GQs5txBknVL46DHABB/6gsnbXteVHReFPLVXI3QxpgQVR/OB+im381efUx7b2FMcYXmGWZdYAPNFS1usjm2U63gmecMpyt12KuZzy0bFNxfqoh7nr1e+B30+0JyCM8ojWVP/KSABb1Et9SogKmsvf1DhJrnXb3JCbT7OlOaFXUXk/JceKdhD5NVyf99iVPhn4p2Eva2OOnlpEvlBjmHu1VAlfrcLlIrh4skAC7QmTNKfR3MVIbLQF36B8BEzJzTgiEvq1C/UxL4vtRIwh4MeE2S2ooWyBxBjI7RXjZGvvcPRg8oIZh0dbcwDgvE/Hmj3vSYd59fTjzS9ZdbLejZRtO+xB6MyVJUxb5xV4TViTjoco+ESVnt5mCsTedSXC/X7a8oZlWn0WH5WaPxQgJcx8J1Ed7ECrpAX7V4mE7hFMaOqHTHXrylN7TsJ4EmpIehbpVZqEd11NCGEgHsgRfochROAQAsA3yfZsmYia+TG6itjuUhCfCJiwmH/z68gwL7KJqySt0bpXNoyTHqwWoWN9LUJkAcXPnXhdJLJ8HZqMoHKYfhCmUsSVUIT8JL+IMWOHf+HMook8YbP0KiujFiEyKCv37YVNW9kDyL5Vs5pQuRveu3c7L6lCgL9/i4IFLB0hF/dgtH+4zkSqsCqEt/mWw== najib@Najib-Suaras-Mac.local"
}

