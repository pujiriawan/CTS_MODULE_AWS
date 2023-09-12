output "public_ip_address" {
  description = "cts Manager's Public IP Address"
  value = aws_instance.cts_aws.public_ip
}

output "tls_private_key" {
  description = "cts Manager's Admin SSH Private Key"
  value     = tls_private_key.cts_ssh_key.private_key_pem
  sensitive = true
}

output "tls_public_key" {
  description = "cts Manager's Admin SSH Public Key"
  value = tls_private_key.cts_ssh_key.public_key_openssh
}