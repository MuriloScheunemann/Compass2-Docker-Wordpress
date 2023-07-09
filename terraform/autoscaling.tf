# Launch conf, Auto Scaling Group, associacao entre Auto Scaling e Mount target do LB
resource "aws_launch_configuration" "LAUNCH-CONFIGURATION-wordpress" {
  name_prefix     = "Launch-Configuration-wordpress"
  image_id        = aws_ami_from_instance.AMI-wordpress.id
  instance_type   = "t3.small"
  security_groups = [aws_security_group.SG-instances.id]
  key_name        = aws_key_pair.KEY-wordpress.key_name
  user_data       = file("../userdata-launch-conf.sh")
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "AUTOSCALING-wordpress" {
  name                = "AUTOSCALING-wordpress"
  vpc_zone_identifier = [aws_subnet.sub-private-1a.id, aws_subnet.sub-private-1b.id]
  desired_capacity    = 2
  min_size            = 2
  max_size            = 4
  target_group_arns   = [aws_alb_target_group.TARGETGROUP-wordpress.arn]
  #   health_check_grace_period =
  #   health_health_check_type =  
  launch_configuration = aws_launch_configuration.LAUNCH-CONFIGURATION-wordpress.name
}

resource "aws_autoscaling_attachment" "ASSOCIACAO-AS-TG" {
  autoscaling_group_name = aws_autoscaling_group.AUTOSCALING-wordpress.id
  lb_target_group_arn    = aws_alb_target_group.TARGETGROUP-wordpress.arn
}
