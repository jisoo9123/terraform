# =========================================================
# Launch Template
# =========================================================

resource "aws_launch_template" "web" {
  name = "mini2-web-lt"

  image_id      = "ami-0159816442b921a1c"
  instance_type = "t3.micro"
  key_name      = var.key_name

  vpc_security_group_ids = [
    var.web_sg_id
  ]

  user_data = base64encode(<<-EOF
#!/bin/bash

dnf -y update

dnf -y install httpd php php-mysqlnd

systemctl enable httpd
systemctl start httpd

cat > /var/www/html/index.php <<'PHP'
<?php
echo "<h1>Mini Project 2 Web Server</h1>";
echo "<p>WEB/WAS Server is running.</p>";
?>
PHP

EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "mini2-web"
    }
  }
}
