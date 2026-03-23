locals {
  required_github_actions_secrets = {
    TF_VAR_gh_token     = var.gh_token
    AWS_DEPLOY_ROLE_ARN = module.workflow_oidc_role.role_arn
  }
  default_permission_sets = toset([])

  required_permission_sets = toset([
    "lambda-image-republish",
    "email-notification",
    "print-notification",
    "root",
  ])
  permission_sets = setunion(
    local.required_permission_sets,
    local.default_permission_sets,
    var.extra_permission_sets
  )
  github_repository_parts  = split("/", var.github_repository)
  github_repository_name   = local.github_repository_parts[1]
  github_subjects          = ["repo:${var.github_repository}:ref:${var.github_ref}"]
  github_job_workflow_refs = ["${var.github_repository}/.github/workflows/${var.github_workflow_filename}@${var.github_ref}"]
  managed_github_actions_secrets = merge(
    var.github_actions_secrets,
    local.required_github_actions_secrets
  )
  managed_github_actions_secret_keys = toset(keys(nonsensitive(local.managed_github_actions_secrets)))
  github_oidc_provider_arn = coalesce(
    var.github_oidc_provider_arn,
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
  )
}

data "aws_caller_identity" "current" {}

data "github_repository" "provider_context" {
  name = local.github_repository_name
}

check "github_provider_owner_matches_repository_owner" {
  assert {
    condition     = data.github_repository.provider_context.full_name == var.github_repository
    error_message = "GitHub provider owner mismatch: expected \"${var.github_repository}\" from repository name \"${local.github_repository_name}\", but provider resolved \"${data.github_repository.provider_context.full_name}\". Configure provider \"github\" with owner = \"${local.github_repository_parts[0]}\"."
  }
}

module "workflow_oidc_role" {
  source = "git::https://github.com/omsf/lambdacron.git//modules/github-deployer-role"

  role_name                      = var.role_name
  role_description               = var.role_description
  max_session_duration           = var.max_session_duration
  github_oidc_provider_arn       = local.github_oidc_provider_arn
  github_audience                = var.github_audience
  github_subjects                = local.github_subjects
  github_job_workflow_refs       = local.github_job_workflow_refs
  permission_sets                = local.permission_sets
  allowed_resource_name_prefixes = var.allowed_resource_name_prefixes
  additional_policy_arns         = var.additional_policy_arns
  tags                           = var.tags
}

resource "github_actions_secret" "managed" {
  for_each = local.managed_github_actions_secret_keys

  repository      = local.github_repository_name
  secret_name     = each.value
  plaintext_value = local.managed_github_actions_secrets[each.value]
}
