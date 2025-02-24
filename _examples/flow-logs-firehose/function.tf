###############################################
# Lambda Authorizer
###############################################

locals {
  function_name = format("%s-ocsf-transform", var.name_prefix)
}

# ################################################
# # Layer that supports requirements.txt install #
# ###############################################
# module "requirements_layer" {
#   source          = "terraform-aws-modules/lambda/aws"
#   version         = "7.20.0"
#   create_function = false
#   create_layer    = false

#   layer_name          = format("%s-requirements", var.name_prefix)
#   compatible_runtimes = ["python3.10"]
#   runtime             = "python3.10" # required to force layers to do pip install
#   # architectures       = ["arm64"]
#   source_path = [
#     {
#       path             = "${path.module}/function/src"
#       pip_requirements = true
#       prefix_in_zip    = "python" # required to get the path correct
#     }
#   ]
# }

module "lambda" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = local.function_name
  create_function = true

  handler       = "main.lambda_handler"
  runtime       = "python3.11"
  # architectures = ["arm64"]
  timeout       = 60
  memory_size   =  512

  build_in_docker = true
  artifacts_dir   = "${path.root}/builds"
  source_path = [{
    path = "${path.module}/function/src"
    pip_requirements = false
  }]

  layers = [
    # format("arn:aws:lambda:%s:336392948345:layer:AWSDataWrangler-Python39:1", var.region),
    # format("arn:aws:lambda:%s:336392948345:layer:AWSSDKPandas-Python312-Arm64:15", var.region),
    # format("arn:aws:lambda:%s:336392948345:layer:AWSSDKPandas-Python310:5", var.region),
    # format("arn:aws:lambda:%s:017000801446:layer:AWSLambdaPowertoolsPythonV2-Arm64:64", var.region),
    # format("arn:aws:lambda:%s:017000801446:layer:AWSLambdaPowertoolsPythonV3-python310-x86_64:3", var.region),
    # module.requirements_layer.lambda_layer_arn,
    format("arn:aws:lambda:%s:336392948345:layer:AWSSDKPandas-Python311:19", var.region),
    # format("arn:aws:lambda:%s:017000801446:layer:AWSLambdaPowertoolsPythonV3-python311-x86_64:3", var.region)
  ]

  environment_variables = {
    SEC_LAKE_BUCKET = module.logs_bucket.bucket_id
    DEBUG       = true
  }
  # Permissions
  role_name = "${local.function_name}-role"

  # Logs 
  cloudwatch_logs_retention_in_days = 1
  cloudwatch_logs_log_group_class   = "STANDARD"

  # AWS SAM 
  create_sam_metadata = true
}

# #################################
# # Lambda Version Aliasing
# #################################


# locals {
#   apigateway_execute_arn = "${aws_api_gateway_rest_api.default.execution_arn}/*"
# }

# # development should always point to the latest function version
# module "alias_refresh" {
#   source  = "terraform-aws-modules/lambda/aws//modules/alias"
#   version = ">= 4.7"

#   refresh_alias = true
#   name          = "dev"

#   function_name                   = module.lambda_function.lambda_function_name
#   function_version                = module.lambda_function.lambda_function_version
#   create_version_allowed_triggers = false
#   allowed_triggers = {
#     Development = {
#       service    = "apigateway"
#       source_arn = "${aws_api_gateway_rest_api.default.execution_arn}/*/POST/{proxy+}"
#     }
#   }

# }

# # production must point to a defined function version
# module "alias_norefresh" {
#   source  = "terraform-aws-modules/lambda/aws//modules/alias"
#   version = ">= 4.7"

#   refresh_alias = true
#   name          = local.environment

#   function_name                   = module.lambda_function.lambda_function_name
#   function_version                = local.function_live_version
#   create_version_allowed_triggers = false
#   allowed_triggers = {
#     Production = {
#       service    = "apigateway"
#       source_arn = local.apigateway_execute_arn
#     }
#   }
# }