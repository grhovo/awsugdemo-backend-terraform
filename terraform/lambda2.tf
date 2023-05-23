resource "aws_lambda_function" "lambda_2_function" {
  function_name    = "${var.common_name}-lambda-1"
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  role             = aws_iam_role.lambda_2_role.arn
  vpc_config {
    subnet_ids         = [ data.aws_subnet.private_subnet_1.id, data.aws_subnet.private_subnet_2.id ]
    security_group_ids = [ aws_security_group.security_group.id ]
  }
  timeout          = 60
  memory_size      = 128
  filename         = "${path.module}/lambda_2_function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambdacode/lambda_2_function.zip")
}


resource "aws_iam_role" "lambda_2_role" {
  name = "lambda_exec"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_2_role_poliy_1" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_2_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_2_role_poliy_2" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.lambda_2_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_2_role_poliy_3" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonDynamoDBFullAccess"
  role       = aws_iam_role.lambda_2_role.name
}