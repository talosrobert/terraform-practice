variable "tags" {
  type = map(string)

  default = {
    Environment = "Personal"
    Project     = "CV"
  }
}