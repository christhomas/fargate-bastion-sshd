variable "bastion_enabled" {
  description = "Whether or not to create the necessary resources"
  default = false
}

variable "bastion_debug_keys" {
  description = "To show the keys that are configured once the users are configured"
  default = false
}

variable "bastion_debug_config" {
  description = "To show the sshd_config written after the entrypoint has computed all the users"
  default = false
}

variable "bastion_debug_ssh" {
  description = "To enable full debugging, although the container will die after one login"
  default = false
}

variable "aws_region" {
  description = "The region to deploy the app inside"
}

variable "container_name" {
  description = "The application name given to the ECS task"
  default = "bastion"
}

variable "app_prefix" {
  description = "The prefix for certain aws resources"
}

variable "app_cluster_id" {
  description = "The id of the cluster this application is being run inside"
}

variable "app_log_group" {
  description = "The log group to add this containers logs into"
}

variable "app_log_stream_prefix" {
  description = "The log stream prefix to use for this container"
  default = "log"
}

variable "app_tags" {
  type = map(string)
  description = "The basic set of tags to attach to all supporting resources"
  default = {}
}

////////////////////////////////////////////////////////////
// IAM ROLE CONFIGURATION
variable "iam_role_ecs_execution_arn" {
  description = "The arn of the IAM role to execute this task under"
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
  default = "christhomas/fargate-bastion-sshd:latest"
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
