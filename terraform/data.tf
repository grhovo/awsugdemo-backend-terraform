data "aws_vpc" "vpc" {
  id = "vpcid"
}

data "aws_subnet" "private_subnet_1" {
  id = "subnet1id"
}

data "aws_subnet" "private_subnet_2" {
  id = "subnet2id"
}

data "archive_file" "lambda_function_1" {
  type        = "zip"
  source_dir  = "../lambda-1/main.py"
  output_path = "${path.module}/lambda_1_function.zip"
}


data "archive_file" "lambda_function_2" {
  type        = "zip"
  source_dir  = "../lambda-2/main.py"
  output_path = "${path.module}/lambda_2_function.zip"
}