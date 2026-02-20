variable "aws_region" {
  description = "AWS region for private ECR, Lambda, and SNS resources."
  type        = string
}

variable "schedule_expression" {
  description = "EventBridge schedule expression."
  type        = string
}

variable "topic_name" {
  description = "SNS topic name for scheduled results."
  type        = string
  default     = "eshgham.fifo"
}

variable "fifo_topic" {
  description = "Whether to create the SNS topic as FIFO."
  type        = bool
  default     = true
}

variable "content_based_deduplication" {
  description = "Whether FIFO SNS content-based deduplication is enabled."
  type        = bool
  default     = true
}

variable "lambda_env" {
  description = "Environment variables for the scheduled Lambda."
  type        = map(string)
  default     = {}
}

variable "eshgham_config_file" {
  description = "Path to the ESHGHAM workflows YAML file to load into ESHGHAM_WORKFLOWS_YAML."
  type        = string
  default     = ""
}

variable "github_token" {
  description = "GitHub token to set as GITHUB_TOKEN for the scheduled Lambda."
  type        = string
  default     = ""
  sensitive   = true
}

variable "lambda_timeout" {
  description = "Scheduled Lambda timeout in seconds."
  type        = number
  default     = 300
}

variable "lambda_memory_size" {
  description = "Scheduled Lambda memory size in MB."
  type        = number
  default     = 256
}

variable "lambda_name" {
  description = "Optional name for the scheduled Lambda."
  type        = string
  default     = "eshgham-scheduled-lambda"
}

variable "lambda_image_command" {
  description = "Optional override for the scheduled Lambda image command."
  type        = list(string)
  default     = null
}

variable "create_test_url" {
  description = "Whether to create a Lambda Function URL for testing."
  type        = bool
  default     = false
}

variable "lambda_public_repo_url" {
  description = "Public ECR repository URL for the ESHGHAM lambda image (e.g., public.ecr.aws/namespace/repo)."
  type        = string
  default     = "public.ecr.aws/i9p4w7k9/eshgham-lambda-dev"
}

variable "lambda_public_tag" {
  description = "Tag for the public ESHGHAM lambda image."
  type        = string
}

variable "lambda_private_repository_name" {
  description = "Optional name for the private ECR repository that stores the republished ESHGHAM image."
  type        = string
  default     = null
}

variable "lambda_enable_kms_encryption" {
  description = "Enable KMS encryption on the private ESHGHAM ECR repository."
  type        = bool
  default     = false
}

variable "lambda_kms_key_arn" {
  description = "KMS key ARN to use when lambda_enable_kms_encryption is true."
  type        = string
  default     = null
}

variable "notification_public_repo_url" {
  description = "Public ECR repository URL for the notification container image."
  type        = string
  default     = "public.ecr.aws/i9p4w7k9/cloud-cron-notifications"
}

variable "notification_public_tag" {
  description = "Public tag for the notification container image."
  type        = string
  default     = "latest"
}

variable "notification_private_repository_name" {
  description = "Optional name for the private ECR repository that stores the republished notification image."
  type        = string
  default     = null
}

variable "notification_enable_kms_encryption" {
  description = "Enable KMS encryption on the private notification ECR repository."
  type        = bool
  default     = false
}

variable "notification_kms_key_arn" {
  description = "KMS key ARN to use when notification_enable_kms_encryption is true."
  type        = string
  default     = null
}

variable "email_result_types" {
  description = "Result types to subscribe to; empty means all. Supports both base statuses (e.g. FAILED) and grouped categories (ACTION_NEEDED, WARNINGS, ALL_ABNORMAL)."
  type        = list(string)
  default     = []
}

variable "email_fifo_queue_name" {
  description = "Name for the FIFO SQS queue feeding the email notifier. Must end with .fifo."
  type        = string
  default     = ""
}

variable "email_subject_template_file" {
  description = "Path to the email subject template file."
  type        = string
  default     = ""
}

variable "email_text_template_file" {
  description = "Path to the email text template file."
  type        = string
  default     = ""
}

variable "email_html_template_file" {
  description = "Path to the email HTML template file."
  type        = string
  default     = ""
}

variable "email_sender" {
  description = "Sender email address for SES."
  type        = string
  default     = ""
}

variable "email_recipients" {
  description = "Recipient email addresses for SES."
  type        = list(string)
  default     = []
}

variable "email_reply_to" {
  description = "Optional reply-to email addresses for SES."
  type        = list(string)
  default     = []
}

variable "email_lambda_name" {
  description = "Optional name for the email notification Lambda."
  type        = string
  default     = null
}

variable "email_timeout" {
  description = "Email notifier Lambda timeout in seconds."
  type        = number
  default     = 30
}

variable "email_memory_size" {
  description = "Email notifier Lambda memory size in MB."
  type        = number
  default     = 256
}

variable "email_batch_size" {
  description = "Maximum number of records per email notifier Lambda invocation."
  type        = number
  default     = 10
}

variable "email_enabled" {
  description = "Enable the email notification event source mapping."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to created resources."
  type        = map(string)
  default     = {}
}
