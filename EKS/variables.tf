variable "aws_access_key_id" {
  description = "AWS Username"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Password"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}