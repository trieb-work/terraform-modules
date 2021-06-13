


resource "vercel_project" "dashboard" {
  team_id = data.vercel_team.triebwork.id
  name    = lower("${var.project}-dashboard")
  git_repository {
    type = "github"
    repo = var.repo
  }
  output_directory = "build"
  root_directory   = "backend"
  install_command  = "yarn --cwd=.. install && yarn install"
  # commands are relative to `root_directory` from above
  # We must use npx for the export because yarn will print its version number
  # and mess up the exported value
  build_command = <<-EOF
    npx ts-node ../deployment/scripts/wait-for-strapi.ts &&
    export STRAPI_API_URL=$(npx ts-node ../deployment/scripts/return_api_url.ts) && 
    yarn build
    EOF
}




resource "vercel_env" "dashboard_url" {
  team_id    = data.vercel_team.triebwork.id
  project_id = vercel_project.dashboard.id
  type       = "plain"
  target     = ["production", "preview", "development"]
  key        = "DASHBOARD_URL"
  value      = "https://${var.strapi_dashboard_domain}"
}

resource "vercel_env" "dashboard_strapi_api_url" {
  team_id    = data.vercel_team.triebwork.id
  project_id = vercel_project.dashboard.id
  type       = "plain"
  target     = ["production", "preview", "development"]
  key        = "STRAPI_API_URL_TEMPLATE"

  value = var.strapi_api_domain_template
}

# resource "vercel_env" "dashboard_strapi_jwt_secret" {
#   team_id    = data.vercel_team.triebwork.id
#   project_id = vercel_project.dashboard.id
#   type       = "plain"
#   target     = ["production", "preview", "development"]
#   key        = "ADMIN_JWT_SECRET"

#   value = var.strapi_dashboard_jwt_secret
# }


