
resource "aws_lb" "bastion" {
  count = var.enabled == true ? length(var.env_list) : 0

  name                = "${var.prefix}-${var.env_list[count.index]}"
  load_balancer_type  = "network"
  internal            = false
  subnets             = split(",",var.vpc_subnets[count.index])

  tags = var.resource_tags[count.index]
}

resource "aws_lb_listener" "bastion" {
  count = var.enabled == true ? length(var.env_list) : 0

  load_balancer_arn = aws_lb.bastion[count.index].id
  port              = var.port
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.bastion[count.index].id
    type             = "forward"
  }
}

resource "aws_lb_target_group" "bastion" {
  count = var.enabled == true ? length(var.env_list) : 0

  name        = "${var.prefix}-${var.env_list[count.index]}"
  port        = var.port
  protocol    = "TCP"
  vpc_id      = var.vpc_id[count.index]
  target_type = "ip"

  health_check {
    interval  = "30"
    protocol  = "TCP"
    port      = var.port
  }

  tags = var.resource_tags[count.index]
}
