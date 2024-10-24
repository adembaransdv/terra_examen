variable "volume_size" {
  description = "Taille du volume EBS en GB"
  type        = number
}

variable "availability_zone" {
  description = "La zone de disponibilité pour le volume EBS"
  type        = string
}

resource "aws_ebs_volume" "volume" {
  availability_zone = var.availability_zone
  size              = var.volume_size
  tags = {
    Name = "adem-ebs-volume"
  }
}

output "volume_id" {
  value = aws_ebs_volume.volume.id
}
