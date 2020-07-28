output "security_group_id" {
  value = {
    for key, value in var.env_list: value => length(aws_security_group.bastion) > key ? aws_security_group.bastion[key].id : null
  }
}

output "host" {
  value = {
    for key, value in var.env_list: value => length(aws_lb.bastion) > key ? aws_lb.bastion[key].dns_name : null
  }
}

output "port" {
  value = {
    for key, value in var.env_list: value => length(aws_security_group.bastion) >= key ? var.port : null
  }
}

output "cloudwatch_log_arn" {
  value = aws_cloudwatch_log_group.bastion.*.arn
}
