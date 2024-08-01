resource "kubernetes_namespace" "vault-cluster" {
  metadata {
    name = "vault-cluster"
  }
  lifecycle {
    ignore_changes = [
        metadata[0].annotations
    ]
  }
}

resource "kubernetes_secret" "wildcard-mediaset-es" {
  depends_on = [kubernetes_namespace.vault-cluster]

  metadata {
    name = "wildcard-mediaset-es"
    namespace = "vault-cluster"
  }
  data = {
    "tls.crt" = file("${path.module}/certs/tls.crt")
    "tls.key" = file("${path.module}/certs/tls.key")
  }
  type = "kubernetes.io/tls"
}

resource "kubernetes_ingress_v1" "vault-cluster" {
  metadata {
    name      = "vault-cluster"
    namespace = kubernetes_namespace.vault-cluster.metadata[0].name
    labels    = merge({ "name" = "vault-cluster-ingress" }, local.base_labels)

#    annotations = {
#      "kubernetes.io/ingress.class"                = "nginx"
#      "nginx.ingress.kubernetes.io/rewrite-target" = "/$2"
#    }
  }

  spec {
    rule {
      host = var.ingress_host

      http {
        path {
          path = ""

          backend {
            service {
              name = "vault-cluster"
              port {
                number = "8200"
              }
            }
          }
        }
      }
    }

    tls {
      hosts = ["vault-mds-pre.mediaset.es"]
      secret_name = "wildcard-mediaset-es"
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations
    ]
  }

}

locals {
  base_labels = {
    "app" = "vault-cluster"
  }
}
