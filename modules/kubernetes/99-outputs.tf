//output "workers_elb_internal_dns_name" {
//  description = "The AWS DNS name of the worker nodes ELB"
//  value       = aws_elb.k8s_workers_internal_elb[0].dns_name
//}
//
//output "workers_elb_internal_zone_id" {
//  description = "The AWS zone id for the worker nodes ELB"
//  value       = aws_elb.k8s_workers_internal_elb[0].zone_id
//}

//output "nodes_ag_id" {
//  description = "The nodes autoscaling group id"
//  value       = aws_autoscaling_group.k8s_workers_ag[0].id
//}
//
//output "nodes_ag_availability_zones" {
//  description = "The nodes autoscaling group AZ used"
//  value       = aws_autoscaling_group.k8s_workers_ag[0].availability_zones
//}

output "nodes_subnets_private_id" {
  description = "The nodes subnets id"
  value       = [aws_subnet.k8s_private.*.id]
}

output "nodes_subnets_public_id" {
  description = "The nodes subnets id"
  value       = [aws_subnet.k8s_public.*.id]
}

output "controller_elb_internal_dns_name" {
  description = "The AWS DNS name of the controller nodes ELB"
  value       = aws_elb.k8s_controllers_internal_elb.dns_name
}

output "controller_elb_internal_zone_id" {
  description = "The AWS zone id for the controller nodes ELB"
  value       = aws_elb.k8s_controllers_internal_elb.zone_id
}

output "nodes_sd_id" {
  description = "The id of the nodes (workers) sg. Allows injection of rules aws_security_group_rule"
  value       = aws_security_group.k8s_workers_node_sg.id
}

output "controllers_sd_id" {
  description = "The id of the controllers sg. Allows injection of rules aws_security_group_rule"
  value       = aws_security_group.k8s_controllers_node_sg.id
}

output "k8s_role_id" {
  description = "The role the nodes use. Can be used to attach policies"
  value       = aws_iam_role.k8s_assume_role.id
}

output "private_route_table_id" {
  description = "The id of the PRIVATE route table"
  value       = aws_route_table.k8s_private_route_table.id
}

output "public_route_table_id" {
  description = "The id of the PUBLIC route table"
  value       = aws_route_table.k8s_public_route_table.id
}
