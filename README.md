# dq-tf-lambda-virus-scanner

This repo deploys a [lambda based clamav virus scanning solution](https://github.com/upsidetravel/bucket-antivirus-function) to an AWS account using terraform.

This repo deploys two lambdas:

`virus_definitions_update_lambda.tf` Is set to trigger every 3 hours which pulls the latest virus definitions to a specified bucket.

`virus_scan_lambda.tf` Is triggered from S3 object creation and scans the file

## Settings

Settings are stored in `variables.tf`

| Variable                      | Description                                                                     | Default |
|-------------------------------|---------------------------------------------------------------------------------|---------|
| delete_infected_files         | Determines whether infected files should be automatically deleted or not        | True    |
| process_original_version_only | Determines whether only original file should be scanned if versioning is enabled| False   |

If `delete_infected_files` is set to `False`, infected files will not automatically be deleted. Instead they will be given an `INFECTED` tag.
