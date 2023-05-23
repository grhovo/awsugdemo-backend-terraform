# Create a Network Load Balancer
resource "aws_lb" "nlb" {
  name    = "${var.common_name}-lb"
  internal           = true
  load_balancer_type = "network"
  subnets = [ data.aws_subnet.private_subnet_1.id, data.aws_subnet.private_subnet_2.id ]
}

# Create a listener for the Network Load Balancer
resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port = "80"
  protocol = "TCP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# Create a target group for the Auto Scaling Group
resource "aws_lb_target_group" "tg" {
  name = "${var.common_name}-nlbtg"
  port = 80
  protocol = "TCP"
  vpc_id = data.aws_vpc.vpc.id
  health_check {
    port = 80
    protocol = "TCP"
  }
}

# Attach the target group to the Auto Scaling Group
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.name
  alb_target_group_arn = aws_lb_target_group.tg.arn
}

# Register the instances in the target group
resource "aws_lb_target_group_attachment" "lb_attachment" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_autoscaling_group.asg.id
  port             = 80
}
