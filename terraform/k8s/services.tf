resource "kubernetes_service" "app-master" {
    metadata {
        name = "app-master"
    }

    spec {
        selector = {
          app  = "bankingOnSpringboot"
        }
        port {
            name        = "http"
            port        = 80
            target_port = 8080
        }

        port {
            name        = "db-port"
            port        = 3306
            target_port = 3306
        }

        port {
            port        = 8080
            target_port = 8080
            name        = "app-port"
        }

        type = "LoadBalancer"
    }
  
}
