
resource "aws_key_pair" "petunia" {
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBSfZUb2FwLdSh2iOyETlWhez+vsJ+lBgQ8GrUEjc5Cm6ChY5HSxw+78w+P6Dm3t3w3ThxKsdb7Yt/l5nVG1B+pRKTB1z6ND1BNNm6LsNCFw6E2q8O8HwMz4CeN1pgZNFB8v2USTRgXGZd/b/Q1gBK9W9lcASouvnnIHaRA17nBm30NcicEG8hcnp81Jgo3Ml6YJx6nj4rmTecFNoTQVo/w6JBRMIM9A3x575cy54sB6Q6hX+Gb7KiiV5WH1hivJqwDBovqs86RBxJdbygnc2iwf2u30ltH0LH/YFxET4yK6n2bPCCwANLHXk+7/3+0k4r0O8m5l8B1k1i8pxwVtQ2/GLnUs0IQPftthFQ2QpyRL/mCjz4uPSZuzXk1WwsR7atvfKd1+cmrtH3s17QH+KDU3fL5zXGsWsCtMoUUy4fM1YQAzmOVSURgtJ9Uf1NJYlS9Fw/SMB2v5nPiTB5HbKy3OmHcwIyms2vQ4yqfxpGUAETWZCDzKplCIRMVliF3rk="
}

resource "aws_instance" "mymachine" {
  ami           = var.nixos_amis.latest[var.region].hvm-ebs
  instance_type = "t3.micro"
  vpc_security_group_ids = [ aws_security_group.default.id ]
  subnet_id = aws_subnet.subnet_a.id
  key_name = aws_key_pair.petunia.key_name
  associate_public_ip_address = false
  root_block_device {
    volume_size = 20
  }
}

resource "aws_eip" "mymachine" {
  vpc = true

  instance                  = aws_instance.mymachine.id
  depends_on                = [ aws_internet_gateway.default ]
}
