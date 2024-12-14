terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

variable "github_token" { }

provider "github" {
  token = var.github_token
}

resource "github_repository" "my_repo" {
  name      = "your-repository-name"
  owner     = "your-github-username"

   collaborators = ["softservedata"]

   default_branch = "develop"

   protection_rule {
    branch_name = "main"

      requires_approving_reviews {
      enabled  = true
      required_approvals = 1
    }

    restrictions {
      type = "user"
      users = ["your-github-username"]
    }
  }

  protection_rule {
    branch_name = "develop"

  
    requires_approving_reviews {
      enabled  = true
      required_approvals = 2
    }
  }

 
  codeowners = <<EOF
    /*  @softservedata
EOF

 
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
