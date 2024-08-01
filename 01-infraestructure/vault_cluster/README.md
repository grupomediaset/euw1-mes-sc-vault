# VAULT CLUSTER
## Description
This module creates a VAULT CLUSTER wiht transit engine Autounseal.

## Usage
```
module "vault_transit" {
  source = "github.com/ibm-garage-cloud/terraform-tools-vault-transit.git?ref=v1.0.0"

  vault_addr = var.vault_addr
  vault_token = var.vault_token
  vault_transit_key
}
```

## Variables
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| vault_addr | The address of the Vault server | string | | yes |
| vault_token | The token to authenticate with Vault | string

## Outputs
| Name | Description |
|------|-------------|

## Known issues
- None

## Limitations
- None

## Deployment
```bash
tfa -var "autounseal_token=$(vault kv get -field=vault_transit_autounseal_token apps_sist/vault_k8s/staging/pre)"
```

## Configure
### Get all the resources in the namespace
```bash
kubectl get all --namespace vault-cluster
```
### Generate the keys (When PODS running)
```bash
k get pods -n vault-cluster
NAME              READY   STATUS    RESTARTS   AGE
vault-cluster-0   0/1     Running   0          81s
vault-cluster-1   0/1     Running   0          81s
vault-cluster-2   0/1     Running   0          81s

kubectl exec -it -n vault-cluster vault-cluster-0 -- vault operator init
vault kv get -field=vault_cluster_mds_pre_keys apps_sist/vault_k8s/staging/pre |jq -r '.'
vault kv get -field=vault_cluster_mds_pre_keys apps_sist/vault_k8s/staging/pre |jq -r '.recovery_keys[]'
```
### Save the keys in Vault
```bash
vault kv get -field=vault_cluster_mds_pre_keys apps_sist/vault_k8s/staging/pre
vault kv get -field=vault_cluster_mds_pre_keys apps_sist/vault_k8s/staging/pre > vault-cluster-mds_pre-keys.json
```

### Unseal vault-cluster-0
```bash
kubectl exec -n vault-cluster vault-cluster-0 -- vault operator unseal $(vault kv get -field=mds_pre_keys apps_sist/vault_k8s/staging/pre |jq -r '.unseal_keys_b64[0]')
kubectl exec -n vault-cluster vault-cluster-0 -- vault operator unseal $(vault kv get -field=mds_pre_keys apps_sist/vault_k8s/staging/pre |jq -r '.unseal_keys_b64[1]')
k get pods -n vault-cluster
NAME              READY   STATUS    RESTARTS   AGE
vault-cluster-0   1/1     Running   0          41m
vault-cluster-1   0/1     Running   0          41m
vault-cluster-2   0/1     Running   0          41m
```
### JOIN and Unseal vault-cluster-1
```bash
kubectl exec -ti -n vault-cluster vault-cluster-1 -- vault operator raft join http://vault-cluster-0.vault-cluster-internal:8200
Key       Value
---       -----
Joined    true
k get pods -n vault-cluster
NAME              READY   STATUS    RESTARTS   AGE
vault-cluster-0   1/1     Running   0          41m
vault-cluster-1   1/1     Running   0          41m
vault-cluster-2   0/1     Running   0          41m
```
### JOIN and Unseal vault-cluster-2
```bash
kubectl exec -ti -n vault-cluster vault-cluster-2 -- vault operator raft join http://vault-cluster-0.vault-cluster-internal:8200
Key       Value
---       -----
Joined    true
k get pods -n vault-cluster
NAME              READY   STATUS    RESTARTS   AGE
vault-cluster-0   1/1     Running   0          41m
vault-cluster-1   1/1     Running   0          41m
vault-cluster-2   1/1     Running   0          41m
```
### Test Vault cluster Service
```bash
kubectl port-forward -n vault-cluster svc/vault-cluster 8200:8200
vault kv get -field=mds_pre_keys apps_sist/vault_k8s/staging/pre |jq -r '.root_token'
http://localhost:8200/ui/vault/auth?with=token
```
![Alt text](images/vault_transit.png?raw=true "Vault Transit")



### Test Vault cluster Command Line
```bash
export VAULT_TOKEN=$(vault kv get -field=vault_cluster_mds_pre_keys apps_sist/vault_k8s/staging/pre |jq -r '.initial_root_token')
export VAULT_ADDR="http://localhost:8200"
vault status
Key                      Value
---                      -----
Recovery Seal Type       shamir
Initialized              true
Sealed                   false
Total Recovery Shares    5
Threshold                3
Version                  1.13.1
Build Date               2023-03-23T12:51:35Z
Storage Type             raft
Cluster Name             vault-cluster
Cluster ID               ef50dce6-5480-814f-0ac3-572a7348c897
HA Enabled               true
HA Cluster               https://vault-cluster-0.vault-cluster-internal:8201
HA Mode                  active
Active Since             2024-07-31T07:09:58.601485196Z
Raft Committed Index     43
Raft Applied Index       43
```



```bash
k get secrets -n mediaset wildcard-mediaset-es -o json |jq -r '.data."tls.crt"' |base64 --decode > tls.crt
k get secrets -n mediaset wildcard-mediaset-es -o json |jq -r '.data."tls.key"' |base64 --decode > tls.key
kubectl create secret tls wildcard-mediaset-es -n vault-cluster --key tls.key --cert tls.crt
secret/wildcard-mediaset-es created
```
vault kv get -field=key sistemascorp/generic/wildcard.mediaset.es > tls.key
vault kv get -field=chain sistemascorp/generic/wildcard.mediaset.es > tls.crt
vault kv get -field=certificate sistemascorp/generic/wildcard.mediaset.es >> tls.crt
kubectl create secret tls wildcard-mediaset-es -n vault-cluster --key tls.key --cert tls.crt








### Get
```bash
kubectl
```

