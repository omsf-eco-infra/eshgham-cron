# bootstrap-deploy-repo

Reusable deployment-bootstrap module for ESHGHAM repositories.

This module creates the GitHub OIDC deploy role and manages required GitHub Actions secrets:

- `AWS_DEPLOY_ROLE_ARN`
- `TF_VAR_gh_token`

Extension inputs are available for reuse in other roots:

- `extra_permission_sets`
- `additional_policy_arns`
- `allowed_resource_name_prefixes`
- `github_actions_secrets`

Backend S3 + DynamoDB policy attachment and backend secrets (`TF_STATE_BUCKET`, `TF_STATE_TABLE`) are intentionally not part of this module. Add them in a backend-specific module at the calling root.

Deployer permissions are prefix-scoped; default `allowed_resource_name_prefixes = ["eshgham"]`. Add additional prefixes when your deployment manages resources outside the default naming family.

Useful defaults in this module:

- `role_name = "eshgham-cron-deployer"`
- `github_ref = "refs/heads/main"`
- `github_workflow_filename = "deploy.yaml"`
- `github_oidc_provider_arn = null` (auto-resolves to the current account OIDC provider ARN)
