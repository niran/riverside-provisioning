terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "riverside_utility" {
  availability_zone = "us-east-2b"
  ami               = "ami-05fb0b8c1424f266b" # Ubuntu Server 22.04 LTS
  instance_type     = "t3.medium"
  user_data         = file("init.sh")
  security_groups   = [aws_security_group.allow_ssh.name]

  tags = {
    Name        = "RiversideUtility"
    Description = "Primary utility server for the riverside environment"
  }
}

# The EBS volumes were created with Terraform as a resource, but we never want them
# to be destroyed. After creation, we import them as data sources that Terraform
# will never destroy.
#
# 1) Uncomment the resource block and run `terraform apply` to create a new volume.
# 2) Display the state of the new resource using `terraform state show aws_ebs_volume.riverside_utility`.
# 3) Comment the resource block and record the new volume id in the data source block.
# 4) `terraform state rm aws_ebs_volume.riverside_utility`
#
# resource "aws_ebs_volume" "riverside_utility" {
#   availability_zone = "us-east-2b"
#   size              = 20
#   encrypted         = true
#   type              = "gp3"
#
#   tags = {
#     Name = "RiversideUtilityVolume"
#   }
# }
# 
# resource "aws_ebs_volume" "riverside_utility_docker" {
#   availability_zone = "us-east-2b"
#   size              = 20
#   type              = "gp3"
#   tags = {
#     Name = "RiversideUtilityDockerVolume"
#   }
# }

data "aws_ebs_volume" "riverside_utility" {
  filter {
    name   = "volume-id"
    values = ["vol-0433a3e0312547522"]
  }
}

data "aws_ebs_volume" "riverside_utility_docker" {
  filter {
    name   = "volume-id"
    values = ["vol-03d935fdefef72307"]
  }
}

resource "aws_volume_attachment" "riverside_utility" {
  device_name = "/dev/sdf"
  volume_id   = data.aws_ebs_volume.riverside_utility.id
  instance_id = aws_instance.riverside_utility.id
}

resource "aws_volume_attachment" "riverside_utility_docker" {
  device_name = "/dev/sdg"
  volume_id   = data.aws_ebs_volume.riverside_utility_docker.id
  instance_id = aws_instance.riverside_utility.id
}

resource "aws_security_group" "allow_ssh" {
  name        = "AllowSSH"
  description = "Make the utility server accessible via SSH from the internet"

  tags = {
    Name = "AllowSSH"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_ssh.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_ipv4" {
  security_group_id = aws_security_group.allow_ssh.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_ipv6" {
  security_group_id = aws_security_group.allow_ssh.id

  cidr_ipv6   = "::/0"
  ip_protocol = "-1"
}

data "aws_route53_zone" "niran_org" {
  name = "niran.org."
}

resource "aws_route53_record" "riverside_utility" {
  zone_id = data.aws_route53_zone.niran_org.zone_id
  name    = "riverside.${data.aws_route53_zone.niran_org.name}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.riverside_utility.public_ip]
}
