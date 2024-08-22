locals {
  attribute_removed_bypass = {
    azurerm_cdn_endpoint_custom_domain = toset(
      ["user_managed_https.key_vault_certificate_id"]
    )
    azurerm_container_registry = toset([
      "retention_policy",
      "trust_policy",
      "network_rule_set.virtual_network",
    ])
  }
  auto_generated_attribute_removed     = flatten([for _, blocks in flatten([for resource_type, resource_blocks in data.resource.all.result : resource_blocks if try(local.diffs[resource_type].deleted != null, false)]) : [for b in blocks : b]])
  auto_generated_attribute_removed_map = { for block in local.auto_generated_attribute_removed : block.mptf.block_address => block }
  extra_attribute_removed = {
    azurerm_container_app = toset([
      "ingress.custom_domain",
    ])
    azurerm_container_group = toset([
      "network_profile_id",
    ])
    azurerm_hdinsight_kafka_cluster = toset([
      "roles.kafka_management_node"
    ])
    azurerm_kubernetes_fleet_manager = toset([
      "hub_profile"
    ])
  }
  extra_attribute_removed_blocks = flatten([for _, blocks in flatten([for resource_type, resource_blocks in data.resource.all.result : resource_blocks if try(local.extra_attribute_removed[resource_type] != null, false)]) : [for b in blocks : b]])
  extra_attribute_removed_map    = { for block in local.extra_attribute_removed_blocks : block.mptf.block_address => block }
}

transform "remove_block_element" auto_generated_attribute_removed {
  for_each             = var.attribute_removed_toggle ? try(local.auto_generated_attribute_removed_map, {}) : tomap({})
  target_block_address = each.key
  paths                = try(setsubtract(local.diffs[each.value.mptf.block_labels[0]].deleted, local.attribute_removed_bypass[each.value.mptf.block_labels[0]]), local.diffs[each.value.mptf.block_labels[0]].deleted)
  depends_on           = [transform.regex_replace_expression.simply_renamed]
}

transform "remove_block_element" extra_attribute_removed {
  for_each             = var.attribute_removed_toggle ? try(local.extra_attribute_removed_map, {}) : tomap({})
  target_block_address = each.key
  paths                = local.extra_attribute_removed[each.value.mptf.block_labels[0]]
  depends_on           = [transform.remove_block_element.auto_generated_attribute_removed]
}
