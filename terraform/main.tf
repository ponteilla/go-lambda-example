terraform {
  backend "s3" {
    bucket = "go-lambda-example"
    region = "eu-west-1"
  }
}

module "vpc" {
  source = "./vpc"
  name   = "${var.name}-${var.env}"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.name}-data-${var.env}"
}

module "api" {
  source     = "./lambda"
  name       = "${var.name}-api"
  env        = "${var.env}"
  filename   = "../lambda/api/handler.zip"
  vpc_id     = "${module.vpc.id}"
  subnet_ids = "${module.vpc.private_subnet_ids}"

  role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DetachNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "logs:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.bucket.id}",
        "arn:aws:s3:::${aws_s3_bucket.bucket.id}/*"
      ]
    }
  ]
}
EOF

  environment_variables = {
    "S3_BUCKET" = "${aws_s3_bucket.bucket.id}"
  }
}

module "api_gateway" {
  name       = "${var.name}-api"
  env        = "${var.env}"
  source     = "./lambda_gateway"
  lambda     = "${module.api.name}"
  region     = "${var.region}"
  account_id = "${var.account_id}"
}
