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
}

variable "deploy_key_content" {
  description = "Content of the deploy key"
  type        = string
}

variable "discord_webhook_url" {
  description = "Webhook URL for Discord notifications"
  type        = string
  default     = ""
}

# Провайдер GitHub
provider "github" {
  token = var.github_token
}

# Створення репозиторію
resource "github_repository" "my_repo" {
  name           = "your-repository-name"
  owner          = "your-github-username"
  collaborators  = ["softservedata"]
  default_branch = "develop"

  # Захист гілки main
  protection_rule {
    branch_name = "main"
    requires_approving_reviews {
      enabled            = true
      required_approvals = 1
    }
    restrictions {
      type  = "user"
      users = ["your-github-username"]
    }
  }

  # Захист гілки develop
  protection_rule {
    branch_name = "develop"
    requires_approving_reviews {
      enabled            = true
      required_approvals = 2
    }
  }

  # Вказання codeowners
  codeowners = <<EOF
* @softservedata
EOF

  # Шаблон для Pull Request
  pull_request_template = <<EOF
## Describe your changes

**Issue ticket number and link:**

**Checklist before requesting a review:**

* I have performed a self-review of my code.
* If it is a core feature, I have added thorough tests.
* Do we need to implement analytics?
* Will this be part of a product update? If yes, please write one phrase about this update.
EOF
}

# Додавання deploy key
resource "github_deploy_key" "deploy_key" {
  title       = "DEPLOY_KEY"
  public_key  = var.deploy_key_content
  repository  = github_repository.my_repo.full_name
  read_only   = false
}

# Налаштування сповіщень у Discord
resource "null_resource" "discord_notification" {
  depends_on = [github_repository.my_repo]

  provisioner "local-exec" {
    when    = create
    command = <<EOF
      curl -X POST -H "Content-Type: application/json" ${var.discord_webhook_url} -d '{"content": "New pull request created in ${github_repository.my_repo.full_name}"}'
EOF
  }
}
