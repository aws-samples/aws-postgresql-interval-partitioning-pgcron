# Automate Interval Partitioning, maintenance and monitoring in Amazon RDS for PostgreSQL and Amazon Aurora PostgreSQL

This template deploys a Lambda function that is triggered by the PostgreSQL procedure when there are failures in PostgreSQL Partition maintenance job. The Lambda function sends the notification using SNS.

Learn more about this pattern at Serverless Land Patterns: https://serverlessland.com/patterns/

Important: this application uses various AWS services and there are costs associated with these services after the Free Tier usage - please see the [AWS Pricing page](https://aws.amazon.com/pricing/) for details. You are responsible for any AWS costs incurred. No warranty is implied in this example.

## Requirements

* [Create an AWS account](https://portal.aws.amazon.com/gp/aws/developer/registration/index.html) if you do not already have one and log in. The IAM user that you use must have sufficient permissions to make necessary AWS service calls and manage AWS resources.
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) installed and configured
* [Git Installed](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
* [AWS Serverless Application Model](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html) (AWS SAM) installed

## Deployment Instructions

1. Create a new directory, navigate to that directory in a terminal and clone the GitHub repository:
    ```
	git clone https://github.com/aws-samples/aws-postgresql-interval-partitioning-pgcron.git
    ```
1. Change directory to the pattern directory:
    ```
    cd aws-postgresql-interval-partitioning-pgcron/send-cron-job-failures
    ```
1. From the command line, use AWS SAM to deploy the AWS resources for the pattern as specified in the template.yml file:
    ```
    sam deploy --guided
    ```
1. During the prompts (Sample below):
```
Stack Name [sam-app]: send-cron-job-failures
AWS Region [us-east-1]: us-west-2
Parameter pNotificationEmail [example@example.com]: notifydba@xyz.com
Parameter pVpc [vpc-xxxxxx123]: vpc-01234567890awsvpc
Parameter pPrivateSubnet1 [subnet-xxxxxx123]: subnet-01234567890abcdef
Parameter pPrivateSubnet2 [subnet-xxxxxx456]: subnet-01234567890ghijkl
#Shows you resources changes to be deployed and require a 'Y' to initiate deploy
Confirm changes before deploy [y/N]: y
#SAM needs permission to be able to create roles to connect to the resources in your template
Allow SAM CLI IAM role creation [Y/n]: Y
#Preserves the state of previously provisioned resources when an operation fails
Disable rollback [y/N]: N
Save arguments to configuration file [Y/n]: Y
SAM configuration file [samconfig.toml]:
SAM configuration environment [default]:
```

    Once you have run `sam deploy -guided` mode once and saved arguments to a configuration file (samconfig.toml), you can use `sam deploy` in future to use these defaults.

1. Note the outputs from the SAM deployment process. These contain the resource names and/or ARNs which are used for testing.

## How it works

This SAM template creates a necessary AWS Services for Lambda function to check the details on PostgreSQL cron.job_run_details table 

## Testing

After running `sam deploy`, go to the Lambda console. Find your Lambda function, and open the CloudWatch logs. You will see the new events based on the event schedule configured.

## Cleanup

1. Delete the stack
    ```bash
    aws cloudformation delete-stack --stack-name STACK_NAME
    ```
1. Confirm the stack has been deleted
    ```bash
    aws cloudformation list-stacks --query "StackSummaries[?contains(StackName,'STACK_NAME')].StackStatus"
    ```
----
Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.

SPDX-License-Identifier: MIT-0
