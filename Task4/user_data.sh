#!/bin/bash
set -euo pipefail

# Install stress-ng for scaling tests and nginx for ALB health checks.
dnf update -y
dnf install -y stress-ng nginx

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
HOSTNAME=$(hostname)

cat >/usr/share/nginx/html/index.html <<EOF
<html>
	<head><title>Assignment 3 Task 5</title></head>
	<body style="font-family: sans-serif; padding: 2rem;">
		<h1>ALB Target Healthy</h1>
		<p>Instance ID: $${INSTANCE_ID}</p>
		<p>Hostname: $${HOSTNAME}</p>
	</body>
</html>
EOF

systemctl enable nginx
systemctl start nginx
