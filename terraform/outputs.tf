output "public_ip" {
  value = aws_eip.k3s.public_ip
}

output "instance_id" {
  value = aws_instance.k3s.id
}

output "ssh_command" {
  value = "ssh ubuntu@${aws_eip.k3s.public_ip}"
}

output "bootstrap_log" {
  value = "sudo cat /var/log/k3s-bootstrap.log"
}
