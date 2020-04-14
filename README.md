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
    # DEBUGGING FUNCTIONALITY
    ##############################################################################
    # Boolean true|false, defaults false. To show the keys that are configured once the users are configured
    bastion_debug_keys = false
      
    # Boolean true|false, defaults false. To show the sshd_config written after the entrypoint has computed all the users
    bastion_debug_config = false
      
    # Boolean true|false, defaults false. To enable full debugging, although the container will die after one login
    bastion_debug_ssh = false
    
    ##############################################################################
    # BASTION CONFIGURATION
    ##############################################################################
    # String: The cluster id terraform has for where to launch this container
    app_cluster_id = "${aws_ecs_cluster.api_server.id}"
    
    # String: A custom defined prefix for the load balancer and security group
    # NOTE: Don't make it too long, there are string length limits
    app_prefix = "${var.squad}-${var.end}-${var.name}"
    
    # String: A log group that this container will create a log stream under
    app_log_group = "/aws/ecs/${var.squad}_${var.env}_${var.name}"

    # String: Inside the log group, you must give a prefix for this log stream
    # NOTE: it'll already include your container_name automatically, so there 
    #       is no reason to really change this, just leave it alone
    app_log_stream_prefix = "logs"

    # Map: A map of tags you'd like to apply to some resources which support them, defaults to empty map
    app_tags = {
        "squad" = "${var.squad}"
        "env" = "${var.env}"
    }

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
        
    # Number: A fargate compatible number of vCPU units
    # NOTE: the combinations of cpu/memory are fixed, choose compatible values  
    cpu = 256

    # Number: A fargate compatible number of memory units
    # NOTE: the combinations of cpu/memory are fixed, choose compatible values
    memory = 512
    
    ##############################################################################
    # CONTAINER VARIABLES
    # WARNING: These should be left alone unless you know what you're doing
    # NOTE: You can change these variables if you like, but it's recommended to leave them alone
    # NOTE: If you change the image, you must ensure it functions in a similar way
    ##############################################################################
    # String: The container name to create, defaults to 'bastion'
    container_name = "bastion"

    # String: The docker image to deploy
    container_image = "christhomas/fargate-bastion-sshd:latest"

    # String: The port to listen for connectiong on
    container_port = "22"
}
```

# Environment Variables

#### PUBLIC_KEYS
A Base64 encoded string containing a json map of public keys, the keys themselves should not be encoded

#### SHELL_PORT
Set to a numeric value to change the listening port. E.g: 1234

#### DEBUG_KEYS
Set to 'true' to show the authorized_keys

#### DEBUG_CONFIG
Set to 'true' to show the sshd_config file

#### DEBUG_SSH
Set to 'true' to enable '-ddd' command line option with maximum debugging output, although it'll only allow one login before quitting

# Public Key JSON Data Structure

Here is an example of what the PUBLIC_KEYS value should be

```text
{
  "alpha": {
    "key": "the entire public key here",
    "shell": true
  },
  "omega": {
    "key": [
      "another key here",
      "although this can store multiple keys",
    ],
    "shell": false
  }
}

```

This entire JSON document should be base64 encoded and stored. A typical example might be:

```
cat public_keys.json | base64
```

This simple but effective way to easily store the encoded data without problem of quoting 
or escapaing allows the container to quickly use the data inside the entrypoint to do the 
following:
+ Write the basic SSH Configuration
+ Set the appropriate SSH port to listen on
+ Decode the public keys into a json document
+ Loop through all the users in the public keys file
+ For each user, create an account with a random password
+ Write all the keys for each user into the `authorized_keys` file
+ Set all the permissions
+ Enable or disable shell login, depending on the value of the `shell` entry
+ Execute the SSH Daemon

# Logging in to the container

You simply need to execute: `ssh <user>@the_dns_name_of_the_load_balancer.com -p <port>`
If you have shell access, this will let you into the container, you could run some `apk` commands
if you need any specific software installed. 

You'll be refused entry unless you're shell access is enabled. If it's disabled. You can still port forward
to other places, RDS for example.
