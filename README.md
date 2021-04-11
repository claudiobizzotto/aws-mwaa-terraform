# Terraform AWS MWAA Quick Start

Quick start tutorial for Amazon Managed Workflows for Apache Airflow (MWAA) with Terraform. This is a word for word translation of the official [AWS quick start](https://docs.aws.amazon.com/mwaa/latest/userguide/quick-start.html) (with CloudFormation).

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
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```
