# Application Load Balancer
resource "aws_alb" "LOADBALANCER-wordpress" {
  name               = "LoadBalancer-wordpress"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.SG-load-balancer.id]
  subnets            = [aws_subnet.sub-public-1a.id, aws_subnet.sub-public-1b.id]
  tags = {
    Name = "LoadBalancer-wordpress"
  }
}
# Listener do Load Balancer
resource "aws_lb_listener" "LB-LISTENER-wordpress" {
  load_balancer_arn = aws_alb.LOADBALANCER-wordpress.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.TARGETGROUP-wordpress.arn
  }
}
# Target Group
resource "aws_alb_target_group" "TARGETGROUP-wordpress" {
  name        = "TARGET-GROUP-wordpress"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  health_check {
    path     = "/"
    protocol = "HTTP"
    # matcher  = "200,301,302"
  }
  vpc_id = aws_vpc.vpc-wordpress.id
}