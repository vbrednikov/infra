
variable "aws_region" {
  description = "Region"
  default     = "us-east-1"
}

variable "aws_access_key" {
    description="AWS access key"
}
variable "aws_secret_key" {
    description="AWS secret key"
}

variable "aws_key_name" {
    description="AWS key name"
    default="appuser_aws"
}

variable "aws_public_key_path" {
    description="AWS public key path"
}
variable "aws_private_key_path" {
    description="AWS private key path"
}

