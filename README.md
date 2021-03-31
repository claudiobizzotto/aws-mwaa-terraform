# Terraform AWS MWAA Quick Start

Quick start tutorial for Amazon Managed Workflows for Apache Airflow (MWAA) with Terraform. This is a word for word translation of the official [AWS quick start](https://docs.aws.amazon.com/mwaa/latest/userguide/quick-start.html)(with CloudFormation).

## Terraform support for MWAA

As of this writing, Terraform support for MWAA is still on the [roadmap](https://github.com/hashicorp/terraform-provider-aws/blob/075f1302acb2d325c47e0dcebc169c7d544de47c/ROADMAP.md#managed-workflows-for-apache-airflow), i.e. it's not part of Terraform yet.

In order to deploy the contents of this repository, you'll need to [compile](https://github.com/hashicorp/terraform-provider-aws/blob/main/docs/DEVELOPMENT.md) the Terraform AWS provider that supports MWAA from the PR branch that will eventually get merged.

* Github issue: [`16432`](https://github.com/hashicorp/terraform-provider-aws/issues/16432)
* PR: [`16616`](https://github.com/hashicorp/terraform-provider-aws/pull/16616)
* Branch: [`add_resource_aws_mwaa_environment`](https://github.com/shuheiktgw/terraform-provider-aws/tree/add_resource_aws_mwaa_environment)

Once the AWS provider is compiled, place it inside the following directory in your workstation, according to your operating system:

* Linux: `~/.terraform.d/plugins/registry.github.com.local/shuheiktgw/aws/1.0.0/linux_amd64`
* MacOS: `~/.terraform.d/plugins/registry.github.com.local/shuheiktgw/aws/1.0.0/darwin_amd64`
* Windows: I have no idea :(

Example on MacOS:

```bash
mkdir -p ~/development/terraform-providers/
cd ~/development/terraform-providers/
git clone git@github.com:shuheiktgw/terraform-provider-aws
cd terraform-provider-aws
git checkout add_resource_aws_mwaa_environment
make tools
make build
mkdir -p ~/.terraform.d/plugins/registry.github.com.local/shuheiktgw/aws/1.0.0/darwin_amd64
cp ~/go/bin/terraform-provider-aws ~/.terraform.d/plugins/registry.github.com.local/shuheiktgw/aws/1.0.0/darwin_amd64/terraform-provider-aws_v1.0.0
```

## Variables

Below is an example `terraform.tfvars` file that you can use in your deployments:

```ini
region   = "us-east-1"
prefix   = "my-mwaa"
vpc_cidr = "10.192.0.0/16"
public_subnet_cidrs = [
  "10.192.10.0/24",
  "10.192.11.0/24"
]
private_subnet_cidrs = [
  "10.192.20.0/24",
  "10.192.21.0/24"
]
mwaa_max_workers = 2
```

## DAGs

There's a test DAG file inside the local [`dags` directory](./dags), which was taken from the official tutorial for [Apache Airflow v1.10.12](https://airflow.apache.org/docs/apache-airflow/1.10.12/tutorial.html#example-pipeline-definition). You can place as many DAG files inside that directory as you want and Terraform will pick them up and upload them to S3.

## Usage

```bash
terraform fmt
terraform validate
terraform plan
terraform apply
```
