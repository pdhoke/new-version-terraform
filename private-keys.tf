# Replaced with using an existing keypair

# # Generate a secure private key and encode it as PEM
# resource "tls_private_key" "main" {
#   count     = var.public_key == null ? 1 : 0
#   algorithm = "RSA"
# }

# # Let Terraform generate a new EC2 key pair if a public key is not specified
# resource "aws_key_pair" "terraform-generated" {
#   count = var.public_key == null ? 1 : 0

#   key_name   = "${local.name_prefix}-${var.env}-ec2-key-terraform"
#   public_key = tls_private_key.main[0].public_key_openssh

#   tags = merge({
#     Name = "${local.name_prefix}-${var.env}-ec2-key"
#   }, var.custom_tags)
# }

# # Create an EC2 key pair with the user-provided public key (if supplied)
# resource "aws_key_pair" "user-provided" {
#   count = var.public_key != null ? 1 : 0

#   key_name   = "${local.name_prefix}-${var.env}-ec2-key-user_provided"
#   public_key = var.public_key

#   tags = merge({
#     Name = "${local.name_prefix}-${var.env}-ec2-key"
#   }, var.custom_tags)
# }