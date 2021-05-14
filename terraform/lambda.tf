terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Creates sns topic
resource "aws_sns_topic" "sns_topic" {
  name            = "sns-topic-lambda"
  delivery_policy = <<EOF
    {
      "http": {
        "defaultHealthyRetryPolicy": {
          "minDelayTarget": 20,
          "maxDelayTarget": 20,
          "numRetries": 3,
          "numMaxDelayRetries": 0,
          "numNoDelayRetries": 0,
          "numMinDelayRetries": 0,
          "backoffFunction": "linear"
        },
        "disableSubscriptionOverrides": false,
        "defaultThrottlePolicy": {
          "maxReceivesPerSecond": 1
        }
      }
    }
    EOF

  /*
  * Subscribes to the sns topic using local awscli
  * Since terraform doesn't allow creating email subscriptions
  */
  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${self.arn} --protocol email --notification-endpoint ${var.sns_subscription_email}"
  }
}


resource "aws_lambda_function" "helloworld_lambda" {
  function_name = "HelloWorldExample"

  # bucker name for the lambda artifact
  s3_bucket = var.lambda_artifact_bucket
  s3_key    = "v1.0.0/helloworld-lambda.zip"

  handler = "index.handler"
  runtime = "nodejs12.x"
  timeout = 80

  role = aws_iam_role.lambda_role.arn

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.sns_topic.arn
    }
  }

  depends_on = [
    aws_sns_topic.sns_topic,
  ]

}

# IAM role required for the lambda execution
resource "aws_iam_role" "lambda_role" {
  name = "helloworld_lambda_role"

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
      "Sid": ""
    }
  ]
}
EOF

}

resource "aws_iam_policy" "lambda_sns" {
  name        = "lambda_sns"
  path        = "/"
  description = "IAM policy allow sns access"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
          "sns:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_sns_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_sns.arn
}
