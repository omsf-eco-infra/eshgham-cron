output "role_arn" {
  description = "ARN of the GitHub deployer role."
  value       = module.workflow_oidc_role.role_arn
}

output "role_name" {
  description = "Name of the GitHub deployer role."
  value       = module.workflow_oidc_role.role_name
}

output "selected_permission_sets" {
  description = "Permission sets attached to this role."
  value       = module.workflow_oidc_role.selected_permission_sets
}

output "permission_set_policy_arns" {
  description = "Managed policy ARNs generated for selected permission sets."
  value       = module.workflow_oidc_role.permission_set_policy_arns
}

output "available_permission_sets" {
  description = "All permission sets available from the source module."
  value       = module.workflow_oidc_role.available_permission_sets
}
