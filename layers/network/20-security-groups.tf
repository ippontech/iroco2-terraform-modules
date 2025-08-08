resource "aws_security_group" "this" {
  for_each = local.security_groups

  vpc_id = module.vpc.vpc_id

  name        = each.key
  description = each.value.description

  tags = {
    Name = each.key
  }
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = { for r in local.all_ingress_rules : r.name => r }

  description = each.value.rule.description

  security_group_id            = aws_security_group.this[each.value.sg_name].id
  referenced_security_group_id = try(aws_security_group.this[each.value.rule.referenced_sg].id, null)
  cidr_ipv4                    = try(each.value.rule.cidr_ipv4, null)

  from_port   = each.value.rule.port
  to_port     = each.value.rule.port
  ip_protocol = each.value.rule.protocol

  tags = {
    Name = each.value.name
  }
}

data "aws_prefix_list" "prefix_list" {
  for_each = { for pl in local.prefix_list_ids : pl.alias => pl }
  name     = each.value.name
}

resource "aws_vpc_security_group_egress_rule" "prefix_lists" {
  for_each = { for r in local.all_egress_prefix_list : r.name => r }

  description = each.value.description

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  security_group_id = aws_security_group.this[each.value.sg_name].id
  prefix_list_id    = data.aws_prefix_list.prefix_list[each.value.prefix].id

  tags = {
    Name = each.value.name
  }
}

resource "aws_vpc_security_group_ingress_rule" "computed" {
  for_each = { for r in local.computed_ingress_rules : r.name => r }

  description = each.value.rule.description

  security_group_id            = aws_security_group.this[each.value.sg_name].id
  referenced_security_group_id = aws_security_group.this[each.value.referenced_sg].id

  from_port   = each.value.rule.port
  to_port     = each.value.rule.port
  ip_protocol = "tcp"

  tags = {
    Name = "computed_${each.value.name}"
  }
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = { for r in local.all_egress_rules : r.name => r }

  description = each.value.rule.description

  security_group_id            = aws_security_group.this[each.value.sg_name].id
  referenced_security_group_id = try(aws_security_group.this[each.value.rule.referenced_sg].id, null)
  cidr_ipv4                    = try(each.value.rule.cidr_ipv4, null)

  from_port   = each.value.rule.port
  to_port     = each.value.rule.port
  ip_protocol = each.value.rule.protocol

  tags = {
    Name = each.value.name
  }
}
