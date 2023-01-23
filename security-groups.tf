resource "aws_security_group" "ec2-security-group" {
  name_prefix = "${local.name_prefix}-${var.env}-security-group-"
  vpc_id      = data.aws_vpc.selected.id
  description = "Security group for the ec2 instance"

  dynamic "ingress" {
    for_each = var.security_group_ingress_with_cidr
    content {
      from_port   = lookup(ingress.value, "from_port", null)
      to_port     = lookup(ingress.value, "to_port", null)
      protocol    = lookup(ingress.value, "protocol", null)
      cidr_blocks = lookup(ingress.value, "cidr_blocks", null)
      description = lookup(ingress.value, "description", null)
    }
  }

  dynamic "ingress" {
    for_each = var.security_group_ingress_with_sg
    content {
      from_port       = lookup(ingress.value, "from_port", null)
      to_port         = lookup(ingress.value, "to_port", null)
      protocol        = lookup(ingress.value, "protocol", null)
      security_groups = lookup(ingress.value, "security_groups", null)
      description     = lookup(ingress.value, "description", null)
    }
  }

  dynamic "egress" {
    for_each = var.security_group_egress
    content {
      from_port   = lookup(egress.value, "from_port", null)
      to_port     = lookup(egress.value, "to_port", null)
      protocol    = lookup(egress.value, "protocol", null)
      cidr_blocks = lookup(egress.value, "cidr_blocks", null)
      description = lookup(egress.value, "description", null)
    }
  }

  tags = merge(
    { Name = "${var.name_prefix}-${var.env}-sg" }
  )
}