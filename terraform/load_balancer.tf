
resource "aws_lb" "bastion" {
  count = "${var.bastion_enabled == true ? 1 : 0}"

  name                = "${var.app_prefix}-${var.container_name}"
  load_balancer_type  = "network"
  internal            = false
  subnets             = "${var.vpc_subnets}"

  tags = "${var.app_tags}"
}

resource "aws_lb_listener" "bastion" {
  count = "${var.bastion_enabled == true ? 1 : 0}"

  load_balancer_arn = "${aws_lb.bastion[0].id}"
  port              = "${var.port}"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.bastion[0].id}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "bastion" {
  count = "${var.bastion_enabled == true ? 1 : 0}"

  name        = "${var.app_prefix}-${var.container_name}"
  port        = "${var.port}"
  protocol    = "TCP"
  vpc_id      = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    interval  = "30"
    protocol  = "TCP"
    port      = "${var.port}"
  }

  tags = "${var.app_tags}"
}
