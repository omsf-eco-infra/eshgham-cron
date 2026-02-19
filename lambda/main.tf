locals {
  lambda_source_dir = "${path.module}/docker"
  dockerfile_path   = "${local.lambda_source_dir}/Dockerfile"
}

provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}

module "lambda_image_public" {
  source = "git::https://github.com/omsf/lambdacron.git//modules/lambda-image-public"

  providers = {
    aws = aws.use1
  }

  repository_name  = var.repository_name
  image_tag         = var.image_tag
  platform          = var.platform
  short_description = var.catalog_description
  about_text        = var.catalog_about_text
  usage_text        = var.catalog_usage_text

  build_context     = local.lambda_source_dir
  dockerfile_path   = local.dockerfile_path
  build_context_paths = var.build_context_paths == null ? [local.lambda_source_dir] : var.build_context_paths
  build_context_patterns = var.build_context_patterns

  architectures     = var.catalog_architectures
  operating_systems = var.catalog_operating_systems
  tags              = var.tags
}
