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

    def test_iam_role(self):
        policy_dict = loads(self.result['freight_glue']['aws_iam_role.glue']['assume_role_policy'])
        self.assertEqual(policy_dict['Statement'][0]['Effect'], 'Allow')
        self.assertEqual(policy_dict['Statement'][0]['Principal']['Service'], 'glue.amazonaws.com')

    def test_iam_role_policy_attachment(self):
        self.assertEqual(self.result['freight_glue']['aws_iam_role_policy_attachment.glue_service']['policy_arn'], 'arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole')

    def test_aws_iam_role_policy(self):
        policy_dict = loads(self.result['freight_glue']['aws_iam_role_policy.s3_policy_bucket']['policy'])
        self.assertEqual(policy_dict['Version'], '2012-10-17')
        self.assertEqual(policy_dict['Statement'][0]['Effect'], 'Allow')
        self.assertEqual(policy_dict['Statement'][0]['Resource'], ['arn:aws:s3:::s3-dq-freight-archive-test/*'])

    def test_destroy(self):
        self.assertEqual(self.result['freight_glue']["aws_glue_crawler.fast_parcel_crawler"]["destroy"], False)

    def test_destroy_tainted(self):
        self.assertEqual(self.result['freight_glue']["aws_glue_crawler.fast_parcel_crawler"]["destroy_tainted"], False)


if __name__ == '__main__':
    unittest.main()