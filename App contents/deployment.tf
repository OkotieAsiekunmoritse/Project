resource "kubernetes_deployment" "mo-project-deployment" {
  metadata {
    name = "deployment"
    labels = {
      test = "MyWebApp"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        test = "MyWebApp"
      }
    }

    template {
      metadata {
        labels = {
          test = "MyWebApp"
        }
      }

      spec {
        container {
          image = "moritse/dockerhub:mydemo"
          name  = "mywebapp"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80

              http_header {
                name  = "My Webapp"
                value = "Deployed from kubernetes"
              }
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}