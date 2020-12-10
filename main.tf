variable "vpc_id" {
  type = string
}

variable "region" {
  type = string
}

variable "subnets" {
  type = list(string)
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.14.1"
    }
  }
}

provider "aws" {
  region = var.region
}

# Get Private Subnets
data "aws_subnet_ids" "private" {
  vpc_id = var.vpc_id
  filter {
    name   = "tag:Name"
    values = subnets
  }
}

# Create VM Import Policy
resource "aws_iam_policy" "vmimport_policy" {
  name        = "avi-vmimport-policy"
  description = "Enables the Avi SE VM to be imported into AWS"
  path        = "/"
  policy      = file("./iam_policies/vmimport-policy.json")
}

# Create VM Import Service Role
resource "aws_iam_role" "vmimport_role" {
  name               = "vmimport"
  description        = "Enables the Avi SE VM to be imported into AWS"
  assume_role_policy = file("./iam_policies/vmimport-role-trust.json")
  tags = {
    Terraform = true
  }
}

# Attach VM Import Policy to Role
resource "aws_iam_role_policy_attachment" "vmimport-attach" {
  role       = aws_iam_role.vmimport_role.name
  policy_arn = aws_iam_policy.vmimport_policy.arn
}

# Create Avi Controller Ec2 Policy
resource "aws_iam_policy" "avicontroller_ec2_policy" {
  name        = "avi-controller-ec2-policy"
  description = "Enables Avi Controller instance to be installed."
  path        = "/"
  policy      = file("./iam_policies/avicontroller-ec2-policy.json")
}

# Create Avi Controller IAM Policy
resource "aws_iam_policy" "avicontroller_iam_policy" {
  name        = "avi-controller-iam-policy"
  description = "Enable access to retrieve IAM roles and policy information."
  path        = "/"
  policy      = file("./iam_policies/avicontroller-iam-policy.json")
}

# Create Avi Controller ASG Policy
resource "aws_iam_policy" "avicontroller_asg_policy" {
  name        = "avi-controller-asg-policy"
  description = "Enables read access to the AWS cloud's Auto Scaling groups."
  path        = "/"
  policy      = file("./iam_policies/avicontroller-asg-policy.json")
}

# Create Avi Controller S3 Policy
resource "aws_iam_policy" "avicontroller_s3_policy" {
  name        = "avi-controller-s3-policy"
  description = "Enables read access to the AWS cloud S3 Buckets."
  path        = "/"
  policy      = file("./iam_policies/avicontroller-s3-policy.json")
}

# Create AVI Service Role
resource "aws_iam_role" "avicontroller_role" {
  name               = "AviController-Refined-Role"
  description        = "Enables Avi Controller instance to be installed."
  assume_role_policy = file("./iam_policies/avicontroller-role-trust.json")
  tags = {
    Terraform = true
  }
}

resource "aws_iam_instance_profile" "avicontroller_profile" {
  name = "AviController-Refined-Role"
  role = aws_iam_role.avicontroller_role.name
}


# Attach AVI Ec2 Policy to Role
resource "aws_iam_role_policy_attachment" "avicontroller-ec2-attach" {
  role       = aws_iam_role.avicontroller_role.name
  policy_arn = aws_iam_policy.avicontroller_ec2_policy.arn
}

# Attach AVI IAM Policy to Role
resource "aws_iam_role_policy_attachment" "avicontroller-iam-attach" {
  role       = aws_iam_role.avicontroller_role.name
  policy_arn = aws_iam_policy.avicontroller_iam_policy.arn
}

# Attach AVI ASG Policy to Role
resource "aws_iam_role_policy_attachment" "avicontroller-asg-attach" {
  role       = aws_iam_role.avicontroller_role.name
  policy_arn = aws_iam_policy.avicontroller_asg_policy.arn
}

# Attach AVI S3 Policy to Role
resource "aws_iam_role_policy_attachment" "avicontroller-s3-attach" {
  role       = aws_iam_role.avicontroller_role.name
  policy_arn = aws_iam_policy.avicontroller_s3_policy.arn
}
