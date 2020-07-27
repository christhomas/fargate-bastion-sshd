resource "aws_ecs_cluster" "bastion" {
  count = length(var.env_list)
  name = "${var.prefix}-${var.env_list[count.index]}"
}

resource "aws_cloudwatch_log_group" "bastion" {
  count = length(var.env_list)
  name = "${var.log_group}-${var.env_list[count.index]}"
  retention_in_days = var.log_retention_days
}

data "template_file" "task_template" {
  count = length(var.env_list)
  template = file("${path.module}/ecs.tpl")

  vars = {
    aws_region  = var.aws_region
    name        = var.container_name
    image       = var.image
    cpu         = var.cpu
    memory      = var.memory
    port        = var.port
    log_group   = "${var.log_group}-${var.env_list[count.index]}"
    log_prefix  = var.log_stream_prefix

    env_bastion_keys  = var.bastion_keys
    env_debug_keys    = var.debug_ssh_keys
    env_debug_config  = var.debug_ssh_config
    env_debug_ssh     = var.debug_ssh_connection
  }
}

resource "aws_ecs_task_definition" "task_def" {
  count = var.enabled == true ? length(var.env_list) : 0

  family                   = var.env_list[count.index]
  execution_role_arn       = var.iam_ecs_tasks_role[count.index].arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  container_definitions    = data.template_file.task_template[count.index].rendered
}

resource "aws_ecs_service" "service" {
  count = var.enabled == true ? length(var.env_list) : 0

  name            = var.container_name
  cluster         = aws_ecs_cluster.bastion[count.index].id
  task_definition = aws_ecs_task_definition.task_def[count.index].arn
  desired_count   = "1"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.bastion[count.index].id]
    subnets          = split(",",var.vpc_subnets[count.index])
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.bastion[count.index].arn
    container_name   = var.container_name
    container_port   = var.port
  }
}
