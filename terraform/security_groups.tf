resource "aws_security_group" "load_balancer" {
	count = "${var.enable_bastion == 1 ? 1 : 0}"

	name = "${local.lb}"
	description = "Limits traffic for the ${var.container_name} ECS cluster to the Load Balancer"
	vpc_id = "${var.vpc_id}"

	ingress {
		protocol = "tcp"
		from_port = "${var.port}"
		to_port = "${var.port}"
		cidr_blocks = ["${var.vpc_cidr}"]
	}

	egress {
		protocol = "-1"
		from_port = 0
		to_port = 0
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = {
		Name = "${local.lb}"
	}

	lifecycle {
		create_before_destroy = true
	}
}

