output "lambda_republished_image_uri" {
  description = "Private ECR image URI for the republished ESHGHAM lambda image."
  value       = module.lambda_image_republish.lambda_image_uri_with_digest
}

output "notification_republished_image_uri" {
  description = "Private ECR image URI with digest for the republished notification image (null when notification_image_uri_override is used)."
  value       = local.use_notification_image_override ? null : module.notification_image_republish[0].lambda_image_uri_with_digest
}

output "notification_image_uri" {
  description = "Notification image URI used by notification lambdas (republished image with digest or notification_image_uri_override)."
  value       = local.notification_lambda_image_uri
}

output "sns_topic_arn" {
  description = "ARN of the shared SNS topic."
  value       = module.cloud_cron.sns_topic_arn
}

output "scheduled_lambda_arn" {
  description = "ARN of the scheduled Lambda."
  value       = module.cloud_cron.scheduled_lambda_arn
}

output "scheduled_lambda_test_url" {
  description = "Lambda Function URL for on-demand test invokes (null if disabled)."
  value       = module.cloud_cron.scheduled_lambda_test_url
}
