data "aws_ami" "tf_al2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-minimal-2023*"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  owners = ["amazon"]
}

resource "aws_launch_template" "tf_lt" {
  name                   = "tf_lt"
  update_default_version = true
  image_id               = data.aws_ami.tf_al2023.id
  instance_type          = "t4g.nano"
  user_data              = filebase64("httpd.sh")
  key_name               = "my-ec2-keypair"
  vpc_security_group_ids = [aws_security_group.tf_sg_public_http.id]

  //  iam_instance_profile {
  //    name = aws_iam_instance_profile.tf_instance_profile.name
  //  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "tf_instance"
    }
  }

  tags = {
    Name = "tf_lt"
  }
}

resource "aws_autoscaling_group" "tf_asg" {
  name                      = "tf_asg"
  min_size                  = 2
  max_size                  = 2
  desired_capacity          = 2
  target_group_arns         = [aws_lb_target_group.tf_lbtg_http.arn]
  vpc_zone_identifier       = [aws_subnet.tf_subnet_public_1.id, aws_subnet.tf_subnet_public_2.id]
  health_check_type         = "ELB"
  health_check_grace_period = 180

  launch_template {
    id      = aws_launch_template.tf_lt.id
    version = "$Latest"
  }
}

resource "aws_lb" "tf_alb_public" {
  name               = "tf-alb-public"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "dualstack"
  subnets            = [aws_subnet.tf_subnet_public_1.id, aws_subnet.tf_subnet_public_2.id]
  security_groups    = [aws_security_group.tf_sg_public_http.id]

  tags = {
    Name = "tf-alb-public"
  }
}

resource "aws_lb_target_group" "tf_lbtg_http" {
  name     = "tf-lbtg-http"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.tf_vpc.id

  tags = {
    Name = "tf-lbtg-http"
  }
}

resource "aws_lb_listener" "tf_http" {
  load_balancer_arn = aws_lb.tf_alb_public.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tf_lbtg_http.arn
  }

  tags = {
    Name = "tf_http"
  }
}
