resource "aws_ecr_repository" "backend_repos" {
  for_each             = var.ecs_services
  name                 = "${var.project_name}-${each.key}-repo"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }


  tags = {
    Name = "${var.project_name}-${each.key}-repo"
  }
}

# Create a lifecycle policy resource for the repositories

resource "aws_ecr_lifecycle_policy" "backend_repo_policy" {
  for_each   = aws_ecr_repository.backend_repos
  repository = each.value.name

  policy = <<POLICY
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 10 images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
POLICY
}