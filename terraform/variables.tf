variable "bastion_enabled" {
  description = "Whether or not to create the necessary resources"
  default = false
}

variable "aws_region" {
  description = "The region to deploy the app inside"
}

variable "squad" {
  description = "The squad name that these resources belong to"
  default = "example"
}

variable "container_name" {
  description = "The application name given to the ECS task"
  default = "bastion"
}

variable "group_name" {
  description = "The application this container is running part of"
}

variable "env" {
  description = "[string] (dev|staging|prod): One of the defined values"
}

variable "cluster" {
  description = "The name of the cluster this application is being run inside"
}

locals {
  app_slug = "${lower(join("_", [var.squad, var.group_name, var.container_name]))}"
  app_dash = "${replace(local.app_slug, "_", "-")}"
  lb = "${local.app_dash}"
}

////////////////////////////////////////////////////////////
// IAM ROLE CONFIGURATION
variable "iam_role_ecs_execution" {
  description = "The IAM role to execute this task under"
}

////////////////////////////////////////////////////////////
// CONTAINER CONFIGURATION
variable "cpu" {
  description = "Container instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default = 256
}

variable "memory" {
  description = "Container instance memory to provision (in MiB)"
  default = 512
}

variable "port" {
  description = "The exposed external port to connect to this application"
  default = 22
}

variable "image" {
  description = "Docker image for the container to run in the ECS cluster"
  default = "christhomas/fargate-bastion-sshd:no-shell"
}

////////////////////////////////////////////////////////////
// SHARED VPC CONFIGURATION
variable "vpc_subnets" {
  description = "The VPC subnets to attach to"
}

variable "vpc_id" {
  description = "The VPC Id to attach to"
}

variable "vpc_cidr" {
  description = "The VPC CIDR Range to use"
}

variable "vpc_bastion_keys" {
  description = "The bastion keys to install in the SSH server"
}
