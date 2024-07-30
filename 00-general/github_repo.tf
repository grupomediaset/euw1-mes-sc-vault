resource "github_repository" "this" {
  name        = var.name
  description = coalesce(var.description, var.name)
  has_downloads               = true
  has_issues                  = true
  has_projects                = true
  has_wiki                    = true
  vulnerability_alerts        = true
}
