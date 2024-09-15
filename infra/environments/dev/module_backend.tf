module "backend_secret_manager" {
  source           = "../../modules/secret_manager/backend"
  environment_name = var.environment_name
}

module "backend_ecr" {
  source           = "../../modules/ecr/backend"
  environment_name = var.environment_name
}

module "backend_iam" {
  source           = "../../modules/iam/backend"
  environment_name = var.environment_name
}

module "backend_network" {
  source           = "../../modules/network/backend"
  environment_name = var.environment_name
  vpc_id           = var.vpc_id
  vpc_cidr_block   = module.network.vpc_cidr_block
}

module "backend_load_balancer" {
  source                              = "../../modules/load_balancer/backend"
  environment_name                    = var.environment_name
  aws_security_group_load_balancer_id = module.backend_network.elb_sg_id
  subnet_1a_load_balancer_id          = var.public_subnet_a_id
  subnet_1c_load_balancer_id          = var.public_subnet_b_id
  vpc_id                              = var.vpc_id
  certificate_arn                     = module.certificate_manager.cert_arn
}

module "backend_ecs" {
  source                          = "../../modules/ecs/backend"
  environment_name                = var.environment_name
  logs_region                     = var.region
  secret_arn                      = module.backend_secret_manager.secret_arn
  ecr_uri                         = module.backend_ecr.ecr_uri
  ecs_task_execution_role_arn     = module.backend_iam.ecs_task_execution_role_arn
  ecs_task_container_role_arn     = module.backend_iam.ecs_task_container_role_arn
  security_group_ecs_task_service = module.backend_network.ecs_sg_id
  public_subnet_id                = var.public_subnet_a_id
  target_group_arn                = module.backend_load_balancer.load_balancer_target_group_arn
}
