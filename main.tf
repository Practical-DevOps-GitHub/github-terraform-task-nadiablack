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

resource "github_branch" "develop" {
  repository    = "github-terraform-task-nadiablack"
  branch        = "develop"
  source_branch = "main"
}

resource "github_branch_default" "default" {
  repository = "github-terraform-task-nadiablack"
  branch     = "develop"
}

resource "github_branch_protection" "main_protection" {
  repository                   = "github-terraform-task-nadiablack"
  pattern                      = "main"
  enforce_admins               = true
  require_signed_commits       = false
  required_linear_history      = true
  require_conversation_resolution = true

  required_pull_request_reviews {
    required_approving_review_count = 1
    require_code_owner_reviews      = true
  }
}

resource "github_branch_protection" "develop_protection" {
  repository                   = "github-terraform-task-nadiablack"
  pattern                      = "develop"
  enforce_admins               = false
  require_signed_commits       = false
  required_linear_history      = true

  required_pull_request_reviews {
    required_approving_review_count = 2
  }
}

resource "github_repository_deploy_key" "deploy_key" {
  repository = "github-terraform-task-nadiablack"
  title      = "DEPLOY_KEY"
  key        = file("deploy_key.pub")
  read_only  = false
}

resource "github_repository_collaborator" "collaborator" {
  repository = "github-terraform-task-nadiablack"
  username   = "softservedata"
  permission = "push"
}

resource "github_repository_file" "pull_request_template" {
  repository = "github-terraform-task-nadiablack"
  file       = ".github/pull_request_template.md"
  content    = <<EOT
### Describe your changes

### Issue ticket number and link

### Checklist before requesting a review
- [ ] I have performed a self-review of my code
- [ ] If it is a core feature, I have added thorough tests
- [ ] Do we need to implement analytics?
- [ ] Will this be part of a product update? If yes, please write one phrase about this update
EOT
  branch     = "main"
}

resource "github_branch_protection_v3" "codeowners" {
  repository                   = "github-terraform-task-nadiablack"
  branch                       = "main"
  enforce_admins               = true
  dismiss_stale_reviews        = true

  required_pull_request_reviews {
    dismiss_stale_reviews        = true
    require_code_owner_reviews   = true
    required_approving_review_count = 1
  }

  push_restrictions = ["softservedata"]
}

resource "github_repository_webhook" "discord_notification" {
  repository = "github-terraform-task-nadiablack"
  events     = ["pull_request"]
  configuration {
    url          = var.discord_webhook_url
    content_type = "json"
    insecure_ssl = false
  }
}
