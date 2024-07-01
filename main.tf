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
