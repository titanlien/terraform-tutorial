variable "key_name" {
  default = "private-passwd"
}

variable "pvt_key" {
  default = "/Users/titan/.ssh/id_rsa"
}

variable "us-east-zones" {
  default = ["us-west-2a", "us-west-2b"]
}

variable "sg-id" {
  default = "sg-22ad455c"
}
