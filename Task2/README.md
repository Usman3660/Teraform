# Task 2 - Security Groups and EC2 Instance Deployment

This Terraform configuration satisfies the assignment requirements by:

- Creating a public web Security Group allowing inbound ports 80, 443, and 22 from your IP only.
- Creating a private DB Security Group allowing inbound port 3306 from the web SG only.
- Allowing all outbound traffic on all SGs.
- Launching a public `t3.*` web EC2 instance in a public subnet with Nginx user data.
- Launching a private `t3.*` DB EC2 instance in a private subnet.
- Creating and attaching an AWS key pair from a local `.pub` key.
- Validating `instance_type` to allow only: `t3.micro`, `t3.small`, `t3.medium`.

## Prerequisites

1. Complete Task 1 first (`../task1/terraform.tfstate` must exist).
2. Ensure `public_key_path` points to an existing local public key file.

## Deploy

Run from the `Task2` folder:

```powershell
& "D:/teraform/terraform.exe" init
& "D:/teraform/terraform.exe" fmt
& "D:/teraform/terraform.exe" validate
& "D:/teraform/terraform.exe" plan -out tfplan
& "D:/teraform/terraform.exe" apply tfplan
```

## Verify requirements

1. Confirm SG rules in AWS Console:
- `assignment3-web-sg`: inbound 80/443/22 from `my_ip_cidr` only.
- `assignment3-db-sg`: inbound 3306 only from `assignment3-web-sg`.
- Outbound all traffic for each SG.

2. Confirm both EC2 instances are running in AWS Console:
- `assignment3-web-instance` in public subnet
- `assignment3-db-instance` in private subnet

3. Open Nginx page from your browser:
- `http://<web_public_ip>`
- Page should show `Instance ID: i-...`

4. SSH checks:

```powershell
# From your machine to public instance
ssh -i "C:/Users/muham/.ssh/assignment3_task2" ec2-user@<web_public_ip>

# From public instance to private instance (bastion path)
scp -i "C:/Users/muham/.ssh/assignment3_task2" "C:/Users/muham/.ssh/assignment3_task2" ec2-user@<web_public_ip>:/home/ec2-user/
ssh -i "C:/Users/muham/.ssh/assignment3_task2" ec2-user@<web_public_ip>
chmod 400 ~/assignment3_task2
ssh -i ~/assignment3_task2 ec2-user@<db_private_ip>
```

5. Direct private access should fail from your machine:

```powershell
ssh -i "C:/Users/muham/.ssh/assignment3_task2" ec2-user@<db_private_ip>
```

Expected: timeout/no route because private instance has no public path from the internet.

## Validate invalid instance type error

Set in `terraform.tfvars`:

```hcl
instance_type = "t2.micro"
```

Run:

```powershell
& "D:/teraform/terraform.exe" plan
```

Expected error:

```text
Error: Invalid value for variable

  on variables.tf line ...
  instance_type must be one of: t3.micro, t3.small, t3.medium.
```

## Cleanup

```powershell
& "D:/teraform/terraform.exe" destroy
```
