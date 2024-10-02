# Security Group Module

A module that creates a simple vpc security group with predefined ports as verbs. This repository uses [pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform) to run validation, security and automatic docs checks before pushing new changes.

### Example

  ```hcl
  # Get your assigned vpc
  data "aws_vpcs" "vpc" {}

  data "aws_vpc" "vpc" {
    id = tolist(data.aws_vpcs.vpc.ids)[0]
  }

  module "security-group" {
    source = "./"
    vpc_id = data.aws_vpc.vpc.id
    name   = "test-example-sg"

    ingress_rules = [
      {
        type        = "https"
        source_cidr = [data.aws_vpc.vpc.cidr_block]
      },
      {
        type        = "icmp_all"
        source_cidr = [data.aws_vpc.vpc.cidr_block]
      }
    ]

    egress_rules = [
      {
        type        = "all"
        source_cidr = ["0.0.0.0/0"]
      }
    ]
  }

  ```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_rules"></a> [allowed\_rules](#input\_allowed\_rules) | Approved rules by type (valid format is 'name' = ['from port', 'to port', 'protocol', 'description']). Used when type `custom` or type attribute is not defined in `var.ingress_rules` or `var.egress_rules` | `map(any)` | <pre>{<br>  "": [<br>    0,<br>    0,<br>    -1,<br>    ""<br>  ],<br>  "all": [<br>    0,<br>    65535,<br>    -1,<br>    "ALL"<br>  ],<br>  "all_tcp": [<br>    0,<br>    65535,<br>    "tcp",<br>    "ALL TCP"<br>  ],<br>  "all_udp": [<br>    0,<br>    65535,<br>    "udp",<br>    "ALL UDP"<br>  ],<br>  "dns": [<br>    53,<br>    53,<br>    "udp",<br>    "DNS"<br>  ],<br>  "dns_tcp": [<br>    53,<br>    53,<br>    "tcp",<br>    "DNS TCP"<br>  ],<br>  "efs": [<br>    2049,<br>    2049,<br>    "tcp",<br>    "NFS/EFS"<br>  ],<br>  "http": [<br>    80,<br>    80,<br>    "tcp",<br>    "HTTP"<br>  ],<br>  "http_8080": [<br>    8080,<br>    8080,<br>    "tcp",<br>    "HTTP 8080"<br>  ],<br>  "https": [<br>    443,<br>    443,<br>    "tcp",<br>    "HTTPS"<br>  ],<br>  "icmp_all": [<br>    -1,<br>    -1,<br>    "icmp",<br>    "PING"<br>  ],<br>  "imap": [<br>    143,<br>    143,<br>    "tcp",<br>    "IMAP"<br>  ],<br>  "ldap": [<br>    389,<br>    389,<br>    "tcp",<br>    "LDAP"<br>  ],<br>  "mssql": [<br>    1433,<br>    1433,<br>    "tcp",<br>    "MSSQL Server"<br>  ],<br>  "mysql": [<br>    3306,<br>    3306,<br>    "tcp",<br>    "MySQL/Aurora"<br>  ],<br>  "oracle": [<br>    1521,<br>    1521,<br>    "tcp",<br>    "Oracle-RDS"<br>  ],<br>  "pop3": [<br>    110,<br>    110,<br>    "tcp",<br>    "POP3"<br>  ],<br>  "postgres": [<br>    5432,<br>    5432,<br>    "tcp",<br>    "PostgreSQL"<br>  ],<br>  "rdp": [<br>    3389,<br>    3389,<br>    "tcp",<br>    "RDP"<br>  ],<br>  "redshift": [<br>    5439,<br>    5439,<br>    "tcp",<br>    "Redshift"<br>  ],<br>  "smtp": [<br>    25,<br>    25,<br>    "tcp",<br>    "SMPT"<br>  ],<br>  "ssh": [<br>    22,<br>    22,<br>    "tcp",<br>    "SSH"<br>  ],<br>  "winrm_http": [<br>    5985,<br>    5985,<br>    "tcp",<br>    "WinRm-HTTP"<br>  ],<br>  "winrm_https": [<br>    5986,<br>    5986,<br>    "tcp",<br>    "WinRm-HTTPS"<br>  ]<br>}</pre> | no |
| <a name="input_description"></a> [description](#input\_description) | Security Group Description | `string` | `null` | no |
| <a name="input_egress_rules"></a> [egress\_rules](#input\_egress\_rules) | A list of egress rules defined as maps. More info below | `any` | `[]` | no |
| <a name="input_ingress_rules"></a> [ingress\_rules](#input\_ingress\_rules) | A list of ingress rules defined as maps. More info below | `any` | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Security Group Name | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Security Group tags in addition to tag:Name, which is automatically derived from `var.name` | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC where the Security Group is created | `string` | n/a | yes |

### ingress\_rules

  A list of ingress rules defined as maps.

  Allowed attributes per rule:

- **source\_security\_group** = `string` \_conficts with `source_cidr` and `source_self`\_
- **source\_cidr** = `list(string)` \_conficts with`source_security_group` and `source_self`\_
- **source\_self** = `bool` \_conficts with `source_security_group` and `source_cidr`\_

- **type** = `string` \_can be either `custom` or a predefined type as per `allowed_rules`\_
- **protocol** = `string` \_can be either `tcp`,`udp`,`-1`,`all`,`icmp` or any approved number [iana.org](https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)\_
- **from\_port** = `number`
- **to\_port** = `number`
- **description** = `string`

  Required attributes:  
  `source_security_group|source_cidr|source_self` and `protocol`,`from_port`,`to_port` when `type=custom` or `type` is not defined.

---

### ingress\_rules

  A list of egress rules defined as maps.

  Allowed attributes per rule:

- **source\_security\_group** = `string` \_conficts with `source_cidr` and `source_self`\_
- **source\_cidr** = `list(string)` \_conficts with`source_security_group` and `source_self`\_
- **source\_self** = `bool` \_conficts with `source_security_group` and `source_cidr`\_

- **type** = `string` \_can be either `custom` or a predefined type as per `allowed_rules`\_
- **protocol** = `string` \_can be either `tcp`,`udp`,`-1`,`all`,`icmp` or any approved number [iana.org](https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)\_
- **from\_port** = `number`
- **to\_port** = `number`
- **description** = `string`

  Required attributes:  
  `source_security_group|source_cidr|source_self` and `protocol`,`from_port`,`to_port` when `type=custom` or `type` is not defined.

---

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | outputs the security group id |
| <a name="output_name"></a> [name](#output\_name) | outputs the security group name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
