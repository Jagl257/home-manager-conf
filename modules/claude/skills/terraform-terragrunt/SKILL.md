name: terraform-terragrunt
description: "Terraform + Terragrunt patterns for AWS infrastructure. Use when writing or reviewing infrastructure code, terragrunt configs, ECS/ECR/IAM/SSM resources, or deploying to AWS environments."

---

# Overview

Terraform + Terragrunt patterns for writing infrastructure code and deploying to AWS. Covers directory structure, configuration hierarchy, naming conventions, and deployment workflow.

## Directory Structure

```
terragrunt/
├── aws_vars.hcl                    # Root: env→AWS account/profile mapping
├── apps/
│   └── terragrunt.hcl              # Module config (hooks, remote state, source)
│       └── common/
│           ├── alb.tf              # Load balancer
│           ├── data.tf             # Data sources
│           ├── ecr.tf              # Container registry
│           ├── ecs-autoscaling.tf  # Auto-scaling policies
│           ├── ecs-services-tasks.tf # ECS task/service definitions
│           ├── iam.tf              # IAM roles and policies
│           ├── monitoring.tf       # CloudWatch alarms
│           ├── providers.tf        # AWS provider config
│           ├── r53.tf              # Route 53 DNS
│           ├── s3.tf               # S3 buckets
│           ├── ssm.tf              # SSM parameters
│           ├── vars.tf             # Variable declarations (no defaults)
│           └── versions.tf         # Terraform version constraints
│       └── envs/
│           └── dev/
│               ├── dev/
│               │   ├── account.hcl         # Account name + tfstate key
│               │   └── us-east-1/
│               │       ├── terragrunt.hcl  # Includes parent
│               │       ├── region.hcl      # Region name
│               │       └── dev-variables.tf # Env-specific variable defaults
│               ├── stage/
│               │   └── us-east-1/
│               ├── uat/
│               │   ├── us-east-1/
│               │   └── eu-west-1/          # Optional EU region
│               └── prod/
│                   ├── us-east-1/
│                   └── eu-west-1/          # Optional EU region
└── backend/
    └── mongodb/                    # Separate modules (e.g. MongoDB Atlas)
        ├── terragrunt.hcl          # Same hook pattern as apps/
        └── common/
            ├── mongo-atlas.tf
            ├── mongo-atlas-monitoring.tf
            ├── ssm.tf
            ├── vars.tf
            └── versions.tf
        └── envs/
            ├── dev/us-east-1/
            │   └── dev-mongo-vars.tf
            ├── stage/us-east-1/
            ├── uat/us-east-1/
            └── prod/us-east-1/
```

## Environments & AWS Profiles

| Environment | AWS Profile (us-east-1) | AWS Profile (eu-west-1) | Account Name |
|-------------|------------------------|------------------------|--------------|
| dev  | `mycompany-dev-terraform`   | —                        | `mycompany-dev`   |
| stage | `mycompany-stage-terraform` | —                        | `mycompany-stage` |
| uat  | `mycompany-uat-terraform`   | `mycompany-eu-uat-terraform` | `mycompany-uat` |
| prod | `mycompany-prod-terraform`  | `mycompany-eu-prod-terraform` | `mycompany-prod` |

**S3 state buckets:** `mycompany-tfstate-{env}` (us-east-1), `mycompany-tfstate-{env}-eu-west-1` (eu-west-1)
**DynamoDB lock table:** `tfstate_{env}`

## Configuration Hierarchy

Terragrunt resolves configuration by composing files from multiple levels. Understanding this hierarchy is essential.

### 1. `aws_vars.hcl` (root)

Maps `{env}-{region}` keys to AWS account details. Every module reads this.

