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
  ami           = "ami-0e83be366243f524a"
  instance_type = "t3.medium"

  tags = {
    Name = "RiversideUtility"
    Description = "Primary utility server for the riverside environment"
  }
}
