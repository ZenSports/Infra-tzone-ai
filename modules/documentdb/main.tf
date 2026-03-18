################################################################################
# Security Group
################################################################################

resource "aws_security_group" "docdb" {
  name        = "${var.cluster_identifier}-sg"
  description = "Security group for DocumentDB cluster ${var.cluster_identifier}"
  vpc_id      = var.vpc_id

  ingress {
    description     = "DocumentDB access from EC2 instances"
    from_port       = 27017
    to_port         = 27017
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.cluster_identifier}-sg"
  }
}

################################################################################
# Subnet Group
################################################################################

resource "aws_docdb_subnet_group" "this" {
  name        = "${var.cluster_identifier}-subnet-group"
  description = "Subnet group for DocumentDB cluster ${var.cluster_identifier}"
  subnet_ids  = var.private_subnets

  tags = {
    Name = "${var.cluster_identifier}-subnet-group"
  }
}

################################################################################
# Parameter Group
################################################################################

resource "aws_docdb_cluster_parameter_group" "this" {
  name        = "${var.cluster_identifier}-pg"
  description = "Parameter group for DocumentDB cluster ${var.cluster_identifier}"
  family      = var.parameter_group_family

  parameter {
    name  = "tls"
    value = "disabled" // easier for dev/staging restore; enable for prod
  }

  tags = {
    Name = "${var.cluster_identifier}-pg"
  }
}

################################################################################
# Cluster
################################################################################

resource "aws_docdb_cluster" "this" {
  cluster_identifier = var.cluster_identifier

  engine         = "docdb"
  engine_version = var.engine_version
  port           = 27017

  master_username = var.master_username
  master_password = var.master_password

  db_subnet_group_name            = aws_docdb_subnet_group.this.name
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.this.name
  vpc_security_group_ids          = [aws_security_group.docdb.id]

  storage_encrypted = var.storage_encrypted

  backup_retention_period      = var.backup_retention_period
  preferred_backup_window      = "03:00-05:00"
  preferred_maintenance_window = "sun:05:00-sun:07:00"

  skip_final_snapshot = var.skip_final_snapshot
  deletion_protection = var.deletion_protection

  tags = {
    Name = var.cluster_identifier
  }
}

################################################################################
# Cluster Instances
################################################################################
data "aws_region" "current" {}

resource "aws_docdb_cluster_instance" "this" {
  count = var.instance_count

  identifier         = "${var.cluster_identifier}-${count.index + 1}"
  cluster_identifier = aws_docdb_cluster.this.id
  instance_class     = var.instance_class
  engine             = "docdb"
  availability_zone = "${data.aws_region.current.name}a"
  auto_minor_version_upgrade = true

  tags = {
    Name = "${var.cluster_identifier}-${count.index + 1}"
  }
}