```hcl
locals {
  env_settings = {
    dev-us-east-1 = {
      aws_profile      = "mycompany-dev-terraform"
      aws_account_name = "mycompany-dev"
      sso_env_name     = "dev"
      tfstate_bucket   = "mycompany-tfstate-dev"
    }
    stage-us-east-1 = {
      aws_profile      = "mycompany-stage-terraform"
      aws_account_name = "mycompany-stage"
      sso_env_name     = "stage"
      tfstate_bucket   = "mycompany-tfstate-stage"
    }
    uat-us-east-1 = {
      aws_profile      = "mycompany-uat-terraform"
      aws_account_name = "mycompany-uat"
      sso_env_name     = "uat"
      tfstate_bucket   = "mycompany-tfstate-uat"
    }
    prod-us-east-1 = {
      aws_profile      = "mycompany-prod-terraform"
      aws_account_name = "mycompany-prod"
      sso_env_name     = "prod"
      tfstate_bucket   = "mycompany-tfstate-prod"
    }
    # EU regions follow pattern: {env}-eu-west-1
    prod-eu-west-1 = {
      aws_profile      = "mycompany-eu-prod-terraform"
      aws_account_name = "mycompany-eu-prod"
      sso_env_name     = "eu-prod"
      tfstate_bucket   = "mycompany-tfstate-prod-eu-west-1"
    }
  }
}
```

### 2. `account.hcl` (per environment)

Located at `envs/{env}/account.hcl`. Defines the environment name and tfstate key.

```hcl
locals {
  account_name  = "${basename(get_terragrunt_dir())}"  # "dev", "stage", "uat", "prod"
  tfstate_s3_key = "my-service-name/terraform.tfstate"
}
```

### 3. `region.hcl` (per region)

Located at `envs/{env}/{region}/region.hcl`. Derives region from directory name.

```hcl
locals {
  region = "${basename(get_terragrunt_dir())}"  # "us-east-1", "eu-west-1"
}
```

### 4. Module `terragrunt.hcl` (e.g. `apps/terragrunt.hcl`)

The core config that wires everything together. All modules (apps, backend/mongodb, etc.) follow this pattern:

```hcl
locals {
  aws_vars     = read_terragrunt_config(find_in_parent_folders("aws_vars.hcl")).locals
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars  = read_terragrunt_config("region.hcl")

  aws_env         = local.account_vars.locals.account_name
  env             = lookup(local.aws_vars.env_settings, "${local.account_vars.locals.account_name}-${local.region_vars.locals.region}", "")
  tfstate_s3_key  = local.account_vars.locals.tfstate_s3_key
  backend_bucket  = local.env.tfstate_bucket
  aws_profile     = local.env.aws_profile
  aws_sso_cmd     = get_platform() == "windows" ? ["aws-sso", "--env", local.env.sso_env_name] : ["aws-sso", "--env", local.env.sso_env_name]
  hooks_enabled   = get_env("DISABLE_HOOKS", "false") == "true" ? false : true
}

terraform {
  source = "${get_parent_terragrunt_dir()}//common"

  # Authenticate via aws-sso before init
  before_hook "aws_sso" {
    commands = local.hooks_enabled ? ["init-from-module"] : []
    execute  = local.aws_sso_cmd
  }

  # Download provider.tf from S3 (contains var.acct, var.aws, var.vpc, etc.)
  before_hook "load_provider" {
    commands = ["apply", "plan", "import", "init", "refresh"]
    execute  = ["aws", "s3", "cp", "s3://${local.backend_bucket}/main/${local.aws_env}-${local.region_vars.locals.region}-provider.tf", ".", "--profile", "${local.aws_profile}"]
  }

  # Download autovars from S3 (contains account-specific variable values)
  before_hook "load_autovars" {
    commands = ["apply", "plan", "import", "init", "refresh"]
    execute  = ["aws", "s3", "cp", "s3://${local.backend_bucket}/main/${local.aws_env}.auto.tfvars", ".", "--profile", "${local.aws_profile}"]
  }
}

remote_state {
  backend  = "s3"
  generate = {
    path     = "remotestate.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket         = local.backend_bucket
    region         = local.region_vars.locals.region
    encrypt        = true
    profile        = local.aws_profile
    key            = local.tfstate_s3_key
    dynamodb_table = "tfstate_${local.aws_env}"
  }
}
```

### 5. Leaf `terragrunt.hcl` (per env/region)

