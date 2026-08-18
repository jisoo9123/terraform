output "cluster_endpoint" {
  description = "Aurora MySQL cluster endpoint"
  value       = aws_rds_cluster.myDBCluster.endpoint
}

output "reader_endpoint" {
  description = "Aurora MySQL reader endpoint"
  value       = aws_rds_cluster.myDBCluster.reader_endpoint
}
