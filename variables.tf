variable "env" {
  description = "A logical name to env for which resources are created"
  type        = string
}

variable "instance_info" {
  description = "Map of objects to provide information about each indvidual EC2 instance to deploy"
  type = map(object({
    subnet_name         = string
    instance_type       = string
    launch_template_key = string
  }))
}

# variable "instance_profile" {
#   description = "IAM instance profile to launch the instance with"
#   type        = string
#   default     = "FMGManagedSSMInstanceProfile"
# }

# variable "instance_type" {
#   description = "The type of instance to start"
#   type        = string
#   default     = "t3.micro"
# }

# variable "instance_name" {
#   description = "The instance name"
#   type        = string
#   default     = ""
# }

variable "vpc_name" {
  description = "The VPC name"
  type        = string
  default = "shared-iaas-nonprod-vpc"
}

variable "region" {
  description = "The region to deploy resources"
  type        = string
  default     = "ap-southeast-2"
}

# variable "public_key" {
#   description = "The public key to access the EC2 instance"
#   type        = string
#   default     = null
# }

variable "key_pair" {
  description = "An existing key pair to access the EC2 instance"
  type        = string
  default     = ""
}

# variable "private_ip" {
#   description = "Private IP address to associate with the instance in a VPC"
#   type        = string
#   default     = null
# }

variable "is_windows" {
  description = "Is the instance being provisioned with the Windows platform?"
  type        = bool
}

variable "name_prefix" {
  description = "Name prefix for resources"
  type        = string
  default     = ""
}

# variable "custom_tags" {
#   description = "Tagging for resources created"
#   type        = map(string)
#   default     = {}
# }

variable "backup_tag" {
  description = "The AWS backup service tag. Refer to https://docs.cks.fmgaws.cloud/01.user-guide/03.operate/backups.html#scheduled-backup-plans for more information."
  type        = string
  default     = ""
}

variable "patch_tag" {
  description = "The AWS patch tag. Refer to https://docs.cks.fmgaws.cloud/01.user-guide/03.operate/backups.html#scheduled-backup-plans for more information."
  type        = string
  default     = ""
}

# variable "scheduler_tag" {
#   description = "The instance scheduler tag. Refer to https://docs.cks.fmgaws.cloud/01.user-guide/03.operate/instance-scheduler.html for more information."
#   type        = string
#   default     = ""
# }

variable "security_group_ingress_with_cidr" {
  description = "Can be specified multiple times for each ingress rule"
  type = list(object({
    from_port   = number
    protocol    = string
    to_port     = number
    cidr_blocks = list(string)
    description = string
  }))
  default = []
}

# variable "security_group_id" {
#   type        = string
#   description = "Any existing security groups to use"
#   default     = null
# }

variable "security_group_ingress_with_sg" {
  description = "Can be specified multiple times for each ingress rule"
  type = list(object({
    from_port       = number
    protocol        = string
    to_port         = number
    security_groups = list(string)
    description     = string
  }))
  default = []
}

variable "security_group_egress" {
  description = "Can be specified multiple times for each egress rule"
  type = list(object({
    from_port   = number
    protocol    = string
    to_port     = number
    cidr_blocks = list(string)
    description = string
  }))
  default = [{
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = null
  }]
}

variable "enable_instance_protection" {
  description = "Enable instance protection"
  type        = bool
  default     = false
}

variable "ebs_optimized" {
  description = "(Optional) If true, the launched EC2 instance will be EBS-optimized. Note that if this is not set on an instance type that is optimized by default then this will show as disabled but if the instance type is optimized by default then there is no need to set this and there is no effect to disabling it"
  type        = bool
  default     = false
}

# variable "enable_instance_autorecovery" {
#   description = "Enable instance auto recovery"
#   type        = bool
#   default     = true
# }

variable "windows_domain" {
  description = "The Windows domain, e.g. FMG, FMGUAT, FMGDEV omitting the .local suffix"
  type        = string
}