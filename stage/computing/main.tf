data "aws_ami" "instance_ami" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20210223"]
  }
}

resource "random_id" "random" {
  byte_length = 2
  count = var.instance_count
  keepers = {
    key_name = var.instance_key_name
  }
}

resource "aws_key_pair" "cloud_network_user_keys" {
  key_name = var.instance_key_name
  public_key = file(var.instance_key_path)
}

resource "aws_instance" "cloud_public_instance" {
  count = var.instance_count
  ami = data.aws_ami.instance_ami.id
  instance_type = var.instance_type
  subnet_id = var.public_subnet_ids[count.index]
  vpc_security_group_ids = [var.public_sg]
  key_name = aws_key_pair.cloud_network_user_keys.key_name
  tags = {
    Name = "cloud-instance-${random_id.random[count.index].dec}"
  }
  root_block_device {
    volume_size = var.instance_vol_size
  }
}

resource "aws_lb_target_group_attachment" "cloud_public_instance_attach" {
  count = var.instance_count
  target_group_arn = var.public_target_arn
  target_id = aws_instance.cloud_public_instance[count.index].id
  port = 8000
}
