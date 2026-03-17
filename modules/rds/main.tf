# Fetch snapshot data for restore
data "aws_db_snapshot" "snapshot" {
  count                = var.snapshot_identifier != null ? 1 : 0
  db_snapshot_identifier = var.snapshot_identifier
  most_recent          = var.snapshot_most_recent
}

# RDS Subnet Group
resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-rds-subnet-group"
  subnet_ids = var.private_subnets

  tags = merge(var.tags, {
    Name = "${var.name}-rds-subnet-group"
  })
}

# RDS Security Group
resource "aws_security_group" "this" {
  name        = "${var.name}-rds-sg"
  description = "RDS access from allowed services"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
  }

  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name}-rds-sg"
  })
}

# RDS Parameter Group
resource "aws_db_parameter_group" "this" {
  name   = "${var.name}-rds-params"
  family = var.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameter_group_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name}-rds-params"
  })
}

# Primary RDS Instance (Snapshot Restore + Multi-AZ Ready)
resource "aws_db_instance" "this" {
  # SNAPSHOT RESTORE - highest precedence
  snapshot_identifier = var.snapshot_identifier != null ? data.aws_db_snapshot.snapshot[0].id : null

  identifier             = var.name
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  
  # Storage - use snapshot storage if restoring, else use var
  allocated_storage      = var.snapshot_identifier != null ? data.aws_db_snapshot.snapshot[0].allocated_storage : var.allocated_storage
  max_allocated_storage  = var.max_allocated_storage
  storage_type           = var.storage_type
  storage_encrypted      = true

  # Only set these for NEW instances (skip during snapshot restore)
  db_name                = var.snapshot_identifier == null ? var.db_name : null
  username               = var.snapshot_identifier == null ? var.db_username : null
  password               = var.snapshot_identifier == null ? var.db_password : null
  port                   = var.db_port

  multi_az               = var.multi_az
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]

  backup_retention_period    = var.backup_retention_period
  backup_window              = var.backup_window
  maintenance_window         = var.maintenance_window
  deletion_protection        = var.deletion_protection
  skip_final_snapshot        = false
  final_snapshot_identifier  = "${var.name}-final-snapshot"
  copy_tags_to_snapshot      = true

  monitoring_interval         = var.monitoring_interval
  performance_insights_enabled = var.performance_insights_enabled

  parameter_group_name = aws_db_parameter_group.this.name

  tags = merge(var.tags, {
    Name = "${var.name}-rds"
  })
}
