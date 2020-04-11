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
          "awslogs-group": "/aws/ecs/${log_group}",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "log"
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
