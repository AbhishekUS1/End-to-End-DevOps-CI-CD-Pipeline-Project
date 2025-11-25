provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "myinstance" {
  ami           = "ami-0dee22c13ea7a9a67" # <-- valid AMI for ap-south-1
  instance_type = "t2.medium"
  key_name      = "project-1"
  security_groups = ["default"]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = true
  }

  tags = {
    Name = "Project-Server"
  }
}

output "instance_public_ip" {
  value = aws_instance.myinstance.public_ip }

