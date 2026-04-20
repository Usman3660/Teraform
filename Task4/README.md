# Task 4 - Auto Scaling Group with CloudWatch Alarms

This Terraform configuration satisfies the assignment requirements by:

- Reusing the Task 1 VPC and public subnets from local Terraform state.
- Reusing the Task 2 web Security Group and SSH key pair from local Terraform state.
- Creating an EC2 launch template with Amazon Linux 2023, `t3.micro`, the Task 2 key pair, and the web Security Group.
- Installing `stress-ng` automatically on boot through user data.
- Creating an Auto Scaling Group across both public subnets with `min_size = 1`, `max_size = 3`, and `desired_capacity = 1`.
- Propagating a `Name` tag to launched instances.
- Creating scale-out and scale-in policies with the required cooldowns.
- Creating CloudWatch alarms that trigger scale-out at `>= 60%` CPU and scale-in at `<= 20%` CPU.

## Prerequisites

1. Complete Task 1 and Task 2 first.
2. Ensure these state files exist:
   - `../Task1/terraform.tfstate`
   - `../Task2/terraform.tfstate`
3. Confirm you have the private SSH key that matches the Task 2 key pair.

## Deploy

Run from the `Task4` folder:

```powershell
& "D:/teraform/terraform.exe" init
& "D:/teraform/terraform.exe" fmt
& "D:/teraform/terraform.exe" validate
& "D:/teraform/terraform.exe" plan -out tfplan
& "D:/teraform/terraform.exe" apply tfplan
```

## Verify the infrastructure

1. Open **EC2 -> Auto Scaling Groups** and confirm:
   - Desired capacity is `1`
   - Minimum is `1`
   - Maximum is `3`
   - The ASG is spanning both public subnets
   - The running instance has the expected `Name` tag

2. Open **CloudWatch -> Alarms** and confirm both alarms exist.

3. SSH into the running instance using the Task 2 private key and the instance public IP from the ASG details:

```powershell
ssh -i "C:/Users/muham/.ssh/assignment3_task2" ec2-user@<instance_public_ip>
```

4. Start a CPU stress test and keep it running long enough for two 60-second periods to breach the alarm threshold:

```bash
stress-ng --cpu 2 --cpu-method matrixprod --timeout 10m --metrics-brief
```

5. Watch **CloudWatch -> Alarms** until the high-CPU alarm enters the `ALARM` state.

6. Open **EC2 -> Auto Scaling Groups -> Activity** and capture the scale-out event when the new instance launches.

7. Stop the stress test with `Ctrl+C` or wait for the timeout.

8. After the cooldown period, confirm the ASG scales back in to 1 instance and capture the scale-in activity.

## Screenshot checklist for submission

Capture these items for your deliverable:

1. **EC2 Auto Scaling Group** page showing the running instances.
2. **CloudWatch alarm** page showing the scale-out alarm in the `ALARM` state.
3. **Auto Scaling Group Activity History** showing scale-out and scale-in events.
4. Terminal output showing the `stress-ng` command running.
5. Any additional console screenshots your instructor requested.

## Notes

- The launch template user data installs `stress-ng` on boot.
- The ASG uses the Task 2 web Security Group, so SSH access is limited to the IP rule already defined there.
- If you need to test again, you can terminate the stress command and wait for the scale-in alarm to bring the group back to 1 instance.

## Cleanup

```powershell
& "D:/teraform/terraform.exe" destroy
```
