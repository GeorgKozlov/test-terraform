terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }
  }
}

variable "aws_account_id" {
  default = 156061538191
}

provider "docker" {
  registry_auth {
    address  = "${var.aws_account_id}.dkr.ecr.${data.aws_ecr_authorization_token.token.id}.amazonaws.com"
    password = data.aws_ecr_authorization_token.token.password
    username = data.aws_ecr_authorization_token.token.user_name
  }
}

resource "aws_ecr_repository" "lambda_image" {
  name = "lambda-image"
}

resource "docker_registry_image" "lambda_image" {
  name = "${aws_ecr_repository.lambda_image.repository_url}:latest"

  build {
    context      = "${path.cwd}/app"
    force_remove = true
  }
}

resource "aws_iam_role" "role" {
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "custom_role" {
  role = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "hello_world_lambda" {
  function_name = "hello-world"
  role          = aws_iam_role.role.arn
  image_uri     = "${aws_ecr_repository.lambda_image.repository_url}:latest"
  package_type  = "Image"
  architectures = [ "arm64" ]

  depends_on = [
    docker_registry_image.lambda_image
  ]
}

resource "aws_lambda_function_url" "url" {
  authorization_type = "NONE"
  function_name      = aws_lambda_function.hello_world_lambda.function_name
}
