variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ecr_image" {
  type = string
}

variable "sns_topic_arn" {
  type = string
}
