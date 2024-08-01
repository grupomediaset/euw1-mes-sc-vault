
#resource "helm_release" "vault-cluster" {
#  create_namespace = true
#  name        = "vault-cluster"
#  namespace   = "vault-cluster"
#  repository  = "oci://registry.mediaset.es/swhelm"
#  version     = "0.28.1"
#  chart       = "vault"
#}

resource "helm_release" "vault-cluster" {
  depends_on = [kubernetes_namespace.vault-cluster]

  name             = "vault-cluster"
  namespace        = "vault-cluster"
  create_namespace = true
  repository       = "https://helm.releases.hashicorp.com"
  chart            = "vault"
  version          = var.vault_helm_chart_version

  values = [ templatefile("${path.root}/values_vault-cluster.yaml", { TOKEN_AUTOUNSEAL = var.autounseal_token }) ]

#  set {
#    name  = "global.namespace"
#    value = "vault-cluster"
#    type  = "string"
#  }

}
