locals {
  computed_repositories = concat(var.repositories, [
    {
      name                            = ".github"
      description                     = "Github repository"
      visibility                      = "public"
      is_template                     = false
      dynamic_pages                   = false
      push_teams                      = ["opentofu-engineers"]
      branches                        = ["main"]
      protected_branches              = ["main"]
      required_status_checks_contexts = [] // TODO: Add required status checks
      files_target_branch             = "main"
    },
    {
      name                            = "${var.github_owner}.github.io"
      description                     = "Website repository"
      visibility                      = "public"
      is_template                     = false
      dynamic_pages                   = true
      push_teams                      = []
      branches                        = ["main"]
      protected_branches              = ["main"]
      required_status_checks_contexts = [] // TODO: Add required status checks
    },
    {
      name                            = "commons"
      description                     = "Commons library repository"
      visibility                      = "public"
      is_template                     = false
      dynamic_pages                   = false
      push_teams                      = ["java-engineers", "github-ci-engineers", "protobuf-engineers"]
      branches                        = ["main", "develop"]
      protected_branches              = ["main", "develop"]
      required_status_checks_contexts = ["build"]
    },
    {
      name                            = "java-service-template"
      description                     = "Java service base template repository"
      visibility                      = "public"
      is_template                     = true
      dynamic_pages                   = false
      push_teams                      = ["java-engineers", "github-ci-engineers", "protobuf-engineers"]
      branches                        = ["main", "develop"]
      protected_branches              = ["main", "develop"]
      required_status_checks_contexts = ["build"]
    }
  ])
}

resource "github_repository" "repo" {
  for_each = {
    for repo in local.computed_repositories :
    repo.name => repo
  }

  name                   = each.value.name
  description            = each.value.description
  visibility             = each.value.visibility
  has_issues             = true
  has_wiki               = false
  has_projects           = false
  has_downloads          = false
  archive_on_destroy     = true
  is_template            = each.value.is_template
  allow_merge_commit     = false
  allow_squash_merge     = true
  allow_rebase_merge     = false
  allow_auto_merge       = false
  delete_branch_on_merge = true
  auto_init              = true # INFO: Mandatory for adding a license file later
  vulnerability_alerts   = true

  dynamic "pages" {
    for_each = each.value.dynamic_pages ? [1] : []

    content {
      source {
        branch = "main"
        path   = "/"
      }
    }
  }
}
