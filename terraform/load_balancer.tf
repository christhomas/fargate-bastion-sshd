
resource "aws_lb" "bastion" {
  count = "${var.enable_bastion == 1 ? 1 : 0}"

  name                = "${local.lb}"
  load_balancer_type  = "network"
  internal            = false
  subnets             = "${var.vpc_subnets}"

  tags = {
    squad = "${var.squad}"
  }
}

resource "aws_lb_listener" "bastion" {
  count = "${var.enable_bastion == 1 ? 1 : 0}"

  depends_on = [
    "aws_lb.bastion",
    "aws_lb_target_group.bastion"
  ]

  load_balancer_arn = "${aws_lb.bastion[0].id}"
  port              = "${var.port}"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.bastion[0].id}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "bastion" {
  count = "${var.enable_bastion == 1 ? 1 : 0}"

  name        = "${local.lb}"
  port        = "${var.port}"
  protocol    = "TCP"
  vpc_id      = "${var.vpc_id}"
  target_type = "ip"

  health_check {
    interval  = "30"
    protocol  = "TCP"
    port      = "${var.port}"
  }

  tags = {
    squad = "${var.squad}"
  }
}
