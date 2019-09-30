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

    def test_lambda_function(self):
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

    def test_destroy(self):
        self.assertEqual(self.result['virus_scanner']["aws_lambda_function.virus_definition_lambda"]["destroy"], False)

    def test_destroy_tainted(self):
        self.assertEqual(self.result['virus_scanner']["aws_lambda_function.virus_definition_lambda"]["destroy_tainted"], False)


if __name__ == '__main__':
    unittest.main()