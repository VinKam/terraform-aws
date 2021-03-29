resource "aws_lb" "cloud_network_lb" {
  name = "cloud-network-lb"
  subnets = var.public_subnets
  security_groups = [var.public_sg]
  tags = {
    Name = "cloud_network_lb"
  }
}

resource "aws_lb_target_group" "cloud_network_lb" {
  name = "cloud-network-lb-${substr(uuid(), 0, 3)}"
  vpc_id = var.network_vpc_id
  port = var.tg_port
  protocol = var.tg_protocol
  health_check {
    healthy_threshold = var.lb_healthy_threshold
    unhealthy_threshold = var.lb_unhealthy_threshold
    timeout = var.lb_timeout 
    interval = var.lb_interval
  }
  lifecycle {
    ignore_changes = [name]
    create_before_destroy = true
  }

}

resource "aws_lb_listener" "cloud_network_lb" {
  load_balancer_arn = aws_lb.cloud_network_lb.arn
  port = var.listener_port
  protocol = var.listener_protocol
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.cloud_network_lb.arn
  }
}
