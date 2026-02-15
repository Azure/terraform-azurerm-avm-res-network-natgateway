# TODO: insert locals here.
locals {
  role_definition_resource_substring = "providers/Microsoft.Authorization/roleDefinitions"
  subscription_id                    = element(split("/", var.parent_id), 2)
}
