resource "aws_security_group" "bastion" {
	count = var.enabled == true ? length(var.env_list) : 0

	name = "${var.prefix}-${var.env_list[count.index]}"
	description = "Limits traffic for the ${var.prefix}-${var.env_list[count.index]} ECS cluster to the Load Balancer"
	vpc_id = var.vpc_id[count.index]

	tags = merge(var.resource_tags[count.index], {
		Name = "${var.prefix}-${var.env_list[count.index]}"
	})

	lifecycle {
		create_before_destroy = true
	}
}

resource "aws_security_group_rule" "bastion_ingress" {
	count = var.enabled == true ? length(var.env_list) : 0

	type              = "ingress"
	security_group_id = aws_security_group.bastion[count.index].id
	protocol          = "tcp"
	from_port         = var.port
	to_port           = var.port
	cidr_blocks       = [var.vpc_cidr[count.index]]
}

resource "aws_security_group_rule" "bastion_egress" {
	count = var.enabled == true ? length(var.env_list) : 0

	type = "egress"
	security_group_id = aws_security_group.bastion[count.index].id

	protocol = "-1"
	from_port = 0
	to_port = 0
	cidr_blocks = ["0.0.0.0/0"]
}