Located at `envs/{env}/{region}/terragrunt.hcl`. Minimal - just includes parent:

```hcl
include "root" {
  path   = find_in_parent_folders()
  expose = true
}
```

## Shared Variables (from S3)

The `load_provider` and `load_autovars` hooks download files from S3 that provide these variables at plan/apply time. They are NOT checked into the repo:

- `var.acct["account-id"]` - AWS account ID
- `var.acct["abbrev"]` - Environment abbreviation (dev, stage, uat, prod)
- `var.acct["region"]` - AWS region
- `var.aws["region"]` - AWS region
- `var.aws["profile"]` - AWS CLI profile
- `var.vpc["sg-web-app"]` - Shared web application security group
- `var.vpc["subnets-private"]` - Private subnets
- `var.vpc["internal-zoneid"]` - Route53 hosted zone ID
- `var.vpc["internal-dns"]` - Internal DNS domain (e.g. `aws-dev.mycompany.internal`)
- `var.vpc["cert"]` - ACM certificate ARN
- `var.fluentd_memory_reservation`, `var.fluentd_cpu` - Logging sidecar resources

## Naming Conventions

### Resource Names

```hcl
# Pattern: mycompany-{type}-{application}-{purpose}
name = "mycompany-role-${lower(replace(var.application, " ", ""))}-task"
name = "mycompany-policy-${lower(replace(var.application, " ", ""))}-task"
```

Always use `lower(replace(var.application, " ", ""))` for consistency.

### Application Variable
```hcl
variable "application" {
  # NO SPACES, lowercase with hyphens
  default = "my-service-name"
}
```

## Required Tags

All resources MUST have these tags:

```hcl
tags = {
  Name            = "resource-name"
  Environment     = var.acct["abbrev"]     # dev, stage, uat, prod
  Project         = var.project            # project-name
  Owner           = var.owner              # team-name
}
```

### Default Tags (via Provider)
```hcl
provider "aws" {
  region  = var.aws["region"]
  profile = var.aws["profile"]

  default_tags {
    tags = {
      Environment     = lower(var.acct["abbrev"])
      Project         = var.project
      Owner           = var.owner
      Service         = lower(replace(var.application, " ", ""))
      GitRepo         = var.git_repo
    }
  }
}
```

## Standard vars.tf Template

```hcl
variable "application" {
  default = "my-service-name"
}

variable "dnsname" {
  default = "my-service"
}

variable "project" {
  default = "my-project"
}

variable "owner" {
  default = "my-team"
}

variable "ecs_cluster" {
  default = "app-cluster"
}

variable "docker_container_name" {
  default = "my-org/my-service-name"
}

variable "git_repo" {
  default = "https://github.com/my-org/my-service-name"
}
```

### Environment-Specific Variables

Located at `envs/{env}/{region}/{env}-variables.tf`. Only override values that differ per environment:

```hcl
# dev-variables.tf
variable "env" {
  default = {
    min_task_capacity                = 1
    max_task_capacity                = 3
    aspnetcore_environment           = "Development"
    deployment_minimum_healthy_percent = 50
    deployment_maximum_percent       = 200
    health_check_grace_period_seconds = 120
    memory                           = 1024
    memory_reservation               = 512
    cpu                              = 256
  }
}
```

```hcl
# prod-variables.tf - higher resources
variable "env" {
  default = {
    min_task_capacity                = 2
    max_task_capacity                = 8
    aspnetcore_environment           = "Production"
    deployment_minimum_healthy_percent = 100
    deployment_maximum_percent       = 200
    health_check_grace_period_seconds = 120
    memory                           = 4096
    memory_reservation               = 1024
    cpu                              = 1024
  }
}
```

## IAM Role Template

```hcl
resource "aws_iam_role" "app_task" {
  name = "mycompany-role-${lower(replace(var.application, " ", ""))}-task"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Principal = {
        Service = ["ec2.amazonaws.com", "ecs-tasks.amazonaws.com"]
      }
    }]
  })
}
```

## ECR Repository Template

