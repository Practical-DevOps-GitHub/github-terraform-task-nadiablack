terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# Оголошення змінних
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

variable "discord_webhook_url" {
  description = "Discord Webhook URL for notifications"
  type        = string
  default     = ""
}

# Налаштування провайдера GitHub
provider "github" {
  token = var.github_token
}

# Створення репозиторію
resource "github_repository" "my_repo" {
  name           = "github-terraform-task-nadiablack"
  description    = "Repository managed by Terraform"
  private        = true
  has_issues     = true
  has_projects   = true
  has_wiki       = true
  auto_init      = true
  default_branch = "develop"
}

# Додавання співпрацівника
resource "github_repository_collaborator" "collaborator" {
  repository = github_repository.my_repo.name
  username   = "softservedata"
  permission = "push"
}

# Захист гілки main
resource "github_branch_protection_v3" "main" {
  repository     = github_repository.my_repo.name
  branch         = "main"
  enforce_admins = true

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    required_approving_review_count = 1
  }

  required_status_checks {
    strict   = true
    contexts = []
  }

  restrictions {
    users = ["nadiablack"]
    teams = []
  }
}

# Захист гілки develop
resource "github_branch_protection_v3" "develop" {
  repository     = github_repository.my_repo.name
  branch         = "develop"
  enforce_admins = true

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = false
    required_approving_review_count = 2
  }

  required_status_checks {
    strict   = true
    contexts = []
  }

  restrictions {
    users = []
    teams = []
  }
}

# Файл CODEOWNERS
resource "github_repository_file" "codeowners" {
  repository = github_repository.my_repo.name
  file       = ".github/CODEOWNERS"
  content    = "* @softservedata"
  branch     = "main"
}

# Шаблон для Pull Request
resource "github_repository_file" "pull_request_template" {
  repository = github_repository.my_repo.name
  file       = ".github/pull_request_template.md"
  content = <<EOF
## Describe your changes

**Issue ticket number and link:**

**Checklist before requesting a review:**

* I have performed a self-review of my code.
* If it is a core feature, I have added thorough tests.
* Do we need to implement analytics?
* Will this be part of a product update? If yes, please write one phrase about this update.
EOF
  branch = "main"
}

# Додавання deploy key
resource "github_deploy_key" "deploy_key" {
  title      = "DEPLOY_KEY"
  public_key = var.deploy_key_c
