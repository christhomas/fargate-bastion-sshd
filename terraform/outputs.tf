output "security_group_id" {
  value = length(aws_security_group.bastion) == 1 ? aws_security_group.bastion[0].id : null
}

output "nlb_dns_name" {
  value = length(aws_lb.bastion) == 1 ? aws_lb.bastion[0].dns_name : null
}

output "port" {
  value = length(aws_security_group.bastion) == 1 ? var.port : null
}
