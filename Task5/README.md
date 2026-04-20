# Task 5 - Application Load Balancer with Health Checks

This task adds an internet-facing Application Load Balancer (ALB) in front of the Task 4 Auto Scaling Group and verifies load distribution across instances.

## What this task creates

- ALB (`aws_lb`) across both public subnets from Task 1.
- Dedicated ALB Security Group that allows inbound HTTP (`80`) from `0.0.0.0/0` and all outbound traffic.
- Ingress rule on the Task 2 web Security Group to allow HTTP only from the ALB Security Group.
- Target Group (`aws_lb_target_group`) on HTTP/80 with health check path `/`, `healthy_threshold = 2`, `unhealthy_threshold = 3`.
- Listener (`aws_lb_listener`) on port 80 forwarding to the target group.
- ASG attachment (`aws_autoscaling_attachment`) between Task 4 ASG and the target group.

## Prerequisites

1. Task 1, Task 2, and Task 4 are applied.
2. AWS credentials are available in your terminal.
3. Task 2 changes are re-applied so direct internet HTTP to web SG is removed.
4. Task 4 changes are re-applied so ASG instances run nginx and `desired_capacity = 2`.

## Apply order

Run these commands in order:

```powershell
Set-Location "D:/Eigth smester/dev/Assignment 3/Task2"
terraform init
terraform apply

Set-Location "D:/Eigth smester/dev/Assignment 3/Task4"
terraform init
terraform apply

Set-Location "D:/Eigth smester/dev/Assignment 3/Task5"
terraform init
terraform validate
terraform plan -out tfplan
terraform apply tfplan
```

## Verify load balancing

1. Get the ALB DNS name:

```powershell
Set-Location "D:/Eigth smester/dev/Assignment 3/Task5"
terraform output alb_dns_name
```

2. Send repeated requests and observe instance IDs changing:

```powershell
for ($i=1; $i -le 12; $i++) { Invoke-WebRequest -UseBasicParsing "http://<alb_dns_name>" | Select-Object -ExpandProperty Content; "-----" }
```

The page includes `Instance ID` and `Hostname`, so repeated requests should show different instances.

## Required screenshots for deliverable

1. **ALB DNS and load balancer details**
   - AWS Console -> EC2 -> Load Balancers -> select `assignment3-task5-alb`
   - Include DNS name in screenshot.

2. **Target group health checks**
   - AWS Console -> EC2 -> Target Groups -> select `assignment3-task5-tg` -> Targets tab
   - Show at least 2 healthy targets.

3. **ALB request distribution proof**
   - Browser tab or terminal output showing responses with different instance IDs.

4. **ASG activity context (optional but recommended)**
   - AWS Console -> EC2 -> Auto Scaling Groups -> `assignment3-task4-asg` -> Activity tab.

## Cleanup

```powershell
Set-Location "D:/Eigth smester/dev/Assignment 3/Task5"
terraform destroy
```
