output "name" {
  value = "${aws_lambda_function.lambda.function_name}"
}

output "security_group_id" {
  value = "${aws_security_group.lambda_security_group.id}"
}
