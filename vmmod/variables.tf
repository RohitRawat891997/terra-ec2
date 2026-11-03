variable "env" {
  default     = "prd"
  type        = string
  description = "This is my default dev env"

}
variable "key_pair_name" {
  default     = "terra-key"
  type        = string
  description = "This is webserver key pair name."
}

variable "public_key" {
  type        = string
  description = "This is webserver public key for ssh."
}


variable "instance_name" {
  default     = "webserver"
  type        = string
  description = "This instance name value for webserver instance"
}

variable "instance_type" {
  default     = "t2.micro"
  type        = string
  description = "This instance type value for webserver instance"
}

variable "instance_volume_size" {
  default     = "10"
  type        = string
  description = "This instance type value for webserver instance"
}


variable "security_group_name" {
  default     = "webserver-sg"
  type        = string
  description = "This is webserver sg name"
}

variable "ingress_ports" {
  description = "List of ingress rules to apply"
  type = list(object({
    port        = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    {
      port        = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow SSH from internal network"
    },
    {
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP from anywhere"
    },
    {
      port        = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTPS from anywhere"
    }
  ]
}
