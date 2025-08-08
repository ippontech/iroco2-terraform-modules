# Get the latest encrypted amazon 2 AMI
data "aws_ami" "amazon_linux_3" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_ami_copy" "amazon_linux_3_encrypted" {
  name              = "bastion-${data.aws_ami.amazon_linux_3.name}-encrypted-temp"
  description       = "A copy of ${data.aws_ami.amazon_linux_3.description} but encrypted"
  source_ami_id     = data.aws_ami.amazon_linux_3.id
  source_ami_region = data.aws_region.current.name
  encrypted         = true
  tags = {
    ImageType = "encrypted-al3-linux"
  }
}
