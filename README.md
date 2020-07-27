# fargate-bastion-sshd
A Fargate container to allow SSH access into a VPC to access resources on the private subnets configured using environment variables

# Installing software

Because each user runs as themselves, not run, `sudo` is here to make sure you can terrify your closest devops by giving yourself a root
ability to install software.

If you can launch containers into an ECS cluster, you can already launch a root enabled container. So it's not like this is 
worse in a technical sense.

# Terraform

There is a terraform module included with the project. You can instantiate the module and use it like this:

```
module "bastion" {
    source = "git::https://github.com/christhomas/fargate-bastion-sshd//terraform?ref=master"
    
    ##############################################################################
    # GENERAL FUNCTIONALITY
    ##############################################################################
    # String: The AWS resource prefix
    prefix = "SQUAD-vpc-bastion"

    # Array(String): The deployment environments to create
    env_list = ["dev"]

    # String: The AWS Region. E.g. 'eu-west-1'
    aws_region = "eu-west-1"

    # Boolean true|false, defaults to false
    enabled = "true"
    
    # String: A Base64 encoded JSON document. The JSON must be an array of public ssh keys
    # This information should probably be calculated from an object and passed through base64 and json encode functions
    bastion_keys = "eyJjdGgiOnsia2V5Ijoic3NoLXJzYSBBQUFBQjNOe....."

    ##############################################################################
    # DEBUGGING FUNCTIONALITY
    ##############################################################################
    # Boolean true|false, defaults false. To show the keys that are configured once the users are configured
    debug_ssh_keys = false
      
    # Boolean true|false, defaults false. To show the sshd_config written after the entrypoint has computed all the users
    debug_ssh_config = false
      
    # Boolean true|false, defaults false. To enable full debugging, although the container will die after one login
    debug_ssh_connection = false
    
    ##############################################################################
    # BASTION CONFIGURATION
    ##############################################################################
    # String: A log group that this container will create a log stream under
    log_group = "/aws/ecs/SQUAD-vpc-bastion"

    # String: Inside the log group, you must give a prefix for this log stream
    # NOTE: it'll already include your container_name automatically, so there 
    #       is no reason to really change this, just leave it alone
    log_stream_prefix = "logs"

    # Number: The number of days to keep logs before cycling the logs
    log_retention_days = 30

    # Map: A map of tags (one for each environment) you'd like to apply to some resources which support them, defaults to empty map
    resource_tags = [
        dev = {
            "Name" = "SQUAD-vpc-bastion"
            "Environment" = "dev"
        }
    ]

    ##############################################################################
    # VPC CONFIGURATION
    ##############################################################################
    # String: What VPC subnets to attach this bastion to. Probably should be your public subnets 
    vpc_subnets = data.aws_ssm_parameter.public_subnets.*.value
    
    # String: What is the id of your VPC to attach the NLB and SG to
    vpc_id = data.aws_ssm_parameter.vpc_id.*.value
    
    # String: What is the cidr range of your VPC to attach the SG to
    vpc_cidr = data.aws_ssm_parameter.vpc_cidr_block.*.value
    
    # String: A ARN of an IAM role that this ecs task can execute under
    iam_ecs_tasks_role = module.execution-role.ecs_tasks_role
        
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

    # String: The port to listen for connecting on
    container_port = "22"
}
```

# Environment Variables

#### PUBLIC_KEYS
A Base64 encoded string containing a json map of public keys, the keys themselves should not be encoded

#### SHELL_PORT
Set to a numeric value to change the listening port. E.g: 1234
This value will default to: 22

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
