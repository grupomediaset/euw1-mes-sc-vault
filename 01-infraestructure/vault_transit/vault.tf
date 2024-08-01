resource "vault_mount" "transit" {
  path                      = "transit"
  type                      = "transit"
  description               = "Transit secret engine"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 86400
}

resource "vault_transit_secret_backend_key" "vault-cluster-auto-unseal" {
  depends_on = [vault_mount.transit]

  backend = vault_mount.transit.path
  name              = "cluster_unseal"
  deletion_allowed  = "false"
  exportable        = "true"
}

resource "vault_policy" "cluster-unseal-policy" {
  name = "cluster-unseal"
  policy = <<EOT
path "transit/encrypt/cluster_unseal" {
   capabilities = [ "update" ]
}
path "transit/decrypt/cluster_unseal" {
   capabilities = [ "update" ]
}
EOT
}