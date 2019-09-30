resource "aws_iam_role" "virus_scan_role" {
  name = "bucket-antivirus-function"

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

resource "aws_iam_role_policy" "virus_scan_policy" {
  name = "virus-scan-policy"
  role = "${aws_iam_role.virus_scan_role.id}"

  policy = <<EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
         ],
         "Resource":"*"
      },
      {
         "Action":[
            "s3:GetObject",
            "s3:GetObjectTagging",
            "s3:PutObjectTagging",
            "s3:PutObjectVersionTagging",
         ],
         "Effect":"Allow",
         "Resource": [
           "arn:aws:s3:::${var.virus_scan_bucket}-${var.namespace}/*",
         ]
      },
      {
         "Action":[
            "s3:GetObject",
            "s3:GetObjectTagging",
         ],
         "Effect":"Allow",
         "Resource": [
           "arn:aws:s3:::${var.virus_definition_bucket}-${var.namespace}/*"
         ]
      },
      {
         "Action":[
            "kms:Decrypt",
         ],
         "Effect":"Allow",
         "Resource": [
           "arn:aws:s3:::${var.virus_scan_bucket}-${var.namespace}/*",
         ]
      }
   ]
}
EOF
}

resource "aws_lambda_function" "virus_scan_lambda" {
 filename         = "${local.path_module}/lambdas/lambda.zip"
 function_name    = "bucket-antivirus-function"
 role             = "${aws_iam_role.virus_scan_role.arn}"
 handler          = "scan.lambda_handler"
 source_code_hash = "${base64sha256("lambdas/lambda.zip")}"
 runtime          = "python2.7"
 timeout          = "300"
 memory_size      = "1024"

 environment {
   variables = {
     AV_DEFINITION_S3_BUCKET = "${var.virus_definition_bucket}-${var.namespace}"
   }
 }
}

resource "aws_cloudwatch_log_group" "virus_scan_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.virus_scan_lambda.function_name}"
  retention_in_days = 90 
}

resource "aws_iam_policy" "virus_scan_policy" {
  name        = "virus-scan-logging"
  path        = "/"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "${aws_cloudwatch_log_group.virus_scan_log_group.arn}",
        "${aws_cloudwatch_log_group.virus_scan_log_group.arn}/*"
      ],
      "Effect": "Allow"
    }
  ]
}
EOF
}
