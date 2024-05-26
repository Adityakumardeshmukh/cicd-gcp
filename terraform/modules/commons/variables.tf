variable "project_id" {
  type = string
}

variable "iam_bindings" {
  type = map(object({
    role   = string
    member = string
  }))
}

variable "region" {
  type = string
}

variable "subnet_1_cidr" {
  type = string
}

variable "subnet_2_cidr" {
  type = string
}

variable "composer_node_count" {
  type = number
}

variable "composer_image_version" {
  type = string
}

variable "composer_members" {
  type = list(string)
}
