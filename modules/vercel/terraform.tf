terraform {
  required_providers {
    vercel = {
      source  = "chronark/vercel"
      version = ">=0.8.1"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }
  }
}