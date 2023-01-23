# Select the VPC name
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

# Select the Subnet name to deploy the EC2 instance
data "aws_subnet" "selected" {
  for_each = var.instance_info

  vpc_id = data.aws_vpc.selected.id

  filter {
    name   = "tag:Name"
    values = [each.value.subnet_name]
  }
}

# Select the launch template parameter value to use from the Parameter Store
data "aws_ssm_parameter" "selected" {
  for_each = var.instance_info

  name = lookup(local.launch_template_list, "${data.aws_region.current.name}::${var.instance_info[each.key].launch_template_key}", null) == null ? var.instance_info[each.key].launch_template_key : local.launch_template_list["${data.aws_region.current.name}::${var.instance_info[each.key].launch_template_key}"].launch_template
}

# Select the Launch template parameter to use as a result of a lookup in the Parameter Store
data "aws_launch_template" "selected" {
  for_each = var.instance_info

  name = data.aws_ssm_parameter.selected[each.key].value
}

# Provision a new EC2 instance
resource "aws_instance" "main" {
  # Iterate using for_each
  for_each = var.instance_info

  launch_template {
    name = data.aws_launch_template.selected[each.key].name
  }

  instance_type           = var.instance_info[each.key].instance_type
  availability_zone       = data.aws_subnet.selected[each.key].availability_zone
  key_name                = var.key_pair
  iam_instance_profile    = aws_iam_instance_profile.ec2_instance_profile.name
  disable_api_termination = var.enable_instance_protection
  ebs_optimized           = var.ebs_optimized
  # private_ip              = var.private_ip != null ? var.private_ip : null
  user_data = var.is_windows ? tostring(<<-EOT
<powershell>
[string]$newHostName = '${lower(each.key)}'
[string]$domainJoinUser = '${lower(var.windows_domain)}\svc.az.domainjoin'
%{if var.env == "dev"}[string]$domainJoinSecret = (Get-SECSecretValue -SecretId 'arn:aws:secretsmanager:ap-southeast-2:208238008176:secret:ADDomainJoin/DEV-9kVIYm'  -VersionStage 'AWSCURRENT' -Select 'SecretString' | ConvertFrom-Json).ADDomainJoin%{endif}
%{if var.env == "uat"}[string]$domainJoinSecret = (Get-SECSecretValue -SecretId 'arn:aws:secretsmanager:ap-southeast-2:208238008176:secret:ADDomainJoin/UAT-2bUPrW' -VersionStage 'AWSCURRENT' -Select 'SecretString' | ConvertFrom-Json).ADDomainJoin%{endif}
%{if var.env == "prod"}[string]$domainJoinSecret = (Get-SECSecretValue -SecretId 'arn:aws:secretsmanager:ap-southeast-2:208238008176:secret:ADDomainJoin-5BYGEm' -VersionStage 'AWSCURRENT' -Select 'SecretString' | ConvertFrom-Json).DomainJoinSecret%{endif}
[securestring]$secretObject = (ConvertTo-SecureString $domainJoinSecret -AsPlainText -Force)
[pscredential]$credentialSet = New-Object System.Management.Automation.PSCredential ($domainJoinUser, $secretObject)
Add-Computer -DomainName "${var.windows_domain}.local" -OUPath "OU=AWS,OU=Servers,OU=Unmanaged,OU=ComputerObjects,DC=${var.windows_domain},DC=local" -NewName $newHostName -Credential $credentialSet -Verbose -Force -Restart
</powershell>
<persist>true</persist>
  EOT
  ) : local.linux_ad_join

  tags        = { Name = "${lower(each.key)}" }
  volume_tags = { Name = "${lower(each.key)}-${var.env}-vol" }
}

resource "aws_ec2_tag" "tag_backup_plan" {
  for_each = aws_instance.main
  
  resource_id = each.value.id
  key         = "fmgl:cloudplatform:backup-plan"
  value       = var.backup_tag
}

resource "aws_ec2_tag" "tag_patch_action" {
  for_each = aws_instance.main
  
  resource_id = each.value.id
  key         = "fmgl:cloudplatform:patch-action"
  value       = var.patch_tag
}