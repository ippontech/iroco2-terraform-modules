locals {

  prefix_list_ids = {
    vpce_s3 = {
      alias = "vpce_s3_prefix_list"
      name  = "com.amazonaws.${data.aws_region.this.name}.s3"
    }
  }

  common_egress_rules = {
    # TODO: remove this global rule once all workload gets the new security group
    ingress_wide_private_subnet = [
      {
        description = "Allow TLS communication from anywhere in the private subnets 0"
        port        = 443
        protocol    = "tcp"
        cidr_ipv4   = module.vpc.private_subnets_cidr_blocks[0]
      },
      {
        description = "Allow TLS communication from anywhere in the private subnets 1"
        port        = 443
        protocol    = "tcp"
        cidr_ipv4   = module.vpc.private_subnets_cidr_blocks[1]
      }
    ]
    vpce_ecr = [
      {
        description   = "Allow communication to VPC endpoint ECR API"
        port          = 443
        protocol      = "tcp"
        referenced_sg = "vpce_ecr_api"
      },
      {
        description   = "Allow communication to VPC endpoint ECR DKR"
        port          = 443
        protocol      = "tcp"
        referenced_sg = "vpce_ecr_dkr"
      }
    ],
    vpce_ssm = [
      {
        description   = "Allow communication to VPC endpoint SSM"
        port          = 443
        protocol      = "tcp"
        referenced_sg = "vpce_ssm"
      },
      {
        description   = "Allow communication to VPC endpoint SSM messages"
        port          = 443
        protocol      = "tcp"
        referenced_sg = "vpce_ssm_messages"
      }
    ],
    vpce_logs = [{
      description   = "Allow communication to VPC endpoint logs"
      port          = 443
      protocol      = "tcp"
      referenced_sg = "vpce_logs"
    }],
    iroco_database = [{
      description   = "Allow communication to IroCO database"
      port          = 5432
      protocol      = "tcp"
      referenced_sg = "iroco_database"
    }],
    vpce_kms = [{
      description   = "Allow communication to VPC endpoint KMS"
      port          = 443
      protocol      = "tcp"
      referenced_sg = "vpce_kms"
    }]
  }

  security_groups = {
    vpce_ec2 = {
      description   = "The VPC endpoint EC2 security group",
      ingress_rules = local.common_egress_rules.ingress_wide_private_subnet
    },
    vpce_ecr_dkr = {
      description   = "The VPC endpoint ECR DKR security group",
      ingress_rules = local.common_egress_rules.ingress_wide_private_subnet
    },
    vpce_ecr_api = {
      description   = "The VPC endpoint ECR API security group",
      ingress_rules = local.common_egress_rules.ingress_wide_private_subnet
    },
    vpce_logs = {
      description   = "The VPC endpoint logs security group",
      ingress_rules = local.common_egress_rules.ingress_wide_private_subnet
    }
    vpce_secrets_manager = {
      description   = "The VPC endpoint Secrets Manager security group",
      ingress_rules = local.common_egress_rules.ingress_wide_private_subnet
    }
    vpce_sqs = {
      description   = "The VPC endpoint SQS security group",
      ingress_rules = local.common_egress_rules.ingress_wide_private_subnet
    }
    vpce_ssm = {
      description   = "The VPC endpoint SSM security group",
      ingress_rules = local.common_egress_rules.ingress_wide_private_subnet
    }
    vpce_ssm_messages = {
      description   = "The VPC endpoint SSM Messages security group",
      ingress_rules = local.common_egress_rules.ingress_wide_private_subnet
    }
    iroco_backend = {
      description = "The IroCO backend security group",
      egress_rules = concat(
        local.common_egress_rules.vpce_logs,
        local.common_egress_rules.iroco_database,
        local.common_egress_rules.vpce_ecr,
        local.common_egress_rules.vpce_ssm,
        local.common_egress_rules.vpce_kms,
        [
          {
            description = "Allow pulling image from ECR through S3",
            prefix_list = local.prefix_list_ids.vpce_s3
          }
        ]
      )
    }
    iroco_database = {
      description = "The IroCO database security group"
      egress_rules = concat(
        local.common_egress_rules.vpce_logs,
        local.common_egress_rules.vpce_ssm
      )
    }
    bastion = {
      description  = "The bastion security group"
      egress_rules = concat(local.common_egress_rules.iroco_database, local.common_egress_rules.vpce_ssm)
    }
    alb = {
      description = "The ALB security group"
      ingress_rules = [
        {
          description = "Allow incoming communication from anywhere to ALB (HTTP)"
          port        = 80
          protocol    = "tcp"
          cidr_ipv4   = "0.0.0.0/0"
        },
        {
          description = "Allow incoming communication from anywhere to ALB (HTTPS)"
          port        = 443
          protocol    = "tcp"
          cidr_ipv4   = "0.0.0.0/0"
        }
      ]
      egress_rules = [{
        description   = "Allow communication from ALB to IroCO backend"
        port          = 8080
        protocol      = "tcp"
        referenced_sg = "iroco_backend"
      }]
    }
    vpce_kms = {
      description   = "The VPC endpoint KMS security group",
      ingress_rules = local.common_egress_rules.ingress_wide_private_subnet
    }
  }

  # Lists all ingress rules specified in security groups
  all_ingress_rules = flatten([
    for key, sg in local.security_groups : [
      for index, rule in sg.ingress_rules : {
        name : "${key}_ingress_${try(rule.referenced_sg, null) != null ? rule.referenced_sg : tostring(index)}",
        sg_name : key,
        rule : rule
      }
      if length(sg.ingress_rules) != 0
    ] if try(sg.ingress_rules, null) != null
    ]
  )

  # Lists all egress rules specified in security groups
  all_egress_rules = flatten([
    for key, sg in local.security_groups : [
      for index, rule in sg.egress_rules : {
        name : "${key}_egress_${try(rule.referenced_sg, null) != null ? rule.referenced_sg : tostring(index)}",
        sg_name : key,
        rule : rule
      }
      if try(rule.prefix_list, null) == null && length(sg.egress_rules) != 0
  ] if try(sg.egress_rules, null) != null])

  # Lists of all reversed rules to be created, this simplifies configuration by automatically allowing ingress communication on security group targeted by an egress rules
  computed_ingress_rules = flatten([
    for key, sg in local.security_groups : [
      for index, rule in sg.egress_rules : {
        name : "${rule.referenced_sg}_ingress_${key}",
        sg_name : rule.referenced_sg,
        referenced_sg : key,
        rule : rule
      }
      if try(rule.prefix_list, null) == null && try(rule.referenced_sg, null) != null
  ] if try(sg.egress_rules, null) != null])

  all_egress_prefix_list = flatten([
    for key, sg in local.security_groups : [
      for index, rule in sg.egress_rules : {
        name : "${key}_egress_${rule.prefix_list.alias}",
        prefix : rule.prefix_list.alias,
        sg_name : key,
        description : rule.description
      }
      if try(rule.prefix_list, null) != null
  ] if try(sg.egress_rules, null) != null])
}
