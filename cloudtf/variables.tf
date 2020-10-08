variable "region" {}

variable "nixos_amis" {
  type = map(map(object({
    hvm-ebs = string
  })))
}
