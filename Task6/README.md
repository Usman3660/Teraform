# Task 6 - Code Reusability with Terraform Modules and Packer

This task creates reusable Terraform modules and a Packer template for a custom AMI.

## Implemented modules

- `modules/vpc` inputs: `vpc_cidr`, `public_subnet_cidrs`, `private_subnet_cidrs`, `environment`
- `modules/vpc` outputs: `vpc_id`, `public_subnet_ids`, `private_subnet_ids`, `nat_gateway_id`
- `modules/security` inputs: `vpc_id`, `environment`
- `modules/security` outputs: `web_sg_id`, `db_sg_id`
- `modules/compute` inputs: `ami_id`, `instance_type`, `subnet_id`, `security_group_ids`, `key_name`, `environment`
- `modules/compute` outputs: `public_ip`, `instance_id`

Root module wiring example:

- `module.security` receives `vpc_id = module.vpc.vpc_id`
- `module.compute` receives `subnet_id = module.vpc.public_subnet_ids[0]`
- `module.compute` receives `security_group_ids = [module.security.web_sg_id]`
- `module.compute` receives `ami_id = var.custom_ami_id` (Packer AMI)

## Terraform commands

```powershell
Set-Location "D:/Eigth smester/dev/Assignment 3/Task6"
Copy-Item terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars and set custom_ami_id + key_name
terraform init
terraform validate
terraform plan
terraform apply
```

## Packer setup

Install Packer (Windows):

```powershell
winget install -e --id Hashicorp.Packer
```

Build custom AMI:

```powershell
Set-Location "D:/Eigth smester/dev/Assignment 3/Task6"
packer init build.pkr.hcl
packer build build.pkr.hcl
```

After build, copy the generated AMI ID and set it in `terraform.tfvars` as `custom_ami_id`.

## Deliverable checklist

1. Screenshot of `terraform plan` output showing module references in resource addresses.
2. Screenshot or code snippet proving root wiring with cross-module references:
   - `module.vpc.vpc_id`
   - `module.vpc.public_subnet_ids`
   - `module.security.web_sg_id`
3. AWS Console screenshot: EC2 -> AMIs showing the Packer-created AMI ID.
4. Terraform plan/apply using that custom AMI ID in compute module.
