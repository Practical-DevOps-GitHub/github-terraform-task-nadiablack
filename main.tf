# Configure Terraform with required providers
terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# Set environment variables for secrets (replace with your values)
variable "github_token" { }
variable "discord_webhook_url" { }  # Optional, for Discord notifications

# Configure GitHub provider with access token
provider "github" {
  token = var.github_token
}

# Define the GitHub repository resource
resource "github_repository" "my_repo" {
  name      = "your-repository-name"
  owner     = "your-github-username"

  # Collaborators
  collaborators = ["softservedata"]

  # Default branch
  default_branch = "develop"

  # Branch protection rules
  protection_rule {
    branch_name = "main"

    # Require pull request for merge
    requires_approving_reviews {
      enabled  = true
      required_approvals = 1
    }

    # Only owner can approve pull requests to main
    restrictions {
      type = "user"
      users = ["your-github-username"]
    }
  }

  protection_rule {
    branch_name = "develop"

    # Require pull request for merge
    requires_approving_reviews {
      enabled  = true
      required_approvals = 2
    }
  }

  # Code owners
  codeowners = <<EOF
    /*  @softservedata
EOF

  # Pull request template
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

# Optional: Add a deploy key (replace with your public key content)
resource "github_deploy_key" "deploy_key" {
  title       = "DEPLOY_KEY"
  public_key  = var.deploy_key_content
  repository = github_repository.my_repo.full_name
}

# Optional: Configure Discord notifications (requires webhook URL)
resource "null_resource" "discord_notification" {
  depends_on = [github_repository.my_repo]

  provisioner "local-exec" {
    when = delete

    command = <<EOF
      curl -X POST -H "Content-Type: application/json" ${var.discord_webhook_url} -d '{ "content": "New pull request created in '${github_repository.my_repo.full_name}'" }'
EOF
  }
}
