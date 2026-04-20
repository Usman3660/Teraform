provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

locals {
  roll_segment = var.roll_number != "" ? "-${var.roll_number}" : ""
  bucket_name  = lower("${var.bucket_prefix}${local.roll_segment}-${random_id.bucket_suffix.hex}")
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = local.bucket_name

  tags = merge(var.tags, {
    Name = local.bucket_name
    Use  = "terraform-state"
  })
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(var.tags, {
    Name = var.dynamodb_table_name
    Use  = "terraform-locking"
  })
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "ec2_s3_access" {
  name               = var.ec2_role_name
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(var.tags, {
    Name = var.ec2_role_name
  })
}

data "aws_iam_policy_document" "ec2_s3_rw" {
  statement {
    sid    = "BucketListAccess"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [aws_s3_bucket.terraform_state.arn]
  }

  statement {
    sid    = "ObjectReadWriteAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts"
    ]
    resources = ["${aws_s3_bucket.terraform_state.arn}/*"]
  }
}

resource "aws_iam_policy" "ec2_s3_rw" {
  name   = "${var.ec2_role_name}-policy"
  policy = data.aws_iam_policy_document.ec2_s3_rw.json

  tags = merge(var.tags, {
    Name = "${var.ec2_role_name}-policy"
  })
}

resource "aws_iam_role_policy_attachment" "ec2_s3_rw" {
  role       = aws_iam_role.ec2_s3_access.name
  policy_arn = aws_iam_policy.ec2_s3_rw.arn
}

resource "aws_iam_instance_profile" "ec2_s3_access" {
  name = "${var.ec2_role_name}-instance-profile"
  role = aws_iam_role.ec2_s3_access.name

  tags = merge(var.tags, {
    Name = "${var.ec2_role_name}-instance-profile"
  })
}
