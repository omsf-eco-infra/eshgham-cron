locals {
  tags = merge({ managed_by = "eshgham-cron" }, var.tags)
  enable_email_notification = length(var.email_recipients) > 0
  eshgham_env = length(var.eshgham_config_file) > 0 ? {
    ESHGHAM_WORKFLOWS_YAML = file(var.eshgham_config_file)
  } : {}
  github_env = length(var.github_token) > 0 ? {
    GITHUB_TOKEN = var.github_token
  } : {}
  lambda_env = merge(var.lambda_env, local.eshgham_env, local.github_env)
}

check "email_notification_inputs" {
  assert {
    condition = (
      !local.enable_email_notification
      || (
        length(var.email_fifo_queue_name) > 0
        && length(var.email_subject_template_file) > 0
        && length(var.email_text_template_file) > 0
        && length(var.email_html_template_file) > 0
        && length(var.email_sender) > 0
      )
    )
    error_message = "When email_recipients is non-empty, email_fifo_queue_name, email_subject_template_file, email_text_template_file, email_html_template_file, and email_sender must be set."
  }
}

provider "aws" {
  region = var.aws_region
}

module "lambda_image_republish" {
  source = "../cloud-cron/modules/lambda-image-republish"

  source_lambda_repo = var.lambda_public_repo_url
  source_lambda_tag  = var.lambda_public_tag

  destination_repository_name = var.lambda_private_repository_name
  enable_kms_encryption       = var.lambda_enable_kms_encryption
  kms_key_arn                 = var.lambda_kms_key_arn

  tags = local.tags
}

module "notification_image_republish" {
  source = "../cloud-cron/modules/lambda-image-republish"

  source_lambda_repo = var.notification_public_repo_url
  source_lambda_tag  = var.notification_public_tag

  destination_repository_name = var.notification_private_repository_name
  enable_kms_encryption       = var.notification_enable_kms_encryption
  kms_key_arn                 = var.notification_kms_key_arn

  tags = local.tags
}

module "cloud_cron" {
  source = "../cloud-cron"

  aws_region        = var.aws_region
  lambda_image_uri    = module.lambda_image_republish.lambda_image_uri
  schedule_expression = var.schedule_expression
  topic_name          = var.topic_name
  fifo_topic          = var.fifo_topic
  content_based_deduplication = var.content_based_deduplication

  lambda_env    = local.lambda_env
  timeout       = var.lambda_timeout
  memory_size   = var.lambda_memory_size
  lambda_name   = var.lambda_name
  image_command = var.lambda_image_command
  create_test_url = var.create_test_url

  tags = local.tags
}

module "email_notification" {
  count  = local.enable_email_notification ? 1 : 0
  source = "../cloud-cron/modules/email-notification"

  sns_topic_arn     = module.cloud_cron.sns_topic_arn
  result_types      = var.email_result_types
  fifo_queue_name   = var.email_fifo_queue_name
  lambda_image_uri  = module.notification_image_republish.lambda_image_uri
  lambda_name       = var.email_lambda_name

  subject_template_file = var.email_subject_template_file
  text_template_file    = var.email_text_template_file
  html_template_file    = var.email_html_template_file
  sender                = var.email_sender
  recipients            = var.email_recipients
  reply_to              = var.email_reply_to

  timeout     = var.email_timeout
  memory_size = var.email_memory_size
  batch_size  = var.email_batch_size
  enabled     = var.email_enabled

  tags = local.tags
}
