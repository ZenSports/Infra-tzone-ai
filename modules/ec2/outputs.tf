output "elb_dns" {
  value = { for k, v in aws_elb.elb : k => v.dns_name }
}

output "Ec2InstanceConnect_security_group_id" {
  value = aws_security_group.Ec2InstanceConnect.id
}
