# Assignment 3 - Custom VPC with Subnetting and NAT Gateway

This Terraform configuration creates:

- A custom VPC with DNS support and DNS hostnames enabled
- Two public subnets in different Availability Zones
- Two private subnets in different Availability Zones
- An Internet Gateway
- A public route table associated with both public subnets
- An Elastic IP and NAT Gateway in a public subnet
- A private route table that sends `0.0.0.0/0` traffic through the NAT Gateway
- Outputs for the VPC ID, subnet IDs, and NAT Gateway ID

## Files

- `versions.tf` - Terraform and provider requirements
- `variables.tf` - Input variables
- `main.tf` - Core networking resources
- `outputs.tf` - Terraform outputs

## Deploy

1. Configure AWS credentials for the account you want to use.
2. Update the `aws_region` variable if needed.
3. Run:

```bash
terraform init
terraform fmt
terraform validate
terraform plan -out tfplan
terraform apply tfplan
terraform state list
```

## Destroy

```bash
terraform destroy
```

## What to screenshot for the assignment

- `terraform plan` output
- `terraform apply` output
- AWS Console VPC route tables showing:
  - Public route table with `0.0.0.0/0 -> Internet Gateway`
  - Private route table with `0.0.0.0/0 -> NAT Gateway`
- `terraform state list` output after apply
- Confirmation in the AWS Console that the VPC, subnets, route tables, NAT Gateway, EIP, and IGW are removed after `terraform destroy`

## Traffic flow explanation

A private instance has no public IP and cannot reach the internet directly. Its subnet is associated with the private route table, which sends default traffic to the NAT Gateway. The NAT Gateway lives in a public subnet, uses an Elastic IP, and forwards outbound traffic to the Internet Gateway. Return traffic comes back to the NAT Gateway and is translated back to the private instance.
