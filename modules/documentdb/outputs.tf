output "cluster_endpoint" {
  description = "Writer endpoint for the DocumentDB cluster"
  value       = aws_docdb_cluster.this.endpoint
}

# output "cluster_reader_endpoint" {
#   description = "Reader endpoint for the DocumentDB cluster"
#   value       = aws_docdb_cluster.this.reader_endpoint
# }

output "cluster_port" {
  description = "Port the DocumentDB cluster listens on"
  value       = aws_docdb_cluster.this.port
}

output "cluster_id" {
  description = "ID of the DocumentDB cluster"
  value       = aws_docdb_cluster.this.id
}

output "security_group_id" {
  description = "ID of the DocumentDB security group"
  value       = aws_security_group.docdb.id
}

output "docdb_connection_config" {
  description = "Full connection config for application use"
  value = {
    endpoint  = aws_docdb_cluster.this.endpoint
    port      = aws_docdb_cluster.this.port
    username  = aws_docdb_cluster.this.master_username
    database  = "vipplay-orange-zone"
  }
  sensitive = true
}
