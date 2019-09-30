# pylint: disable=missing-docstring, line-too-long, protected-access
import unittest
from json import loads
from runner import Runner


class TestFreightGlueSetup(unittest.TestCase):
    @classmethod
    def setUpClass(self):
        self.snippet = \
            """
            provider "aws" {
              region = "eu-west-2"
              skip_credentials_validation = true
              skip_get_ec2_platforms = true
            }
            module "virus_scanner" {
              source = "./mymodule"
              path_module = "./"
            }
            """
        self.result = Runner(self.snippet).result

    def test_root_destroy(self):
        self.assertEqual(self.result["destroy"], False)

    def test_virus_update_lambda(self):
        self.assertEqual(
            self.result['virus_scanner']['aws_lambda_function.virus_definition_lambda']['handler'],
            'update.lambda_handler'
        )
        self.assertEqual(
            self.result['virus_scanner']['aws_lambda_function.virus_definition_lambda']['runtime'],
            'python2.7'
        )
        self.assertEqual(
            self.result['virus_scanner']['aws_lambda_function.virus_definition_lambda']['filename'],
            './/lambdas/lambda.zip'
        )

    def test_virus_scan_lambda(self):
        self.assertEqual(
            self.result['virus_scanner']['aws_lambda_function.virus_scan_lambda']['handler'],
            'scan.lambda_handler'
        )
        self.assertEqual(
            self.result['virus_scanner']['aws_lambda_function.virus_scan_lambda']['runtime'],
            'python2.7'
        )
        self.assertEqual(
            self.result['virus_scanner']['aws_lambda_function.virus_scan_lambda']['filename'],
            './/lambdas/lambda.zip'
        )

    def test_cloudwatch_event_rule(self):
        self.assertEqual(
            self.result['virus_scanner']['aws_cloudwatch_event_rule.every_three_hours']['schedule_expression'],
            'rate(3 hours)'
        )

    def test_cloudwatch_event_target(self):
        self.assertEqual(
            self.result['virus_scanner']['aws_cloudwatch_event_target.update_virus_definitions']['target_id'],
            'virus_definition_lambda'
        )

    def test_lambda_cloudwatch_permissions(self):
        self.assertEqual(
            self.result['virus_scanner']['aws_lambda_permission.allow_cloudwatch_to_call_virus_definition_lambda']['function_name'],
            'bucket-antivirus-update'
        )

    def test_virus_scan_bucket_execution(self):
        self.assertEqual(
            self.result['virus_scanner']['aws_lambda_permission.allow_virus_scan_bucket_execution']['statement_id'],
            'AllowExecutionFromS3Bucket'
        )

        self.assertEqual(
            self.result['virus_scanner']['aws_lambda_permission.allow_virus_scan_bucket_execution']['action'],
            'lambda:InvokeFunction'
        )

    def test_destroy(self):
        self.assertEqual(self.result['virus_scanner']["aws_lambda_function.virus_definition_lambda"]["destroy"], False)

    def test_destroy_tainted(self):
        self.assertEqual(self.result['virus_scanner']["aws_lambda_function.virus_definition_lambda"]["destroy_tainted"], False)


if __name__ == '__main__':
    unittest.main()