variable "name" {}

variable "filename" {}

variable "vpc_id" {}

variable "subnet_ids" {
  type = "list"
}

variable "handler" {
  default = "handler.Handle"
}

variable "role_policy" {
  default = <<EOF
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
    }
  ]
}
EOF
}
