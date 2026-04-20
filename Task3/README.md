# Task 3 - S3 Bucket for Terraform Remote State

This Terraform configuration completes all required items:

- Creates a uniquely named S3 bucket using `random_id` (and optional `roll_number` segment).
- Enables bucket versioning using `aws_s3_bucket_versioning`.
- Enables server-side encryption (SSE-S3, AES-256).
- Blocks all public access using `aws_s3_bucket_public_access_block`.
- Creates an IAM role + policy for EC2 with read/write permissions to this bucket only.
- Creates a DynamoDB table for Terraform state locking.
- Provides an S3 backend template for storing Terraform state in S3 after bootstrap.

## Files

- `main.tf`: S3, DynamoDB, IAM resources
- `variables.tf`: input variables + validation
- `versions.tf`: providers
- `outputs.tf`: useful outputs for migration/verification
- `terraform.tfvars.example`: sample values
- `backend.tf.example`: backend template used in migration step

## Prerequisites

1. AWS credentials configured (for example, via `aws configure` or environment variables).
2. Terraform installed.
3. Copy `terraform.tfvars.example` to `terraform.tfvars` and update values.

## Why bootstrap first with local state?

The S3 backend bucket and DynamoDB lock table do not exist at first. Deploy once with local state, then migrate the existing state to S3.

## Step-by-step commands (PowerShell)

Run from the `Task3` folder.

### 1) Bootstrap resources using local state

```powershell
& "D:/teraform/terraform.exe" init
& "D:/teraform/terraform.exe" fmt
& "D:/teraform/terraform.exe" validate
& "D:/teraform/terraform.exe" plan -out tfplan
& "D:/teraform/terraform.exe" apply tfplan
```

### 2) Read outputs (bucket + lock table names)

```powershell
& "D:/teraform/terraform.exe" output terraform_state_bucket_name
& "D:/teraform/terraform.exe" output terraform_lock_table_name
```

### 3) Create backend config file

Copy backend template:

```powershell
Copy-Item .\backend.tf.example .\backend.tf
```

Edit `backend.tf` and fill these values:
- `bucket` = output `terraform_state_bucket_name`
- `key` = `task3/terraform.tfstate`
- `region` = your region (for example `us-east-1`)
- `dynamodb_table` = output `terraform_lock_table_name`
- `encrypt` = `true`

### 4) Migrate local state to S3 backend

Run:

```powershell
& "D:/teraform/terraform.exe" init -migrate-state -reconfigure
```

After migration, Terraform state is stored in S3 and locking is done via DynamoDB.

### 5) Confirm backend is active

```powershell
& "D:/teraform/terraform.exe" plan
```

Expected: plan runs normally and no local-state migration prompt appears.

## Requirement mapping

1. Unique bucket name: `random_id.bucket_suffix` + optional `roll_number` in `local.bucket_name`.
2. Versioning: `aws_s3_bucket_versioning.terraform_state` with `Enabled`.
3. Encryption: `aws_s3_bucket_server_side_encryption_configuration.terraform_state` with `AES256`.
4. Public access block: `aws_s3_bucket_public_access_block.terraform_state` all `true`.
5. EC2 read/write only to this bucket: `aws_iam_policy.ec2_s3_rw` scoped to this bucket ARN and its objects.
6. State in S3: `backend "s3" {}` configured in `backend.tf` + `terraform init -migrate-state`.
7. Locking: `aws_dynamodb_table.terraform_locks` using `LockID` partition key.

## Deliverable checklist (AWS Console screenshots)

Capture these screenshots for submission:

1. S3 bucket overview showing bucket name and region.
2. S3 bucket Properties/Management showing:
   - Versioning = Enabled
   - Default encryption = SSE-S3 (AES-256)
3. S3 bucket Permissions showing Block Public Access settings all enabled.
4. IAM Role details showing attached custom policy for bucket-scoped access.
5. DynamoDB table details showing lock table name and `LockID` partition key.
6. S3 bucket object list showing `task3/terraform.tfstate` exists after migration.

## Cleanup

When backend is S3, destroy using the same backend config context:

```powershell
& "D:/teraform/terraform.exe" destroy
```

If AWS refuses bucket deletion due to versioned objects, empty all object versions/delete markers first, then destroy again.
