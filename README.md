# How to use Terragrunt to manage multiple environments in AWS

## Introduction

Infrastructure as code (IAC) is the practice of managing and provisioning infrastructure using code rather than manual processes. This approach enables teams to manage infrastructure more efficiently, consistently, and reliably. Terragrunt is an open-source tool that helps teams manage infrastructure as code in AWS. In this article, we'll show you how to use Terragrunt with Github Packages and Github Actions to manage multiple environments in AWS.

## Build and Push Terragrunt Image on Github Packages

Before we can use Terragrunt with Github Actions, we need to build and push a Terragrunt image to Github Packages. Github Packages is a package hosting service that allows you to publish and share packages with other developers. To build the Terragrunt image, we'll use a Dockerfile that installs the necessary dependencies and packages. Once the image is built, we'll push it to Github Packages so that we can use it in our Github Actions workflow.

```bash
export GH_USERNAME=antocapp
docker buildx build --platform=linux/amd64 -t ghcr.io/$GH_USERNAME/terraform -f ./Dockerfile --build-arg TERRAFORM_VERSION=1.1.6 .
```

```bash
docker push ghcr.io/antocapp/terraform
```

You will find the image under the `packages` page of you GitHub Account:

![Packages](./static-images/packages.png?raw=true)

In order for your repository to download this image during the run of the GitHub Actions, you need to give permissions to your repository.


![Packages Repo Permissions](./static-images/packages-access.png?raw=true)

## Create a Staging Organization Account on AWS

To demonstrate how to use Terragrunt to manage infrastructure in AWS, we'll create a staging environment in a separate AWS account. We'll use Terragrunt to define the resources both for staging and production account. Depending on the environment, we can define what we may want to use in staging or environment (i.e. we want to have in production a scheduled trigger for the lambda every day at midnight, while not in staging.)

For this reason, we have in `infrastructure/components/cloudwatch.tf` the following line:

```go
count = var.environment == "prod" ? 1 : 0
```

In your organization, create a new account called `staging`. You should see something like this in the organization page:

![Organization accounts](./static-images/org-accounts.png?raw=true)

Please keep in mind the staging account id (the number right below the staging account), as it will be needed in the repository secrets for the Github Actions to run.

## Add AWS credentials as Actions Secrets

In order to let Terragrunt deploy on production and staging (by assuming the staging role), you need to generate the credentials for a user in the IAM page. Once you have these credentials, you have to store them in the repository Actions Secrets at this url: `https://github.com/{USERNAME}/{REPO}/settings/secrets/actions`.

The variables needed to be stored are the following:

- `AWS_ACCESS_KEY_ID` : The access key id downloaded during the user creation in IAM.
- `AWS_REGION` : The regione you want your infrastructure to be deployed. I'll use `eu-west-1` (Ireland).
- `AWS_SECRET_ACCESS_KEY` : The secret access key downloaded during the user creation in IAM.
- `AWS_STAGING_ACCOUNT_ID` : The staging account id, which you can find in the organization page.

![Actions Secrets](./static-images/secrets.png?raw=true)

## Write the CI/CD Pipeline on Github Actions

With the Terragrunt image available on Github Packages, we can now write the Github Actions workflow that will manage our infrastructure code. The workflow should include steps for checking out the code from our repository, building the Terragrunt image, configuring the AWS CLI with our access credentials, running Terragrunt to apply our infrastructure changes, and cleaning up any unused resources. We'll also use Github Actions to trigger the workflow based on events like code pushes.

Github actions workflow should be put in the `.github/workflows/` path, and in this demo you will find `main.yml` and `staging.yml` files.

The only difference between these two files (besides the deployment in different environment and the consequent difference in some variables to be inferred, like the environment itself) is the `TERRAGRUNT_IAM_ROLE` variable, defined only in the staging workflow (it's used by terragrun to assume that role), and it's defined as follows:

```bash
TERRAGRUNT_IAM_ROLE: arn:aws:iam::${{ secrets.AWS_STAGING_ACCOUNT_ID }}:role/OrganizationAccountAccessRole
```

## Overview on Terragrunt Code

To manage infrastructure as code with Terragrunt, we'll need to write code that defines our AWS resources. We can use Terragrunt code to define any resource in AWS, like EC2 instances, RDS instances, and S3 buckets. Terragrunt also supports modules, which allow us to organize and reuse infrastructure code across different projects. In addition, Terragrunt supports dependency management, which means we can define dependencies between infrastructure resources and ensure they are created in the correct order.

For the purpose of this demo, the infrastructure overall contains an S3 bucket (to store the Lambda code), the Lambda Function, and a Cloudwatch Event Rule to trigger the Lambda every day at midnight (but this is only present in staging).

The `infrastructure` folder contains a `components` folder and an `environments` folder.

```txt
infrastructure
├── components
│   ├── cloudwatch.tf   # containes event rule
│   ├── iam.tf          # contains Lambda policy
│   ├── lambda.tf       # contains Lambda definition
│   ├── main.tf         # init Terraform
│   ├── s3.tf           # containse S3 bucket definition
│   └── vars.tf         # contains variables to be used or inherited from environments variables
└── environments
    ├── prod
    │   └── terragrunt.hcl
    ├── staging
    │   └── terragrunt.hcl
    └── terragrunt.hcl
```

`prod` and `staging` folders have their own set of variables, which can vary since you may want to have different computational capacity across the environments. Components are shared across the environments, but if you do not need a component, you can set a `count` value for that component (as it is done in the `cloudwatch.tf` file):

```go
count = var.environment == "prod" ? 1 : 0
```

This will create a component only if the environment is `prod`.

## Run Example (Scheduler + Lambda in Prod, Only Lambda in Staging)

Finally, we'll run an example that demonstrates how to use Terragrunt to manage infrastructure in both the staging and production accounts. We'll define a Lambda function and a scheduled event in the production account, and a Lambda function in the staging account. We'll use Terragrunt to apply the infrastructure changes to each account and verify that the resources are created as expected.

Github Actions are triggered in our case by just pushing to `staging` or `main` branches. Let's start with `staging`.

## Conclusion

In this article, we've shown you how to use Terragrunt with Github Packages and Github Actions to manage infrastructure in AWS. We've covered the basics of building and pushing a Terragrunt image, writing a Github Actions workflow, and using Terragrunt code to define infrastructure resources. We've also demonstrated how to create a staging account in AWS and use Terragrunt to manage resources across multiple accounts. We hope this article has been helpful and that you'll try using Terragrunt with Github Packages and Github Actions to manage your infrastructure as code.
