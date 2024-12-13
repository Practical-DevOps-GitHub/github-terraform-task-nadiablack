terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "github" {
  token = var.github_token
}

resource "github_repository" "repo" {
  name        = "github-terraform-task-nadiablack"
  description = "Repository for Terraform task"
  visibility  = "private"
}

resource "github_branch" "develop" {
  repository    = github_repository.repo.name
  branch        = "develop"
  source_branch = "main"
}

resource "github_branch_default" "default" {
  repository = github_repository.repo.name
  branch     = github_branch.develop.branch
}

resource "github_branch_protection" "main_protection" {
  repository    = github_repository.repo.name
  pattern       = "main"
  enforce_admins = true

  required_pull_request_reviews {
    required_approving_review_count = 1
    require_code_owner_reviews      = true
  }

  require_signed_commits          = false
  require_conversation_resolution = true
}

resource "github_branch_protection" "develop_protection" {
  repository    = github_repository.repo.name
  pattern       = "develop"

  required_pull_request_reviews {
    required_approving_review_count = 2
  }

  require_signed_commits          = false
  require_conversation_resolution = true
}

resource "github_repository_collaborator" "collaborator" {
  repository = github_repository.repo.name
  username   = "softservedata"
  permission = "push"
}

resource "github_repository_file" "pull_request_template" {
  repository = github_repository.repo.name
  file       = ".github/pull_request_template.md"
  content    = <<EOT
Describe your changes

Issue ticket number and link

Checklist before requesting a review

- [ ] I have performed a self-review of my code
- [ ] If it is a core feature, I have added thorough tests
- [ ] Do we need to implement analytics?
- [ ] Will this be part of a product update? If yes, please write one phrase about this update
EOT
}

resource "github_repository_deploy_key" "deploy_key" {
  repository = github_repository.repo.name
  title      = "DEPLOY_KEY"
  key        = file("deploy_key.pub")
  read_only  = false
}
