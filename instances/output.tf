output "instance_ip" {
  value = aws_instance.platzi_instance.*.public_ip
}
