
#resource "helm_release" "vault-transit" {
#  create_namespace = true
#  name        = "vault-transit"
#  namespace   = "vault-transit"
#  repository  = "oci://registry.mediaset.es/swhelm"
#  version     = "0.28.1"
#  chart       = "vault"
#}

resource "helm_release" "vault-transit" {
  depends_on = [kubernetes_namespace.vault-transit]

  name             = "vault-transit"
  namespace        = "vault-transit"
  create_namespace = true
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault"
  version          = var.vault_helm_chart_version

  values = [ file("values_vault-transit.yaml") ]

#  set {
#    name  = "global.namespace"
#    value = "vault-transit"
#    type  = "string"
#  }

}
