#-----outputs.tf-----
#====================
output "k8s-master-Public-IP" {
  value = module.compute.k8s-master_server_ip
}

output "k8s-node-Public-IP" {
  value = module.compute.k8s-node_server_ips
}