data "aws_ami" "amznlinux2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  owners = ["amazon"]
}

resource "aws_launch_template" "tf_lt" {
  name                   = "tf_lt"
  update_default_version = true
  image_id               = data.aws_ami.amznlinux2.id
  instance_type          = "t2.micro"
  user_data              = filebase64("httpd.sh")
  key_name               = "my-ec2-keypair"
  vpc_security_group_ids = [aws_security_group.tf_sg.id]

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
  name              = "tf_asg"
  min_size          = 2
  max_size          = 2
  desired_capacity  = 2
  target_group_arns = [aws_lb_target_group.tf_lbtg.arn]
  vpc_zone_identifier  = [aws_subnet.tf_subnet_1.id, aws_subnet.tf_subnet_2.id]
  health_check_type = "ELB"
  health_check_grace_period = 180

  launch_template {
    id      = aws_launch_template.tf_lt.id
    version = "$Latest"
  }
}

resource "aws_lb" "tf_alb" {
  name               = "tf-alb"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "dualstack"
  subnets            = [aws_subnet.tf_subnet_1.id, aws_subnet.tf_subnet_2.id]
  security_groups = [aws_security_group.tf_sg.id]

  tags = {
    Name = "tf-alb"
  }
}

resource "aws_lb_target_group" "tf_lbtg" {
  name     = "tf-lbtg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.tf_vpc.id

  tags = {
    Name = "tf-lbtg"
  }
}

resource "aws_lb_listener" "tf_http" {
  load_balancer_arn = aws_lb.tf_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tf_lbtg.arn
  }
}
