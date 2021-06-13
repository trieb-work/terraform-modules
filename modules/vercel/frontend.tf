
resource "vercel_project" "frontend" {
  team_id = data.vercel_team.triebwork.id
  name    = lower("${var.project}-frontend")
  git_repository {
    type = "github"
    repo = var.repo
  }
  framework       = "nextjs"
  root_directory  = "frontend"
  install_command = "yarn --cwd=.. install && yarn install"
  #  commands are relative to `root_directory` from above
  # We must use npx for the export because yarn will print its version number
  # and mess up the exported value
  build_command = <<-EOF
    npx ts-node ../deployment/scripts/wait-for-strapi.ts &&
    export STRAPI_API_URL=$(npx ts-node ../deployment/scripts/return_api_url.ts) && 
    yarn build
    EOF
}


resource "vercel_env" "frontend_strapi_api_url_template" {
  team_id    = data.vercel_team.triebwork.id
  project_id = vercel_project.frontend.id
  type       = "plain"
  target     = ["production", "preview", "development"]
  key        = "STRAPI_API_URL_TEMPLATE"

  value = var.strapi_api_domain_template
}


resource "vercel_env" "frontend_preview_secret" {
  team_id    = data.vercel_team.triebwork.id
  project_id = vercel_project.frontend.id
  type       = "plain"
  target     = ["production", "preview", "development"]
  key        = "PREVIEW_SECRET"

  value = "4444"
}

