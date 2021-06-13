

variable "repo" {
  type = string
}


variable "domain" {
  description = "The https endpoint where the webpage is reachable"
  type        = string
}

variable "strapi_api_domain_template" {
  description = "Example: api.#BRANCH_NAME.testdomain.de - must include '#BRANCH_NAME' and should not contain https://"
  type        = string
}


variable "vercel_token" {
  description = "Get one here https://vercel.com/account/tokens"
  type        = string
  sensitive   = true
}


variable "root_dir" {
  description = "The root directory of this repository"
  type        = string
}


variable "project" {
  description = "A unique name used to differentiate this project from others in kubernetes"
  type        = string
}



variable "strapi_dashboard_domain" {
  type = string
}