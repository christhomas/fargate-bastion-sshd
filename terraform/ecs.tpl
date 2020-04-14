[
  {
    "name": "bastion",
    "image": "${image}",
    "cpu": ${cpu},
    "memory": ${memory},
    "networkMode": "awsvpc",
    "mountPoints": [],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${log_group}",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "${log_prefix}"
        }
    },
	"environment": [
		{
			"name": "PUBLIC_KEYS",
			"value": "${env_bastion_keys}"
		},{
			"name": "SHELL_PORT",
			"value": "${port}"
		},{
			"name": "DEBUG_KEYS",
			"value": "${env_debug_keys}"
		},{
			"name": "DEBUG_CONFIG",
			"value": "${env_debug_config}"
		},{
			"name": "DEBUG_SSH",
			"value": "${env_debug_ssh}"
		}
	],
    "portMappings": [
      {
        "containerPort": ${port},
        "hostPort": ${port}
      }
    ]
  }
]
