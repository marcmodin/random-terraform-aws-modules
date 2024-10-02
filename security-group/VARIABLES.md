### ingress_rules

  A list of ingress rules defined as maps.

  Allowed attributes per rule:

  - **source_security_group** = `string` _conficts with `source_cidr` and `source_self`_
  - **source_cidr** = `list(string)` _conficts with`source_security_group` and `source_self`_
  - **source_self** = `bool` _conficts with `source_security_group` and `source_cidr`_

  - **type** = `string` _can be either `custom` or a predefined type as per `allowed_rules`_
  - **protocol** = `string` _can be either `tcp`,`udp`,`-1`,`all`,`icmp` or any approved number [iana.org](https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)_
  - **from_port** = `number`
  - **to_port** = `number`
  - **description** = `string`

  Required attributes:  
  `source_security_group|source_cidr|source_self` and `protocol`,`from_port`,`to_port` when `type=custom` or `type` is not defined.

---

### ingress_rules
  A list of egress rules defined as maps.

  Allowed attributes per rule:

  - **source_security_group** = `string` _conficts with `source_cidr` and `source_self`_
  - **source_cidr** = `list(string)` _conficts with`source_security_group` and `source_self`_
  - **source_self** = `bool` _conficts with `source_security_group` and `source_cidr`_

  - **type** = `string` _can be either `custom` or a predefined type as per `allowed_rules`_
  - **protocol** = `string` _can be either `tcp`,`udp`,`-1`,`all`,`icmp` or any approved number [iana.org](https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml)_
  - **from_port** = `number`
  - **to_port** = `number`
  - **description** = `string`

  Required attributes:  
  `source_security_group|source_cidr|source_self` and `protocol`,`from_port`,`to_port` when `type=custom` or `type` is not defined.

---
