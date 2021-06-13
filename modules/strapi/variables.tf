
variable "domain" {
  description = "top level domain"
  type        = string
}


variable "api_domain" {
  description = "api.branch.project.domain"
  type        = string
}



variable "dashboard_domain" {
  description = "dashboard.branch.project.domain"

  type = string
}


variable "database_url" {
  type      = string
  sensitive = true
}


variable "docker_image" {
  description = "Docker image name including the tag which should be deployed. Set this during CI"
  type        = string
}


variable "id" {
  description = "Combination of project and branch name"
  type        = string
}

variable "rancher_project_id" {
  description = "This ID is used to automatically map a namespace to a rancher project. This is just for 'convenience'"
  type        = string
  default     = "c-f7gwk:p-65qc2"
}

variable "strapi_dashboard_jwt_secret" {
  description = "This secret is needed to sign JWT tokens. Set it to a random value"
  type        = string
}
