# VAULT TRANSIT
## Description
This module creates a transit engine in Vault. The transit engine is used to encrypt/decrypt data without storing it in Vault. The data is encrypted/decrypted in memory and the encryption key is stored in Vault.

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
terraform apply --target='module.vault_transit'
```

## Configure
### Get all the resources in the namespace
```bash
kubectl get all --namespace vault-transit
```
### Generate the keys (When PODS running)
```bash
k get pods -n vault-transit
NAME              READY   STATUS    RESTARTS   AGE
vault-transit-0   0/1     Running   0          81s
vault-transit-1   0/1     Running   0          81s
vault-transit-2   0/1     Running   0          81s

kubectl exec -n vault-transit vault-transit-0 -- vault operator init \
    -key-shares=5 \
    -key-threshold=2 \
    -format=json > vault-transit-mds_pre-keys.json
jq . vault-transit-mds_pre-keys.json
jq -r ".unseal_keys_b64[]" vault-transit-mds_pre-keys.json
```
### Save the keys in Vault
```bash
vault kv patch apps_sist/vault_k8s/staging/pre vault_transit_mds_pre_keys=$(cat vault-transit-mds_pre-keys.json) # NO Funciona
vault kv get -field=vault_transit_mds_pre_keys apps_sist/vault_k8s/staging/pre
vault kv get -field=vault_transit_mds_pre_keys apps_sist/vault_k8s/staging/pre > vault-transit-mds_pre-keys.json
```

### Unseal vault-transit-0
```bash
kubectl exec -n vault-transit vault-transit-0 -- vault operator unseal $(vault kv get -field=mds_pre_keys apps_sist/vault_k8s/staging/pre |jq -r '.unseal_keys_b64[0]')
kubectl exec -n vault-transit vault-transit-0 -- vault operator unseal $(vault kv get -field=mds_pre_keys apps_sist/vault_k8s/staging/pre |jq -r '.unseal_keys_b64[1]')
k get pods -n vault-transit
NAME              READY   STATUS    RESTARTS   AGE
vault-transit-0   1/1     Running   0          41m
vault-transit-1   0/1     Running   0          41m
vault-transit-2   0/1     Running   0          41m
```
### JOIN and Unseal vault-transit-1
```bash
kubectl exec -ti -n vault-transit vault-transit-1 -- vault operator raft join http://vault-transit-0.vault-transit-internal:8200
Key       Value
---       -----
Joined    true
kubectl exec -n vault-transit vault-transit-1 -- vault operator unseal $(vault kv get -field=mds_pre_keys apps_sist/vault_k8s/staging/pre |jq -r '.unseal_keys_b64[0]')
kubectl exec -n vault-transit vault-transit-1 -- vault operator unseal $(vault kv get -field=mds_pre_keys apps_sist/vault_k8s/staging/pre |jq -r '.unseal_keys_b64[1]')
k get pods -n vault-transit
NAME              READY   STATUS    RESTARTS   AGE
vault-transit-0   1/1     Running   0          41m
vault-transit-1   1/1     Running   0          41m
vault-transit-2   0/1     Running   0          41m
```
### JOIN and Unseal vault-transit-2
```bash
kubectl exec -ti -n vault-transit vault-transit-2 -- vault operator raft join http://vault-transit-0.vault-transit-internal:8200
Key       Value
---       -----
Joined    true
kubectl exec -n vault-transit vault-transit-2 -- vault operator unseal $(vault kv get -field=mds_pre_keys apps_sist/vault_k8s/staging/pre |jq -r '.unseal_keys_b64[0]')
kubectl exec -n vault-transit vault-transit-2 -- vault operator unseal $(vault kv get -field=mds_pre_keys apps_sist/vault_k8s/staging/pre |jq -r '.unseal_keys_b64[1]')
k get pods -n vault-transit
NAME              READY   STATUS    RESTARTS   AGE
vault-transit-0   1/1     Running   0          41m
vault-transit-1   1/1     Running   0          41m
vault-transit-2   1/1     Running   0          41m
```
### Test Vault Transit Service
```bash
kubectl port-forward -n vault-transit svc/vault-transit 8200:8200
vault kv get -field=mds_pre_keys apps_sist/vault_k8s/staging/pre |jq -r '.root_token'
http://localhost:8200/ui/vault/auth?with=token
```
![Alt text](images/vault_transit.png?raw=true "Vault Transit")

```bash
k get secrets -n mediaset wildcard-mediaset-es -o json |jq -r '.data."tls.crt"' |base64 --decode > tls.crt
k get secrets -n mediaset wildcard-mediaset-es -o json |jq -r '.data."tls.key"' |base64 --decode > tls.key
kubectl create secret tls wildcard-mediaset-es -n vault-transit --key tls.key --cert tls.crt
secret/wildcard-mediaset-es created
```
vault kv get -field=key sistemascorp/generic/wildcard.mediaset.es > tls.key
vault kv get -field=chain sistemascorp/generic/wildcard.mediaset.es > tls.crt
vault kv get -field=certificate sistemascorp/generic/wildcard.mediaset.es >> tls.crt
kubectl create secret tls wildcard-mediaset-es -n vault-transit --key tls.key --cert tls.crt

### Create an autounseal transit key
```bash
tfa --target={vault_mount.transit,vault_transit_secret_backend_key.vault-cluster-auto-unseal}
```

### Create a policy for autounseal key
```bash
tfa --target={vault_policy.cluster-unseal-policy}
```

### Create a orphan token for autounseal
```bash
vault token create -orphan -policy=cluster-unseal -period=24h
VAULT_TOKEN="" vault token create -orphan -policy=cluster-unseal -period=24h -address=http://localhost:8200
Key                  Value
---                  -----
token                
token_accessor       YPRmU8VZP1QTdUKXVL2mLJOt
token_duration       24h
token_renewable      true
token_policies       ["cluster-unseal" "default"]
identity_policies    []
policies             ["cluster-unseal" "default"]
```








### Get
```bash
kubectl
```

