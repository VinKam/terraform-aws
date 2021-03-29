output "cloud_network" {
  value = module.networking.network_vpc_id
}

output "instance_ami" {
  value = module.compute.instance_ami
}

output "insta_output" {
 value = { for i in range(module.compute.instance_count): module.compute.instances_out[i].tags.Name => "${module.compute.instances_out[i].public_ip}:${module.compute.target_port[i]}"}
}
