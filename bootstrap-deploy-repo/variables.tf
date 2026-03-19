variable "role_name" {
  description = "Name for the GitHub deployer IAM role."
  type        = string
  default     = "eshgham-cron-github-deployer"
}

variable "role_description" {
  description = "Description for the GitHub deployer IAM role."
  type        = string
  default     = "Role assumed by GitHub Actions to deploy ESHGHAM-cron modules."
}

variable "max_session_duration" {
  description = "Maximum assumed-role session duration in seconds."
  type        = number
  default     = 3600

  validation {
    condition     = var.max_session_duration >= 3600 && var.max_session_duration <= 43200
    error_message = "max_session_duration must be between 3600 and 43200 seconds."
  }
}

variable "github_oidc_provider_arn" {
  description = "ARN for the IAM OIDC provider backing token.actions.githubusercontent.com."
  type        = string
  default     = null
  nullable    = true
}

variable "github_repository" {
  description = "GitHub repository in owner/repo form used for OIDC claims and Actions secret management."
  type        = string

  validation {
    condition     = can(regex("^[^/]+/[^/]+$", var.github_repository))
    error_message = "github_repository must be in owner/repo format."
  }
}

variable "github_ref" {
  description = "Git ref that may assume the deploy role (for example refs/heads/main)."
  type        = string
  default     = "refs/heads/main"

  validation {
    condition     = startswith(var.github_ref, "refs/")
    error_message = "github_ref must start with refs/."
  }
}

variable "github_workflow_filename" {
  description = "Workflow filename under .github/workflows/ that may assume the deploy role."
  type        = string
  default     = "deploy.yaml"

  validation {
    condition     = !strcontains(var.github_workflow_filename, "/")
    error_message = "github_workflow_filename must be a file name, not a path."
  }
}

variable "github_audience" {
  description = "OIDC audience expected in GitHub-issued tokens."
  type        = string
  default     = "sts.amazonaws.com"
}

variable "gh_token" {
  description = "GitHub token for ESHGHAM runs. Stored as TF_VAR_gh_token in GitHub Actions secrets."
  type        = string
  sensitive   = true
}

variable "github_actions_secrets" {
  description = "Sensitive map of additional GitHub Actions secrets to create, keyed by secret name."
  type        = map(string)
  sensitive   = true
  default     = {}
}

variable "extra_permission_sets" {
  description = "Optional extra permission sets to union with required ESHGHAM permission sets."
  type        = set(string)
  default     = []
}

variable "allowed_resource_name_prefixes" {
  description = "Allowed resource-name prefixes for deployer-managed infrastructure resources."
  type        = set(string)
  default     = ["eshgham"]
}

variable "additional_policy_arns" {
  description = "Additional pre-existing managed policy ARNs to attach to the role."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to created IAM resources."
  type        = map(string)
  default     = {}
}
