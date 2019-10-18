variable "default_tags" {
  type = "map"
  default = {
    Name        = "terraform-example"
    Owner       = "user1"
    environment = "staging"
    project     = "terraform-example"
  }
}
