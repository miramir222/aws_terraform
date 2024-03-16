#provider "aws" {
#  region = "ap-south-1"
#  secret_key = "6C73MfKENWogXF1tzlxbGDW7KrK8ZOJFiflepYlA"
#  access_key = "AKIAQ6Q3DI64YBAWG55C"
#}
#
#resource "aws_iam_role" "lambda_role" {
# name   = "terraform_aws_lambda_role"
# assume_role_policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Action": "sts:AssumeRole",
#      "Principal": {
#        "Service": "lambda.amazonaws.com"
#      },
#      "Effect": "Allow",
#      "Sid": ""
#    }
#  ]
#}
#EOF
#}
#
## IAM policy for logging from a lambda
#
#resource "aws_iam_policy" "iam_policy_for_lambda" {
#
#  name         = "aws_iam_policy_for_terraform_aws_lambda_role"
#  path         = "/"
#  description  = "AWS IAM Policy for managing aws lambda role"
#  policy = <<EOF
#{
#  "Version": "2012-10-17",
#  "Statement": [
#    {
#      "Action": [
#        "logs:CreateLogGroup",
#        "logs:CreateLogStream",
#        "logs:PutLogEvents"
#      ],
#      "Resource": "arn:aws:logs:*:*:*",
#      "Effect": "Allow"
#    }
#  ]
#}
#EOF
#}
#
## Policy Attachment on the role.
#
#resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
#  role        = aws_iam_role.lambda_role.name
#  policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
#}
#
## Generates an archive from content, a file, or a directory of files.
#
#data "archive_file" "zip_the_python_code" {
# type        = "zip"
# source_dir  = "${path.module}/lambda/"
# output_path = "${path.module}/lambda/lambda.zip"
#}
#
## Create a lambda function
## In terraform ${path.module} is the current directory.
#resource "aws_lambda_function" "terraform_lambda_func" {
# filename                       = "${path.module}/lambda/lambda.zip"
# function_name                  = "Lambda-Function"
# role                           = aws_iam_role.lambda_role.arn
# handler                        = "lambda.lambda_handler"
# runtime                        = "python3.9"
# depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
#}
#
#
#output "teraform_aws_role_output" {
# value = aws_iam_role.lambda_role.name
#}
#
#output "teraform_aws_role_arn_output" {
# value = aws_iam_role.lambda_role.arn
#}
#
#output "teraform_logging_arn_output" {
# value = aws_iam_policy.iam_policy_for_lambda.arn
#}

provider "aws" {
  region     = "ap-south-1"
  secret_key = "6C73MfKENWogXF1tzlxbGDW7KrK8ZOJFiflepYlA"
  access_key = "AKIAQ6Q3DI64YBAWG55C"
}

data "archive_file" "zip_the_python_code" {
 type        = "zip"
 source_dir  = "${path.module}/lambda_handler"
 output_path = "${path.module}/lambda_handler/lambda_function.zip"
}

resource "aws_lambda_function" "ec2_stop_lambda" {
  filename      = "${path.module}/lambda_handler/lambda_function.zip"
  function_name = "EC2StopLambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  timeout       = 60
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "lambda_policy_attachment" {
  name       = "lambda-policy-attachment"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#resource "aws_cloudwatch_event_rule" "lambda_schedule" {
#  name                = "RunOncePerDay"
#  schedule_expression = "cron(0 0 * * ? *)"
##  schedule_expression = "rate(5 minutes)"
#}
#
#resource "aws_cloudwatch_event_target" "lambda_target" {
#  rule      = aws_cloudwatch_event_rule.lambda_schedule.name
#  target_id = "RunLambdaOncePerDay"
#  arn       = aws_lambda_function.ec2_stop_lambda.arn
#}
