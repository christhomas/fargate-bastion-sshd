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
