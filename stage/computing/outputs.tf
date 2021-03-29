output "instance_ami" {
  value = data.aws_ami.instance_ami.id
}

output "instances_out" {
  value = aws_instance.cloud_public_instance.*
}

output "target_port" {
  value = aws_lb_target_group_attachment.cloud_public_instance_attach.*.port
}

output "instance_count" {
 value = var.instance_count
}
