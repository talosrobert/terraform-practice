variable "tags_project_cv" {
  type = map(string)

  default = {
    Environment = "Personal"
    Project     = "CV"
  }
}

variable "my_public_ip" {
  type      = string
  sensitive = true
  default   = "144.2.105.242"
}
