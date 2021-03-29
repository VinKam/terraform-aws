resource "aws_db_instance" "cloud_network_db" {
  allocated_storage    = var.db_storage
  engine               = "mysql"
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  name                 = var.dbname
  username             = var.dbuser
  password             = var.dbpassword
  skip_final_snapshot  = var.skip_db_snapshot
  identifier           = var.db_identifier
  vpc_security_group_ids = [aws_security_group.cloud_network_db.id]
  db_subnet_group_name = aws_db_subnet_group.cloud_network_db.0.name
}

resource "aws_db_subnet_group" "cloud_network_db" {
  count = var.db_subnet_group == true ? 1 : 0
  name = "private_db_group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "private_db_g"
  }
}

resource "aws_security_group" "cloud_network_db" {
  name = "rds_group"
  vpc_id = var.vpc_id

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = [var.network_cidr]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS_group"
  }
}
