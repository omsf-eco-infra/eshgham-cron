output "image_uri" {
  description = "URI of the built Lambda image."
  value       = module.lambda_image_public.image_uri
}

output "repository_arn" {
  description = "ARN of the created ECR repository."
  value       = module.lambda_image_public.repository_arn
}

output "repository_url" {
  description = "URL of the created ECR repository."
  value       = module.lambda_image_public.repository_uri
}
