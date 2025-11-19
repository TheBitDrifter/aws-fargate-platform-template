# --- PLATFORM DEPLOYMENT TEMPLATE ---
# Use this file to deploy the shared infrastructure (VPC, ECS Cluster, ALB, API Gateway).
# This should be deployed ONCE per environment (e.g., staging, prod).

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend configuration (S3 + DynamoDB)
  # Values must be passed via CLI: -backend-config="bucket=..." -backend-config="dynamodb_table=..."
  backend "s3" {
    key     = "platform/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = "Platform-Infra"
      ManagedBy   = "Terraform"
    }
  }
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}


variable "project_name" {
  description = "Project identifier"
  type        = string
  default     = "acme"
}

variable "environment" {
  description = "Deployment environment (e.g., 'dev', 'staging', 'prod')"
  type        = string
}

module "platform" {
  # References the platform module via Git
  source = "git::https://github.com/TheBitDrifter/terraform-aws-fargate-platform.git?ref=main"
  # source = "../../terraform-aws-fargate-platform"

  project_name       = var.project_name
  environment        = var.environment
  aws_region         = var.aws_region
  vpc_cidr_block     = "10.0.0.0/16"
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  availability_zones = 2
}

# Re-export outputs for easy access
output "vpc_id" { value = module.platform.vpc_id }
output "private_subnet_ids" { value = module.platform.private_subnet_ids }
output "ecs_cluster_id" { value = module.platform.ecs_cluster_id }
output "alb_listener_arn" { value = module.platform.alb_listener_arn }
output "api_gateway_id" { value = module.platform.api_gateway_id }
output "vpc_link_id" { value = module.platform.vpc_link_id }
output "ecs_tasks_security_group_id" { value = module.platform.ecs_tasks_security_group_id }
output "internal_alb_dns_name" { value = module.platform.internal_alb_dns_name }
