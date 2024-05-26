variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "iam_bindings" {
  type = map(object({
   
