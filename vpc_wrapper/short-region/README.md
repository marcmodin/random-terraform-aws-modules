# Short Region Terraform Module

## Overview

The **Short Region Terraform Module** is designed to automatically detect the current AWS region and map it to a predefined shorthand version. This is useful for scenarios where a shorter or more convenient representation of the AWS region is required within your infrastructure configurations.

## Features

- **Automatic Region Detection:** Utilizes the `aws_region` data source to fetch the current AWS region.
- **Custom Mapping:** Maps full AWS region names (e.g., `eu-north-1`) to shorthand versions (e.g., `eun1`).
- **Extensible:** Easily extend the `region_map` in `main.tf` to include additional regions as needed.
- **Simple Output:** Provides the shorthand region name as an output for use in other modules or resources.

## Usage

### Example

```hcl
module "short_region" {
  source = "./path-to-your-module/short_region_module"
}

output "current_short_region" {
  value = module.short_region.short_region
}
```
