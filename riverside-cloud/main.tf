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

  tags = {
    Name = "RiversideUtility"
    Description = "Primary utility server for the riverside environment"
  }
}

resource "aws_ebs_volume" "riverside_utility" {
  availability_zone = "us-east-2b"
  size              = 20
  encrypted         = true
  type              = "gp3"

  tags = {
    Name = "RiversideUtilityVolume"
  }
}

resource "aws_volume_attachment" "riverside_utility" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.riverside_utility.id
  instance_id = aws_instance.riverside_utility.id
}
