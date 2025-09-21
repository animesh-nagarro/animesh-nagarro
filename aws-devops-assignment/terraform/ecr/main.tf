resource "aws_ecr_repository" "web" {
  name                 = "demo-web"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.common_tags
}

resource "aws_ecr_repository" "api" {
  name                 = "demo-api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.common_tags
}