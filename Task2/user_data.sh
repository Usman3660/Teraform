#!/bin/bash
set -euxo pipefail

if command -v dnf >/dev/null 2>&1; then
  dnf -y install nginx
else
  yum -y install nginx
fi

TOKEN=$(curl -sS -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -sS -H "X-aws-ec2-metadata-token: ${TOKEN}" "http://169.254.169.254/latest/meta-data/instance-id")

cat > /usr/share/nginx/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Assignment 3 - Task 2</title>
</head>
<body>
  <h1>Nginx is running</h1>
  <p>Instance ID: ${INSTANCE_ID}</p>
</body>
</html>
EOF

systemctl enable nginx
systemctl restart nginx
