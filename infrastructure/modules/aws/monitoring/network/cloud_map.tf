# resource "aws_service_discovery_private_dns_namespace" "ecs" {
#   name = "ecs.internal"
#   vpc = data.aws_ssm_parameter.core_vpc_id.value
# }

# resource "aws_service_discovery_service" "api" {
#   name = "api"

#   dns_config {
#     namespace_id = aws_service_discovery_private_dns_namespace.ecs.id

#     dns_records {
#       ttl = 10
#       type = "A"
#     }
#   }
# }