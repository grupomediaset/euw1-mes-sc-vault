variable "name" {
  type    = string
  default = "euw1-mes-sc-vault"
}

variable "short_name" {
  type    = string
  default = "vault_k8s"
}

variable "description" {
  type    = string
  default = "Vault global repository"
}

variable "vault_paths" {
  type = list(string)
  default = [
    "staging/dev",
    "staging/int",
    "staging/pre",
    "common",
    "pro",
  ]
}