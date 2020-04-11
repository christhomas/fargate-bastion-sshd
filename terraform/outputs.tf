output "security_group_id" {
  value = "${length(aws_security_group.load_balancer[0]) == 1 ? aws_security_group.load_balancer[0].id : "disabled"}"
}

output "nlb_dns_name" {
  value = "${length(aws_lb.bastion[0]) == 1 ? aws_lb.bastion[0].dns_name : "disabled"}"
}

output "port" {
  value = "${var.port}"
}
