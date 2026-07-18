data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_instance" "k3s" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  key_name               = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.k3s.id]

  user_data = file("${path.module}/cloud-init.yaml")

  tags = {
    Name = var.project_name
  }
}

resource "aws_eip" "k3s" {
  domain   = "vpc"
  instance = aws_instance.k3s.id
}
