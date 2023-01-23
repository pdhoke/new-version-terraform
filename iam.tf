# Custom IAM policy to allow access to retrieve the AD domain join secret
resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "${local.name_prefix}-${var.env}-secrets-manager-policy"
  description = "Policy to allow retrieval of the AD Domain join secret in Secrets Manager"
  policy = jsonencode(
    {
      "Statement" : [
        {
          "Action" : [
            "ssm:GetParameterHistory",
            "ssm:GetParametersByPath",
            "ssm:GetParameters",
            "ssm:GetParameter"
          ],
          "Effect" : "Allow",
          "Resource" : "*"
        },
        {
          "Action" : "secretsmanager:GetSecretValue",
          "Effect" : "Allow",
          "Resource" : [
            "arn:aws:secretsmanager:ap-southeast-2:208238008176:secret:ADDomainJoin/DEV-9kVIYm",
            "arn:aws:secretsmanager:ap-southeast-2:208238008176:secret:ADDomainJoin/UAT-2bUPrW",
            "arn:aws:secretsmanager:ap-southeast-2:208238008176:secret:ADDomainJoin-5BYGEm"
          ]
        },
        {
          "Action" : "kms:Decrypt",
          "Effect" : "Allow",
          "Resource" : "arn:aws:kms:ap-southeast-2:208238008176:key/00e5c414-cddc-4cf0-9b2e-a53b1d18a7e0"
        }
      ],
      "Version" : "2012-10-17"
  })
}

# Create an IAM role for the EC2 instance
resource "aws_iam_role" "ec2_iam_role" {
  name                 = "${local.name_prefix}-${var.env}-role"
  description          = "${local.name_prefix}-${var.env} role"
  max_session_duration = 3600
  path                 = "/"

  assume_role_policy = jsonencode(
    {
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "ec2.amazonaws.com"
          }
        }
      ],
      "Version" : "2012-10-17"
    }
  )
}

# Attach a custom policy to allow the EC2 IAM role access to retrieve the AD domain join secret
resource "aws_iam_role_policy_attachment" "secrets_manager_access_policy_attachment" {
  role       = aws_iam_role.ec2_iam_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
}

# Attach a managed policy to allow access to Session Manager
resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
  role       = aws_iam_role.ec2_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach a policy to allow access to the centralised S3 bucket for Session Manager logging activity
resource "aws_iam_role_policy_attachment" "fmg_managed_s3_access_for_ssm_policy" {
  role       = aws_iam_role.ec2_iam_role.name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/FMGManagedS3AccessForSSMPolicy"
}

# Create an instance profile for the EC2 instance
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${local.name_prefix}-${var.env}-ec2-instance-profile"
  role = aws_iam_role.ec2_iam_role.name
}