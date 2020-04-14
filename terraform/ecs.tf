data "template_file" "task_template" {
  template = "${file("${path.module}/ecs.tpl")}"

  vars = {
    aws_region  = "${var.aws_region}"
    name        = "${var.container_name}"
    image       = "${var.image}"
    cpu         = "${var.cpu}"
    memory      = "${var.memory}"
    port        = "${var.port}"
    log_group   = "${var.app_log_group}"
    log_prefix  = "${var.app_log_stream_prefix}"

    env_bastion_keys   = "${var.vpc_bastion_keys}"
  }
}

resource "aws_ecs_task_definition" "task_def" {
  count = "${var.bastion_enabled == true ? 1 : 0}"

  family                   = "${var.container_name}"
  execution_role_arn       = "${var.iam_role_ecs_execution_arn}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "${var.cpu}"
  memory                   = "${var.memory}"
  container_definitions    = "${data.template_file.task_template.rendered}"
}

resource "aws_ecs_service" "service" {
  count = "${var.bastion_enabled == true ? 1 : 0}"

  name            = "${var.container_name}"
  cluster         = "${var.app_cluster_id}"
  task_definition = "${aws_ecs_task_definition.task_def[0].arn}"
  desired_count   = "1"
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = ["${aws_security_group.bastion[0].id}"]
    subnets          = "${var.vpc_subnets}"
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_lb_target_group.bastion[0].arn}"
    container_name   = "${var.container_name}"
    container_port   = "${var.port}"
  }
}
