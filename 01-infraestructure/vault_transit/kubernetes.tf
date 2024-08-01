resource "kubernetes_namespace" "vault-transit" {
  metadata {
    name = "vault-transit"
  }
  lifecycle {
    ignore_changes = [
        metadata[0].annotations
    ]
  }
}

resource "kubernetes_secret" "wildcard-mediaset-es" {
  depends_on = [kubernetes_namespace.vault-transit]

  metadata {
    name = "wildcard-mediaset-es"
    namespace = "vault-transit"
  }

  data = {
    "tls.crt" = "${path.module}/certs/tls.crt"
    "tls.key" = "${path.module}/certs/tls.key"
  }
  type = "kubernetes.io/tls"
}