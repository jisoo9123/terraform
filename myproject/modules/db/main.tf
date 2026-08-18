# =========================================================
# DB Subnet Group
# =========================================================

resource "aws_db_subnet_group" "myDBSubnetGroup" {
  name = "mini2-db-subnet-group"

  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "mini2-db-subnet-group"
  }
}

# =========================================================
# Aurora MySQL Cluster
# =========================================================

resource "aws_rds_cluster" "myDBCluster" {
  cluster_identifier = "mini2-mysql-cluster"

  engine = "aurora-mysql"

  database_name   = var.db_name
  master_username = var.db_username
  master_password = var.db_password

  db_subnet_group_name = aws_db_subnet_group.myDBSubnetGroup.name

  vpc_security_group_ids = [
    var.db_sg_id
  ]

  backup_retention_period = 1

  skip_final_snapshot = true

  tags = {
    Name = "mini2-mysql-cluster"
  }
}

# =========================================================
# Aurora DB Instance x2
# =========================================================

resource "aws_rds_cluster_instance" "myDBInstance" {
  count = 2

  identifier = "mini2-db-${count.index + 1}"

  cluster_identifier = aws_rds_cluster.myDBCluster.id

  instance_class = "db.t3.medium"

  engine = "aurora-mysql"

  db_subnet_group_name = aws_db_subnet_group.myDBSubnetGroup.name

  publicly_accessible = false

  tags = {
    Name = "mini2-db-${count.index + 1}"
  }
}
