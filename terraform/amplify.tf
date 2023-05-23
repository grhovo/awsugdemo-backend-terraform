resource "aws_amplify_app" "frontend" {
  name       = "awsugdemo"
  repository = "https://github.com/grhovo/awsugdemo"

  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - npm ci
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: build
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT

}

resource "aws_amplify_branch" "branch" {
  app_id      = aws_amplify_app.frontend.id
  branch_name = "master"

  framework = "React"
  stage     = "PRODUCTION"
}