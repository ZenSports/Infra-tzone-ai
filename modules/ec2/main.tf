locals {
  server_types = [
    { name = "api",     subnet_type = "public", path = "/api", port = 80 },
    //{ name = "backend", subnet_type = "private", path = "/backend", port = 80 },
    { name = "cms",     subnet_type = "public", path = "/cms", port = 1337 }
  ]
}

locals {
  server_types_map = {
    for st in local.server_types : st.name => st
  }
}

resource "aws_iam_role" "ssm" {
  name = "ssm-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
resource "aws_iam_instance_profile" "ssm" {
  name = "ssm-instance-profile"
  role = aws_iam_role.ssm.name
}
resource "aws_security_group" "Ec2InstanceConnect" {
  name        = "instanceconnect-sg"
  description = "Allow traffic only from ALB and EC2 Instance Connect"
  vpc_id      = var.vpc_id
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.alb.id, aws_security_group.alb_internal.id]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["18.206.107.24/29"]  # EC2 Instance Connect for us-east-1
  }
  egress {
    from_port   = 0
    to_port     = 0 
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "ALB security group allowing Cloudflare and VPC"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = concat(["10.0.0.0/16"], var.cloudflare_ipv4)
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = concat(["10.0.0.0/16"], var.cloudflare_ipv4)
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "alb_internal" {
  name        = "alb-internal-sg"
  description = "Internal ALB security group allowing only VPC"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
 egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}
resource "aws_elb" "elb" {
  for_each = { for st in local.server_types : st.name => st }
  name            = "elb-${each.key}"
  subnets         = each.value.subnet_type == "public" ? slice(var.public_subnets, 0, 2) : slice(var.private_subnets, 0, 2)
  internal        = each.value.subnet_type == "private"
  security_groups = [each.value.subnet_type == "public" ? aws_security_group.alb.id : aws_security_group.alb_internal.id]
  listener {
    instance_port         = each.value.port
    instance_protocol     = "HTTP"
    lb_port               = 443
    lb_protocol           = "HTTPS"
    ssl_certificate_id    = var.ssl_certificate_arn
  }
  health_check {
    target              = each.value.port
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }
  tags = {
    Name = "elb-${each.key}"
  }
}
resource "aws_launch_template" "lt" {
  for_each      = { for st in local.server_types : st.name => st }
  name_prefix   = "lt-${each.key}-"
  # extract a valid ami-id token from the provided value (handles hidden chars); fallback to trimmed raw value
  image_id = try(
    regexall("(ami-[0-9a-fA-F]{8,17})", lookup(var.ami_map, each.key))[0][0],
    trimspace(lookup(var.ami_map, each.key)),
  )
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.Ec2InstanceConnect.id]
  iam_instance_profile {
    arn = aws_iam_instance_profile.ssm.arn
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${each.key}-instance"
    }
  }
}
resource "aws_autoscaling_group" "asg" {
  for_each = { for st in local.server_types : st.name => st }
  name                 = "asg-${each.key}"
  max_size             = 1
  min_size             = 1
  desired_capacity     = 1
  vpc_zone_identifier  = each.value.subnet_type == "public" ? slice(var.public_subnets, 0, 2) : slice(var.private_subnets, 0, 2)
  launch_template {
    id      = aws_launch_template.lt[each.key].id
    version = "$Latest"
  }
  load_balancers = [aws_elb.elb[each.key].name]
  health_check_type = "EC2"
  tag {
    key                 = "Name"
    value               = "${each.key}-asg"
    propagate_at_launch = true
  }
}
