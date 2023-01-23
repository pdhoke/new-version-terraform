# ServiceNow Cloud Provisioning POC - EC2 Instance

**This is a work in progress and should NOT be used for production deployments.**

This module deploys N number of EC2 instances from launch templates that exist outside of Terraform.
It also provides the capability to domain join Windows instances to the FMG domains (FMGDEV.local, FMGUAT.local, and FMG.local, along with tagging options for the AWS Backup service and instance scheduling.

## Run-Book

### Pre-requisites
  
#### IMPORTANT NOTE

Read through `variables.tf` to understand each Terraform variable before running this module's variable.

### Complex Variables in variable.tf

1. `instance_info`: Defines a map of objects that defines each EC2
   instance that needs to be setup. The object contains the following fields that need to be populated in each object

   | field         | type   | example           | description                                                                                                                   |
   | ------------- | ------ | ----------------- | ----------------------------------------------------------------------------------------------------------------------------- |
   | each.key      | hash   | AWSSYDLIMSAD01         | The map key value will be used for naming the EC2 instance                                                                    |
   | subnet_name   | string | shared-iaas-nonprod-vpc-private-a | The tag:Name value assigned to the subnet to deploy the EC2 instance into                                                     |
   | instance_type | string | m5.xlarge          | The EC2 instance type to deploy                                                                                              |
   | launch_template_key       | string | windows-server-2019      | Second part of key value (`${aws_region}::${launch_template_key}`) to the launch_template_list map object. The variable contains mapped SSM parameter  information for different regions (currently only `ap-southeast-2`).

    **Values for launch_template_key**

    The below values can be used for the launch template key. The `launch_template_list` variable can be updated in the `variables.tf` file to cater for more launch templates.

    * `ubuntu-18`: Ubuntu Linux Server 18.04
    * `ubuntu-20`: Ubuntu Linux Server 20.04
    * `windows-server-2019`: Microsoft Windows Server 2019 Base

#### Example Variable: instance_info

```terraform
instance_info = {
    "01" = {
        subnet_name         = "shared-iaas-nonprod-vpc-private-a"
        instance_type       = "m5.xlarge"
        launch_template_key = "/fmgl/cloudplatform/soe/windows-server-2019/launch-template-name"
    },
    "02" = {
        subnet_name         = "shared-iaas-nonprod-vpc-private-b"
        instance_type       = "m5.large"
        launch_template_key = "/fmgl/cloudplatform/soe/ubuntu-20/launch-template-name"
    }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.72.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 3.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.ec2_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.secrets_manager_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.ec2_iam_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.fmg_managed_s3_access_for_ssm_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.secrets_manager_access_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_managed_instance_core](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_key_pair.terraform-generated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_key_pair.user-provided](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_security_group.ec2-security-group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [tls_private_key.main](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_launch_template.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/launch_template) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_ssm_parameter.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source || [aws_subnet.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backup_tag"></a> [backup\_tag](#input\_backup\_tag) | The AWS backup service tag. Refer to https://docs.cks.fmgaws.cloud/01.user-guide/03.operate/backups.html#scheduled-backup-plans for more information. | `map(string)` | `{}` | no |
| <a name="input_custom_tags"></a> [custom\_tags](#input\_custom\_tags) | Tagging for resources created | `map(string)` | `{}` | no |
| <a name="input_ebs_optimized"></a> [ebs\_optimized](#input\_ebs\_optimized) | (Optional) If true, the launched EC2 instance will be EBS-optimized. Note that if this is not set on an instance type that is optimized by default then this will show as disabled but if the instance type is optimized by default then there is no need to set this and there is no effect to disabling it | `bool` | `false` | no |
| <a name="input_enable_instance_autorecovery"></a> [enable\_instance\_autorecovery](#input\_enable\_instance\_autorecovery) | Enable instance auto recovery | `bool` | `true` | no |
| <a name="input_enable_instance_protection"></a> [enable\_instance\_protection](#input\_enable\_instance\_protection) | Enable instance protection | `bool` | `false` | no |
| <a name="input_env"></a> [env](#input\_env) | A logical name to env for which resources are created | `string` | n/a | yes |
| <a name="input_instance_info"></a> [instance\_info](#input\_instance\_info) | Map of objects to provide information about each indvidual EC2 instance to deploy | <pre>map(object({<br>    subnet_name         = string<br>    instance_type       = string<br>    launch_template_key = string<br>  }))</pre> | n/a | yes |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | The instance name | `string` | `""` | no |
| <a name="input_instance_profile"></a> [instance\_profile](#input\_instance\_profile) | IAM instance profile to launch the instance with | `string` | `"FMGManagedSSMInstanceProfile"` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of instance to start | `string` | `"t3.micro"` | no |
| <a name="input_is_windows"></a> [is\_windows](#input\_is\_windows) | Is the instance being provisioned with the Windows platform? | `bool` | n/a | yes |
| <a name="input_launch_template_list"></a> [launch\_template\_list](#input\_launch\_template\_list) | Map of objects containing mapping information for launch templates to names and regions. Used by the instance\_info.launch\_template\_key variable | <pre>map(object({<br>    region          = string<br>    description     = string<br>    launch_template = string<br>  }))</pre> | <pre>{<br>  "ap-southeast-2::ubuntu-18": {<br>    "description": "Ubuntu 18",<br>    "launch_template": "/fmgl/cloudplatform/soe/ubuntu-18/launch-template-name",<br>    "region": "ap-southeast-2"<br>  },<br>  "ap-southeast-2::ubuntu-20": {<br>    "description": "Ubuntu 20",<br>    "launch_template": "/fmgl/cloudplatform/soe/ubuntu-20/launch-template-name",<br>    "region": "ap-southeast-2"<br>  },<br>  "ap-southeast-2::windows-server-2019": {<br>    "description": "Microsoft Windows Server 2019 Base",<br>    "launch_template": "/fmgl/cloudplatform/soe/windows-server-2019/launch-template-name",<br>    "region": "ap-southeast-2"<br>  }<br>}</pre> | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name prefix for resources | `string` | `""` | no |
| <a name="input_private_ip"></a> [private\_ip](#input\_private\_ip) | Private IP address to associate with the instance in a VPC | `string` | `null` | no |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | The public key to access the EC2 instance | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to deploy resources | `string` | `"ap-southeast-2"` | no |
| <a name="input_scheduler_tag"></a> [scheduler\_tag](#input\_scheduler\_tag) | The instance scheduler tag. Refer to https://docs.cks.fmgaws.cloud/01.user-guide/03.operate/instance-scheduler.html for more information. | `map(string)` | `{}` | no |
| <a name="input_security_group_egress"></a> [security\_group\_egress](#input\_security\_group\_egress) | Can be specified multiple times for each egress rule | <pre>list(object({<br>    from_port   = number<br>    protocol    = string<br>    to_port     = number<br>    cidr_blocks = list(string)<br>    description = string<br>  }))</pre> | <pre>[<br>  {<br>    "cidr_blocks": [<br>      "0.0.0.0/0"<br>    ],<br>    "description": null,<br>    "from_port": 0,<br>    "protocol": "-1",<br>    "to_port": 0<br>  }<br>]</pre> | no |
| <a name="input_security_group_id"></a> [security\_group\_id](#input\_security\_group\_id) | Any existing security groups to use | `string` | `null` | no |
| <a name="input_security_group_ingress_with_cidr"></a> [security\_group\_ingress\_with\_cidr](#input\_security\_group\_ingress\_with\_cidr) | Can be specified multiple times for each ingress rule | <pre>list(object({<br>    from_port   = number<br>    protocol    = string<br>    to_port     = number<br>    cidr_blocks = list(string)<br>    description = string<br>  }))</pre> | `[]` | no |
| <a name="input_security_group_ingress_with_sg"></a> [security\_group\_ingress\_with\_sg](#input\_security\_group\_ingress\_with\_sg) | Can be specified multiple times for each ingress rule | <pre>list(object({<br>    from_port       = number<br>    protocol        = string<br>    to_port         = number<br>    security_groups = list(string)<br>    description     = string<br>  }))</pre> | `[]` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | The VPC name | `string` | n/a | yes |
| <a name="input_windows_domain"></a> [windows\_domain](#input\_windows\_domain) | The Windows domain, e.g. FMG, FMGUAT, FMGDEV omitting the .local suffix | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ec2_iam_role_arn"></a> [ec2\_iam\_role\_arn](#output\_ec2\_iam\_role\_arn) | ARN of the EC2 IAM role |
| <a name="output_ec2_iam_role_id"></a> [ec2\_iam\_role\_id](#output\_ec2\_iam\_role\_id) | ID of the EC2 IAM role |
| <a name="output_ec2_iam_role_name"></a> [ec2\_iam\_role\_name](#output\_ec2\_iam\_role\_name) | Name of the EC2 IAM role |
| <a name="output_iam_instance_profile_arn"></a> [iam\_instance\_profile\_arn](#output\_iam\_instance\_profile\_arn) | ARN of the EC2 IAM instance profile |
| <a name="output_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#output\_iam\_instance\_profile\_name) | Name of the EC2 IAM instance profile |
| <a name="output_instance_ids"></a> [instance\_ids](#output\_instance\_ids) | IDs of the EC2 instances |
| <a name="output_private_dns"></a> [private\_dns](#output\_private\_dns) | EC2 instance private DNS names |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | EC2 instance private IPs |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | ID of the Security group created for the EC2 |

### Resources needed before deploying this module

1. VPC Configured
2. Subnets Configured
3. Tag:Name assigned to VPC and subnets to allow for Terraform data providers to filter and find their
   relevant IDs.

### AWS Accounts

1. Account that EC2 instances are being deployed into