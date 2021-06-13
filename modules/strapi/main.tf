


resource "kubernetes_namespace" "strapi_backend" {
  metadata {
    name = var.id
    annotations = {
      "field.cattle.io/projectId" = var.rancher_project_id
    }
  }
  lifecycle {
    ignore_changes = [
      metadata[0].annotations["cattle.io/status"],
      metadata[0].annotations["lifecycle.cattle.io/create.namespace-auth"],
      metadata[0].labels["field.cattle.io/projectId"]
    ]
  }
}

resource "kubernetes_secret" "strapi_backend_secret" {
  metadata {
    name      = "strapi-backend-api-secret"
    namespace = kubernetes_namespace.strapi_backend.metadata.0.name
  }

  data = {
    DASHBOARD_URL    = "https://${var.dashboard_domain}"
    DATABASE_URL     = var.database_url
    STRAPI_API_URL   = "https://${var.api_domain}"
    ADMIN_JWT_SECRET = var.strapi_dashboard_jwt_secret
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations["cattle.io/status"],
      metadata[0].annotations["field.cattle.io/projectId"]
    ]
  }
}

resource "kubernetes_deployment" "strapi_backend" {
  metadata {
    name      = "strapi-backend-api"
    namespace = kubernetes_namespace.strapi_backend.metadata.0.name
    labels = {
      app = var.id
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.id
      }
    }

    template {
      metadata {
        labels = {
          app = var.id
        }
      }

      spec {
        container {
          image = var.docker_image
          name  = var.id

          resources {
            limits = {
              cpu    = "350m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.strapi_backend_secret.metadata.0.name
            }
          }

          port {
            container_port = 1337
            name           = "web"
          }

          liveness_probe {
            http_get {
              path = "/_health"
              port = 1337
            }

            initial_delay_seconds = 30
            period_seconds        = 5
            timeout_seconds       = 5
          }

          readiness_probe {
            http_get {
              path = "/_health"
              port = 1337
            }

            initial_delay_seconds = 20
            period_seconds        = 5
            timeout_seconds       = 5
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations["field.cattle.io/publicEndpoints"],
      metadata[0].annotations["cattle.io/status"]
    ]
  }
}


resource "kubernetes_service" "strapi_backend_service" {
  metadata {
    name      = "strapi-api-service"
    namespace = kubernetes_namespace.strapi_backend.metadata.0.name
  }
  spec {
    selector = {
      app = kubernetes_deployment.strapi_backend.metadata.0.labels.app
    }
    session_affinity = "None"
    port {
      port        = 1337
      target_port = 1337
    }

    type = "ClusterIP"
  }
}



resource "kubernetes_ingress" "strapi_backend_ingress" {
  metadata {
    name      = "strapi-api-ingress"
    namespace = kubernetes_namespace.strapi_backend.metadata.0.name
    annotations = {
      "cert-manager.io/cluster-issuer"                     = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/cors-allow-credentials" = "true"
      "nginx.ingress.kubernetes.io/cors-allow-methods"     = "PUT, GET, POST, OPTIONS"
      "nginx.ingress.kubernetes.io/cors-allow-origin"      = "https://${var.domain},https://${var.dashboard_domain}"
      "nginx.ingress.kubernetes.io/enable-cors"            = "true"
    }
  }

  spec {
    rule {
      host = var.api_domain
      http {
        path {
          backend {
            service_name = "strapi-api-service"
            service_port = 1337
          }
        }
      }
    }

    tls {
      hosts       = [var.api_domain]
      secret_name = "strapi-api-tls"
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations["field.cattle.io/publicEndpoints"],
      metadata[0].annotations["cattle.io/status"]
    ]
  }
}


