resource "aws_lambda_function" "lambda" {
  filename         = "${var.filename}"
  function_name    = "${var.name}-${var.env}"
  role             = "${aws_iam_role.iam_role_for_lambda.arn}"
  handler          = "${var.handler}"
  runtime          = "python2.7"
  source_code_hash = "${base64sha256(file("${var.filename}"))}"

  vpc_config {
    subnet_ids         = ["${var.subnet_ids}"]
    security_group_ids = ["${aws_security_group.lambda_security_group.id}"]
  }

  environment {
    variables = "${merge(var.environment_variables, map("ENV", var.env))}"
  }
}

resource "aws_security_group" "lambda_security_group" {
  name   = "${var.name}-${var.env}"
  vpc_id = "${var.vpc_id}"

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "iam_role_for_lambda" {
  name = "${replace(format("%s-%s", var.name, var.env), "-", "_")}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "policy_for_lambda" {
  name   = "${replace(format("%s-%s", var.name, var.env), "-", "_")}"
  role   = "${aws_iam_role.iam_role_for_lambda.id}"
  policy = "${var.role_policy}"
}