```hcl
resource "aws_ecr_repository" "app" {
  name = var.docker_container_name
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Delete untagged images over 3 days old"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 3
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Keep last 30 release images"
        selection = {
          tagStatus      = "tagged"
          tagPrefixList  = ["release-"]
          countType      = "imageCountMoreThan"
          countNumber    = 30
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 3
        description  = "Keep last 10 develop images"
        selection = {
          tagStatus      = "tagged"
          tagPrefixList  = ["develop-"]
          countType      = "imageCountMoreThan"
          countNumber    = 10
        }
        action = { type = "expire" }
      }
    ]
  })
}
```

## SSM Parameter Template

```hcl
resource "aws_ssm_parameter" "param_name" {
  name      = "/${var.acct["abbrev"]}/${replace(var.application, " ", "")}/PARAM_NAME"
  type      = "String"  # or "SecureString" for secrets
  overwrite = true
  value     = var.param_value

  tags = {
    Name        = "${lower(replace(var.application, " ", ""))}-param-name"
    Environment = var.acct["abbrev"]
    Project     = var.project
    Owner       = var.owner
  }
}
```

## Route53 Pattern

```hcl
resource "aws_route53_record" "app" {
  zone_id = var.vpc["internal-zoneid"]
  name    = "${var.dnsname}.${var.vpc["internal-dns"]}"
  type    = "A"

  alias {
    name                   = aws_alb.app.dns_name
    zone_id                = aws_alb.app.zone_id
    evaluate_target_health = true
  }
}
# Result: my-service.aws-dev.mycompany.internal
```

## ALB Standard Port Configuration

```hcl
resource "aws_alb_listener" "app_https" {
  load_balancer_arn = aws_alb.app.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn   = var.vpc["cert"]
}

resource "aws_alb_target_group" "app" {
  port     = 8080
  protocol = "HTTP"
}
```

## Security Groups

Use existing shared security groups when possible:

```hcl
security_group_ids = [var.vpc["sg-web-app"]]
```

## Deployment Workflow

### 1. Navigate to Environment
```bash
cd terragrunt/apps/envs/dev/us-east-1
```

### 2. Initialize and Plan
```bash
terragrunt init
terragrunt plan
```

### 3. Apply
```bash
terragrunt apply -auto-approve
```

### 4. Verify
```bash
# Check ECS service
aws ecs describe-services --cluster app-cluster --services <service-name> --region us-east-1 --profile mycompany-dev-terraform

# Check SSM parameters
aws ssm get-parameters-by-path --path "/dev/<app-name>/" --region us-east-1 --profile mycompany-dev-terraform

# Check ALB
aws elbv2 describe-load-balancers --names <alb-name> --region us-east-1 --profile mycompany-dev-terraform
```

### Disable SSO Hook (CI/CD or pre-authenticated)
```bash
DISABLE_HOOKS=true terragrunt plan
```

## Common Issues

### State Lock Error
```
Error: Error acquiring the state lock
Lock Info:
  ID: <lock-id>
```
**Fix:** `terragrunt force-unlock -force <lock-id>`

### Duplicate Variable Declaration
Variables should only be declared ONCE - in `common/vars.tf` (without defaults) OR in `{env}-variables.tf` (with defaults). Never both.

### ECR Repository Missing
Create `ecr.tf` in `common/` with the ECR template above.

### Missing execution_role_arn
```hcl
resource "aws_ecs_task_definition" "app" {
  task_role_arn      = aws_iam_role.task.arn
  execution_role_arn = aws_iam_role.task.arn  # Required when using secrets
}
```

### Missing providers.tf
This is downloaded from S3 by the `load_provider` hook. If it fails, check:
1. AWS SSO session is active (`aws-sso --env <sso_env_name>`)
2. The S3 bucket `mycompany-tfstate-{env}` is accessible
3. The file exists: `s3://{bucket}/main/{env}-{region}-provider.tf`

## Standard Clusters

| Environment | Cluster      |
|-------------|--------------|
| Dev         | `app-cluster` |
| Stage       | `app-cluster` |
| UAT         | `app-cluster` |
| Production  | `app-cluster` |