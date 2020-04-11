output "security_group_id" {
  count = "${var.enable_bastion == 1 ? 1 : 0}"

  value = "${aws_security_group.load_balancer[0].id}"
}

output "nlb_dns_name" {
  count = "${var.enable_bastion == 1 ? 1 : 0}"

  value = "${aws_lb.bastion[0].dns_name}"
}

output "port" {
  count = "${var.enable_bastion == 1 ? 1 : 0}"

  value = "${var.port}"
}
