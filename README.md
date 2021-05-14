# ecs_fargate_terraform
cd 1-infrastructure

terraform init -backend-config="infrastructure-prod.config"

terraform plan -var-file="production.tfvars"

terraform apply -var-file="production.tfvars"
