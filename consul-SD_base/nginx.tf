resource "aws_autoscaling_group" "nginx" {
  name                 = "${var.prefix}-${var.app_name}-asg"
  launch_configuration = aws_launch_configuration.nginx.name
  desired_capacity     = var.aws_asg_desired
  min_size             = 1
  max_size             = var.aws_asg_max
  vpc_zone_identifier  = [var.aws_vpc_zone_identifier]

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      key                 = "Name"
      value               = "${var.prefix}-${var.app_name}"
      propagate_at_launch = true
    },
    {
      key                 = "Env"
      value               = "consul"
      propagate_at_launch = true
    },
  ]

}

# Generate init script
data "template_file" "nginx_init" {
  template = file("templates/nginx_sh.tpl")
  vars = {
    service_name    = var.app_name
  }
}


resource "aws_launch_configuration" "nginx" {
  name_prefix                 = "${var.prefix}-${var.app_name}-"
  image_id                    = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  associate_public_ip_address = true

  security_groups = [var.aws_sg_nginx_id]
  key_name        = var.aws_key_name
  user_data       = data.template_file.nginx_init.rendered

  iam_instance_profile = var.aws_iam_instance_name

  lifecycle {
    create_before_destroy = true
  }
}
