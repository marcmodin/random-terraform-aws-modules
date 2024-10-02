variable "vpc_id" {
  description = "VPC where the Security Group is created"
  type        = string
}

variable "name" {
  description = "Security Group Name"
  type        = string
}

variable "description" {
  description = "Security Group Description"
  type        = string
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Security Group tags in addition to tag:Name, which is automatically derived from `var.name`"
  default     = {}
}

variable "ingress_rules" {
  type        = any
  description = "A list of ingress rules defined as maps. More info below"
  default     = []
}

variable "egress_rules" {
  type        = any
  description = "A list of egress rules defined as maps. More info below"
  default     = []
}

variable "allowed_rules" {
  type        = map(any)
  description = "Approved rules by type (valid format is 'name' = ['from port', 'to port', 'protocol', 'description']). Used when type `custom` or type attribute is not defined in `var.ingress_rules` or `var.egress_rules`"
  default = {
    ""          = [0, 0, -1, ""] # this rule is only for safeguard against missing values
    all         = [0, 65535, -1, "ALL"]
    all_tcp     = [0, 65535, "tcp", "ALL TCP"]
    all_udp     = [0, 65535, "udp", "ALL UDP"]
    dns         = [53, 53, "udp", "DNS"]
    dns_tcp     = [53, 53, "tcp", "DNS TCP"]
    icmp_all    = [-1, -1, "icmp", "PING"]
    http        = [80, 80, "tcp", "HTTP"]
    http_8080   = [8080, 8080, "tcp", "HTTP 8080"]
    https       = [443, 443, "tcp", "HTTPS"]
    ldap        = [389, 389, "tcp", "LDAP"]
    mysql       = [3306, 3306, "tcp", "MySQL/Aurora"]
    mssql       = [1433, 1433, "tcp", "MSSQL Server"]
    postgres    = [5432, 5432, "tcp", "PostgreSQL"]
    redshift    = [5439, 5439, "tcp", "Redshift"]
    oracle      = [1521, 1521, "tcp", "Oracle-RDS"]
    efs         = [2049, 2049, "tcp", "NFS/EFS"]
    ssh         = [22, 22, "tcp", "SSH"]
    rdp         = [3389, 3389, "tcp", "RDP"]
    winrm_http  = [5985, 5985, "tcp", "WinRm-HTTP"]
    winrm_https = [5986, 5986, "tcp", "WinRm-HTTPS"]
    smtp        = [25, 25, "tcp", "SMPT"]
    pop3        = [110, 110, "tcp", "POP3"]
    imap        = [143, 143, "tcp", "IMAP"]
  }
}
