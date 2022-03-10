resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": "01"
    }
  ]
}
EOF
}

resource "aws_lambda_function" "CKV_AWS_45_50_116_117_115" {
  filename      = "lambda_function_payload.zip"
  function_name = "lambda_function_name"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "exports.test"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("lambda_function_payload.zip")

  runtime = "nodejs12.x"

  # CKV_AWS_115: "Ensure that AWS Lambda function is configured for function-level concurrent execution limit"
  # reserved_concurrent_executions = 0

  # CKV_AWS_50: "X-ray tracing is enabled for Lambda"
  # tracing_config {
  #  mode = "Active"
  #}

  # CKV_AWS_117: "Ensure that AWS Lambda function is configured inside a VPC"
  #vpc_config {
  #  subnet_ids         = "subnet-0f6f3318eee0c7151"
  #  security_group_ids = "sg-004269bd838ea4e42"
  #}

  # CKV_AWS_116: "Ensure that AWS Lambda function is configured for a Dead Letter Queue(DLQ)"
  # dead_letter_config {
  #  target_arn = aws_sqs_queue.dlq.arn
  #}

  environment {
    variables = {
      # CKV_AWS_45: "Ensure no hard-coded secrets exist in lambda environment"
      AWS_ACCOUNT = "AKIAWVESX6LB7TC3U7WK"
    }
  }
}

resource "aws_sqs_queue" "dlq" {
  name                      = "terraform-example-queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  # redrive_policy = jsonencode({
  #  deadLetterTargetArn = aws_sqs_queue.terraform_queue_deadletter.arn
  #  maxReceiveCount     = 4
  #})

  # CKV_AWS_27: "Ensure all data stored in the SQS queue is encrypted"
  kms_master_key_id                 = "alias/aws/sqs"
  kms_data_key_reuse_period_seconds = 300

  tags = {
    Environment = "production"
  }
}
