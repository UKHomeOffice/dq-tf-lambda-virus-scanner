resource "aws_cloudwatch_event_rule" "every_three_hours" {
    name = "every-three-hours"
    schedule_expression = "rate(3 hours)"
}

resource "aws_cloudwatch_event_target" "update_virus_definitions" {
    rule = "${aws_cloudwatch_event_rule.every_three_hours.name}"
    target_id = "virus_definition_lambda"
    arn = "${aws_lambda_function.virus_definition_lambda.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_virus_definition_lambda" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.virus_definition_lambda.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.every_three_hours.arn}"
}

resource "aws_lambda_permission" "allow_virus_scan_bucket_execution" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.virus_scan_lambda.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.virus_scan_bucket}-${var.namespace}"
}

resource "aws_s3_bucket_notification" "virus_scan_lambda_notifications" {
  bucket = "${var.freight_bucket}-${var.namespace}"

  lambda_function {
      lambda_function_arn = "${aws_lambda_function.virus_scan_lambda.arn}"
      events              = ["s3:ObjectCreated:*"]
  }
}
