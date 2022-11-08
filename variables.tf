variable "network_acl_ingress" {
  description = "List of maps of ingress rules to set on the Network ACL"
  type        = list(map(string))

  default = [
    //    {
    //      rule_no    = 50
    //      action     = "deny"
    //      protocol   = "tcp"
    //      from_port  = 80
    //      to_port    = 80
    //      cidr_block = "207.46.38.25/32"
    //    },
    {
      rule_no         = 60
      action          = "deny"
      protocol        = "tcp"
      from_port       = 80
      to_port         = 80
      ipv6_cidr_block = "2A0B:4340:580::/41"
    },
    {
      rule_no    = 900
      action     = "allow"
      from_port  = 1024
      to_port    = 65535
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 80
      to_port    = 80
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no         = 101
      action          = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    },
    {
      rule_no    = 110
      action     = "allow"
      from_port  = 443
      to_port    = 443
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no    = 120
      action     = "allow"
      from_port  = 22
      to_port    = 22
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no    = 130
      action     = "allow"
      from_port  = 3389
      to_port    = 3389
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
    }
  ]
}

variable "network_acl_egress" {
  description = "List of maps of egress rules to set on the Network ACL"
  type        = list(map(string))

  default = [
    {
      rule_no    = 900
      action     = "allow"
      from_port  = 32768
      to_port    = 65535
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no    = 100
      action     = "allow"
      from_port  = 80
      to_port    = 80
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no         = 101
      action          = "allow"
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      ipv6_cidr_block = "::/0"
    },
    {
      rule_no    = 110
      action     = "allow"
      from_port  = 443
      to_port    = 443
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no    = 120
      action     = "allow"
      from_port  = 1433
      to_port    = 1433
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no    = 130
      action     = "allow"
      from_port  = 22
      to_port    = 22
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no    = 140
      action     = "allow"
      icmp_code  = -1
      icmp_type  = 8
      protocol   = "icmp"
      cidr_block = "0.0.0.0/0"
    },
    {
      rule_no         = 150
      action          = "allow"
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      ipv6_cidr_block = "::/0"
    }
  ]
}