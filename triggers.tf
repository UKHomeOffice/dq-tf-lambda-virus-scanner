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
