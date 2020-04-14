# fargate-bastion-sshd
A Fargate container to allow SSH access into a VPC to access resources on the private subnets configured using environment variables

# Terraform

There is a terraform module included with the project. You can instantiate the module and use it like this:

```
module "bastion" {
    source = "git::https://github.com/christhomas/fargate-bastion-sshd//terraform?ref=master"
    
    ##############################################################################
    # GENERAL FUNCTIONALITY
    ##############################################################################
    # Boolean true|false, defaults to false
    bastion_enabled = "${var.bastion_enabled}"
    
    # String: The AWS Region. E.g. 'eu-west-1'
    aws_region = "${var.aws_region}"
    
    ##############################################################################
    # BASTION CONFIGURATION
    ##############################################################################
    # String: The cluster id terraform has for where to launch this container
    app_cluster_id = "${aws_ecs_cluster.api_server.id}"
    
    # String: A custom defined prefix for the load balancer and security group
    # NOTE: Don't make it too long, there are string length limits
    app_prefix = "${lower(replace(join("-", [var.squad, var.name]), "_", "-"))}"
    
    variable "app_log_group" {
    variable "app_log_stream_prefix" {
    variable "app_tags" {

    ##############################################################################
    # VPC CONFIGURATION
    ##############################################################################
    # String: What VPC subnets to attach this bastion to. Probably should be your public subnets 
    vpc_subnets = "${split(",", data.aws_ssm_parameter.public_subnets.value)}"
    
    # String: What is the id of your VPC to attach the NLB and SG to
    vpc_id = "${data.aws_ssm_parameter.vpc_id.value}"
    
    # String: What is the cidr range of your VPC to attach the SG to
    vpc_cidr = "${data.aws_ssm_parameter.vpc_cidr_block.value}"
    
    # String: A Base64 encoded JSON document. The JSON must be an array of public ssh keys
    vpc_bastion_keys = "${data.aws_ssm_parameter.vpc_bastion_keys.value}"
    
    # String: A ARN of an IAM role that this ecs task can execute under
    iam_role_ecs_execution_arn = "${var.iam_role_ecs_execution.arn}"
    
    # String: A log group that this container will create a log stream under
    log_group = "/aws/ecs/${var.squad}_${var.env}_${var.name}"
    
    tags = {
    squad = "${var.squad}"
    env = "${var.env}"
    }

    variable "iam_role_ecs_execution_arn" {
    
    variable "cpu" {
    variable "memory" {
    
    variable "vpc_subnets" {
    variable "vpc_id" {
    variable "vpc_cidr" {
    variable "vpc_bastion_keys" {
    
    ##############################################################################
    # CONTAINER VARIABLES
    # WARNING: These should be left alone unless you know what you're doing
    # NOTE: You can change these variables if you like, but it's recommended to leave them alone
    # NOTE: If you change the image, you must ensure it functions in a similar way
    # NOTE: If you change the port, the container must also expose the same port, otherwise you'll never be able to connect
    ##############################################################################
    # String: The container name to create, defaults to 'bastion'
    container_name = "bastion"
    container_image = "christhomas/fargate-bastion-sshd:latest"
    container_port = "22"
}
```

# Environment Variables

#### PUBLIC_KEYS
A Base64 encoded string containing a json array of public keys, the keys themselves should not be encoded

#### SHELL_ACCESS
Set to 'true' to enable shell access

#### SHELL_PORT
Set to a numeric value to change the listening port. E.g: 1234

#### DEBUG_KEYS
Set to 'true' to show the authorized_keys

#### DEBUG_CONFIG
Set to 'true' to show the sshd_config file

