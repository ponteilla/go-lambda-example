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

module "api" {
  source     = "./lambda"
  name       = "${var.name}-api-${var.env}"
  filename   = "../lambda/api/handler.zip"
  vpc_id     = "${module.vpc.id}"
  subnet_ids = "${module.vpc.private_subnet_ids}"
}

module "api_gateway" {
  name       = "${var.name}-api"
  env        = "${var.env}"
  source     = "./lambda_gateway"
  lambda     = "${module.api.name}"
  region     = "${var.region}"
  account_id = "${var.account_id}"
}
