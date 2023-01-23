terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.72.0"
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  name_prefix   = lower(var.name_prefix)
  linux_ad_join = ""
}

# moving large variables with defaults here
locals {
  launch_template_list = {
  # description = "Map of objects containing mapping information for launch templates to names and regions. Used by the instance_info.launch_template_key variable"
  # type = map(object({
  #   region          = string
  #   description     = string
  #   launch_template = string
  # }))
  # default = {
    "ap-southeast-2::ubuntu-18" = {
      region          = "ap-southeast-2"
      description     = "Ubuntu 18"
      launch_template = "/fmgl/cloudplatform/soe/ubuntu-18/launch-template-name"
    },
    "ap-southeast-2::ubuntu-20" = {
      region          = "ap-southeast-2"
      description     = "Ubuntu 20"
      launch_template = "/fmgl/cloudplatform/soe/ubuntu-20/launch-template-name"
    },
    "ap-southeast-2::windows-server-2019" = {
      region          = "ap-southeast-2"
      description     = "Microsoft Windows Server 2019 Base"
      launch_template = "/fmgl/cloudplatform/soe/windows-server-2019/launch-template-name"
    }
  }
#}
}