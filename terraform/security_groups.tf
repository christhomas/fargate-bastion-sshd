resource "aws_security_group" "bastion" {
	count = "${var.bastion_enabled == true ? 1 : 0}"

	name = "${local.lb}"
	description = "Limits traffic for the ${var.container_name} ECS cluster to the Load Balancer"
	vpc_id = "${var.vpc_id}"

	tags = {
		Name = "${local.lb}"
	}

	lifecycle {
		create_before_destroy = true
	}
}

resource "aws_security_group_rule" "bastion_ingress" {
	type = "ingress"
	security_group_id = "${aws_security_group.bastion[0].id}"
	protocol = "tcp"
	from_port = "${var.port}"
	to_port = "${var.port}"
	cidr_blocks = ["${var.vpc_cidr}"]
}

resource "aws_security_group_rule" "bastion_egress" {
	type = "egress"
	security_group_id = "${aws_security_group.bastion[0].id}"

	protocol = "-1"
	from_port = 0
	to_port = 0
	cidr_blocks = ["0.0.0.0/0"]
}
