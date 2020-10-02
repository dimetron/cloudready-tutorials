variable "default_tags" {
  type = map(string)
  default = {
    Name        = "terraform-example"
    Owner       = "user1"
    environment = "staging"
    project     = "terraform-example"
  }
}
