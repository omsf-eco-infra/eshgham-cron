variable "repository_name" {
  description = "Name for the public ECR repository."
  type        = string
}

variable "image_tag" {
  description = "Tag to apply to the built image. Pin this to a release-specific value."
  type        = string
}

variable "platform" {
  description = "Target platform for the build (e.g., linux/amd64)."
  type        = string
  default     = "linux/amd64"
}

variable "tags" {
  description = "Tags to apply to created resources."
  type        = map(string)
  default     = {}
}

variable "catalog_description" {
  description = "Short description shown in the ECR Public gallery."
  type        = string
  default     = ""
}

variable "catalog_about_text" {
  description = "About text shown in the ECR Public gallery."
  type        = string
  default     = ""
}

variable "catalog_usage_text" {
  description = "Usage text shown in the ECR Public gallery."
  type        = string
  default     = ""
}

variable "build_context_paths" {
  description = "Optional list of paths to hash for detecting build context changes."
  type        = list(string)
  default     = null
}

variable "build_context_patterns" {
  description = "Glob patterns to include when hashing build context for rebuilds."
  type        = list(string)
  default     = [
    "Dockerfile",
    "requirements.txt",
    "lambda_handler.py",
  ]
}

variable "catalog_architectures" {
  description = "Supported CPU architectures for the public catalog."
  type        = list(string)
  default     = ["x86-64"]
}

variable "catalog_operating_systems" {
  description = "Supported OSes for the public catalog."
  type        = list(string)
  default     = ["Linux"]
}
