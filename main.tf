terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

variable "github_token" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

variable "deploy_key_content" {
  description = "Content of the deploy key"
  type        = string
  sensitive   = true
}

variable "repository_name" {
  description = "Name of the existing GitHub repository"
  type        = string
}

provider "github" {
  token = var.github_token
}

data "github_repository" "existing_repo" {
  name = var.repository_name
}

resource "github_branch" "main" {
  repository = data.github_repository.existing_repo.name
  branch     = "main"
}

resource "github_repository_collaborator" "collaborator" {
  repository = data.github_repository.existing_repo.name
  username   = "softservedata"
  permission = "push"
}

resource "github_repository_file" "codeowners" {
  depends_on = [github_branch.main]
  repository = data.github_repository.existing_repo.name
  file       = ".github/CODEOWNERS"
  content    = "* @softservedata"
  branch     = "main"
}

resource "github_repository_file" "pull_request_template" {
  depends_on = [github_branch.main]
  repository = data.github_repository.existing_repo.name
  file       = ".github/pull_request_template.md"
  content = <<-EOT
    ## Describe your changes

    **Issue ticket number and link:**

    **Checklist before requesting a review:**

    * I have performed a self-review of my code.
    * If it is a core feature, I have added thorough tests.
    * Do we need to implement analytics?
    * Will this be part of a product update? If yes, please write one phrase about this update.
  EOT
  branch = "main"
}

resource "github_repository_deploy_key" "deploy_key" {
  repository = data.github_repository.existing_repo.name
  title      = "DEPLOY_KEY"
  key        = var.deploy_key_content
  read_only  = false
}
