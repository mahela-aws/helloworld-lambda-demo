# helloworld-lambda-demo
Basic lambda function deployment using terraform

## Prerequisites

- AWS account with local credentials configure `~/.aws/credentials`
- aws cli installed and configured on your local environment.
- Terraform 0.14.7+ installed on your local workstation.

## Create and push lambda artifact to an s3 bucket

Follow below steps to create a lambda artifact and push it to an s3 bucket

- Parameters required
  - `s3 bucket name` - this should be a globally unique s3 bucket name - default(helloworld-lambda-example-32431)

- Run below command to create an s3 bucket and push lambda artifact to it
  - `sh upload-artifact.sh`

This s3 bucket name will be required when deploying lambda function in the next step.


## Deploy lambda function to aws using terraform

Follow below steps to deploy lambda function to aws

- Parameters required
  - `S3 bucket name for lambda artifact`(this bucket is created in above step)
  - `Email address sns topic subscription`(this email address will be subscribe to sns topic created)

- Move to terraform directory and initialize terraform
  - `cd terraform`
  - `terraform init`
- Run terraform plan to have glance at what resources will be created
  - `terraform plan`
- Run terraform apply to deploy lambda function to aws
  - `terraform apply`


#### Note
All aws resources will be created in us-east-1 region
