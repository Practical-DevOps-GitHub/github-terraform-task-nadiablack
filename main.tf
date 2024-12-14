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

# Провайдер GitHub
provider "github" {
  token = var.github_token
}

# Створення репозиторію
resource "github_repository" "my_repo" {
  name           = "your-repository-name"
  owner          = "your-github-username"
  default_branch = "develop"
  collaborators  = ["softservedata"]

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
