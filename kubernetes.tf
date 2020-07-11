provider "kubernetes" {
  load_config_file       = false
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "scalable-nginx-example"
    labels = {
      App = "ScalableNginxExample"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "ScalableNginxExample"
      }
    }
    template {
      metadata {
        labels = {
          App = "ScalableNginxExample"
        }
      }
      spec {
        container {
          image = "nginx:1.7.8"
          name  = "example"

          port {
            container_port = 80
          }

          resources {
            limits {
              cpu    = "0.5"
              memory = "100Mi"
            }
            requests {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
        node_selector = {
              "kubernetes.io/os" = "linux"
        }
      }
    }
  }
}
resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx-example"
  }
  spec {
    selector = {
      App = kubernetes_deployment.nginx.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
output "lb_ip" {
  value = kubernetes_service.nginx.load_balancer_ingress[0].hostname
}

/*
resource "kubernetes_deployment" "win-dep" {
  metadata {
    name = "win-example"
    labels = {
      App = "WinExample"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "WinExample"
      }
    }
    template {
      metadata {
        labels = {
          App = "WinExample"
        }
      }
      spec {
        node_selector = {
          os = "windows"
        }
        container {
          image = "mcr.microsoft.com/windows/servercore:1809"
          name  = "example"
          command = ["powershell.exe", "-command", "Add-WindowsFeature Web-Server; Invoke-WebRequest -UseBasicParsing -Uri 'https://dotnetbinaries.blob.core.windows.net/servicemonitor/2.0.1.6/ServiceMonitor.exe' -OutFile 'C:\\ServiceMonitor.exe'; echo '<html><body><br/><br/><marquee><H1>Hello EKS!!!<H1><marquee></body><html>' > C:\\inetpub\\wwwroot\\default.html; C:\\ServiceMonitor.exe 'w3svc';"]

          port {
            container_port = 80
          }

          resources {
            limits {
              cpu    = "0.5"
              memory = "100Mi"
            }
            requests {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}
*/
