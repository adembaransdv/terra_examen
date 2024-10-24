variable "instance_id" {
  description = "L'ID de l'instance à laquelle attacher l'EIP"
  type        = string
}

resource "aws_eip" "ip" {
  instance = var.instance_id
  domain   = "vpc"
}

output "eip_id" {
  value = aws_eip.ip.id
}
