output "DNS-Load-Balancer" {
  value = aws_alb.LOADBALANCER-wordpress.dns_name
}

output "IP-Bastion-Host" {
  value = aws_instance.EC2-bastion-host.public_ip
}


