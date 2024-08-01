config_context = "k8s-pre"
vault_addr = "http://localhost:8200"

vault_helm_chart_version = "0.24.1"

autounseal_token = ""
# vault kv get -field=vault_transit_autounseal_token apps_sist/vault_k8s/staging/pre

ingress_host = "vault-mds-pre.mediaset.es"