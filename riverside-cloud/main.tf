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
  ami               = "ami-0e83be366243f524a" # Ubuntu Server 22.04 LTS
  instance_type     = "t3.medium"
  user_data         = file("init.sh")
  security_groups   = [aws_security_group.allow_ssh.name]

  tags = {
    Name        = "RiversideUtility"
    Description = "Primary utility server for the riverside environment"
  }
}

# The EBS volume was created with Terraform as a resource, but we never want it
# to be destroyed. After creation, we import it as a data source that Terraform
# will never destroy.
#
# 1) Uncomment the resource block and run `terraform apply` to create a new volume.
# 2) Comment the resource block and record the new volume id in the data source block.
# 3) `terraform state rm aws_ebs_volume.riverside_utility`
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

data "aws_ebs_volume" "riverside_utility" {
  filter {
    name   = "volume-id"
    values = ["vol-0433a3e0312547522"]
  }
}

resource "aws_volume_attachment" "riverside_utility" {
  device_name = "/dev/sdf"
  volume_id   = data.aws_ebs_volume.riverside_utility.id
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
