# outputs
output "instance_ids" {
  description = "IDs of the EC2 instances"
  value       = [for instance in aws_instance.main : instance.id]
}

output "private_dns" {
  description = "EC2 instance private DNS names"
  value = {
    for instance in aws_instance.main :
    instance.id => instance.private_dns
  }
}

output "private_ip" {
  description = "EC2 instance private IPs"
  value = {
    for instance in aws_instance.main :
    instance.id => instance.private_ip
  }
}

output "security_group_id" {
  description = "ID of the Security group created for the EC2"
  value       = aws_security_group.ec2-security-group.id
}

output "ec2_iam_role_id" {
  description = "ID of the EC2 IAM role"
  value       = aws_iam_role.ec2_iam_role.id
}

output "ec2_iam_role_name" {
  description = "Name of the EC2 IAM role"
  value       = aws_iam_role.ec2_iam_role.name
}

output "ec2_iam_role_arn" {
  description = "ARN of the EC2 IAM role"
  value       = aws_iam_role.ec2_iam_role.arn
}

output "iam_instance_profile_name" {
  description = "Name of the EC2 IAM instance profile"
  value       = aws_iam_instance_profile.ec2_instance_profile.name
}

output "iam_instance_profile_arn" {
  description = "ARN of the EC2 IAM instance profile"
  value       = aws_iam_instance_profile.ec2_instance_profile.arn
}