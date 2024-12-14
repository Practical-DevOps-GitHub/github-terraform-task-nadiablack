provider "github" {
  token = var.github_token
}

# Створення нового репозиторію
resource "github_repository" "new_repo" {
  name        = var.repository_name
  description = "Repository managed by Terraform"
  visibility  = "private"
  auto_init   = true
}

# Додавання співробітника
resource "github_repository_collaborator" "collaborator" {
  repository = github_repository.new_repo.name
  username   = "softservedata"
  permission = "push"
}

# Створення гілки develop
resource "github_branch" "develop" {
  repository = github_repository.new_repo.name
  branch     = "develop"
}

# Встановлення гілки develop як дефолтної
resource "github_branch_default" "default" {
  repository = github_repository.new_repo.name
  branch     = github_branch.develop.branch
}

# Захист гілки main
resource "github_branch_protection" "main" {
  repository_id = github_repository.new_repo.node_id
  pattern       = "main"

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = true
    required_approving_review_count = 1
  }
}

# Захист гілки develop
resource "github_branch_protection" "develop" {
  repository_id = github_repository.new_repo.node_id
  pattern       = "develop"

  required_pull_request_reviews {
    dismiss_stale_reviews           = true
    require_code_owner_reviews      = false
    required_approving_review_count = 2
  }
}

# Додавання файлу CODEOWNERS
resource "github_repository_file" "codeowners" {
  repository = github_repository.new_repo.name
  file       = ".github/CODEOWNERS"
  content    = "* @softservedata"
  branch     = "main"
}

# Додавання шаблону pull request
resource "github_repository_file" "pull_request_template" {
  repository = github_repository.new_repo.name
  file       = ".github/pull_request_template.md"
  content    = <<-EOT
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

# Додавання ключа деплою
resource "github_repository_deploy_key" "deploy_key" {
  repository = github_repository.new_repo.name
  title      = "DEPLOY_KEY"
  key        = var.deploy_key_content
  read_only  = false
}

# Змінні
variable "github_token" {
  description = "GitHub Token"
  type        = string
}

variable "deploy_key_content" {
  description = "Content of the deploy key"
  type        = string
}

variable "repository_name" {
  description = "Name of the GitHub repository to create"
  type        = string
}
