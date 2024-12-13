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

# Додавання колаборатора
resource "github_repository_collaborator" "collaborator" {
  repository = "github-terraform-task-nadiablack"
  username   = "softservedata"
  permission = "push"
}

# Створення гілки develop
resource "github_branch" "develop" {
  repository    = "github-terraform-task-nadiablack"
  branch        = "develop"
  source_branch = "main"
}

# Захист гілки main
resource "github_branch_protection" "main_protection" {
  repository_id = "github-terraform-task-nadiablack"
  pattern       = "main"

  required_pull_request_reviews {
    require_code_owner_reviews      = true
    required_approving_review_count = 1
  }
}

# Захист гілки develop
resource "github_branch_protection" "develop_protection" {
  repository_id = "github-terraform-task-nadiablack"
  pattern       = "develop"

  required_pull_request_reviews {
    required_approving_review_count = 2
  }
}

# Deploy Key
resource "github_repository_deploy_key" "deploy_key" {
  repository = "github-terraform-task-nadiablack"
  title      = "DEPLOY_KEY"
  key        = file("deploy_key.pub")
  read_only  = false
}
