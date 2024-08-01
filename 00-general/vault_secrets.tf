resource "vault_generic_secret" "initial_path_secrets" {
  for_each = toset(var.vault_paths)

  path = "apps_sist/${var.short_name}/${each.value}"
  disable_read = true
  data_json = jsonencode({
    init_key  = "valor-0"
  })
}
