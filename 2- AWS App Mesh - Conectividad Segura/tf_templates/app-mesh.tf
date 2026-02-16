resource "aws_appmesh_mesh" "main" {
  name = "${var.project_id}-mesh"
  spec {
    #Se establece un criterio para que ningun recurso pueda interactuar con otro que este fuera de la app mesh
    egress_filter {
      type = "DROP_ALL"
    }
  }
}

resource "aws_appmesh_virtual_node" "api_customer" {
  name      = "api-customer-vn"
  mesh_name = aws_appmesh_mesh.main.name

  spec {
    backend_defaults {
      client_policy {
        tls {
          enforce = true
          validation {
            trust {
              acm {
                certificate_authority_arns = [var.acm_certificate_arn]
              }
            }
          }
        }
      }
    }
    listener {
      port_mapping {
        port     = 8080
        protocol = "http"
      }

      tls {
        mode = "STRICT"

        # Certificado del Servidor (Identidad de este nodo)
        certificate {
          acm {
            certificate_arn = var.acm_certificate_arn
          }
        }
        validation {
          subject_alternative_names {
            match {
              exact = ["client-service.local"]
            }
          }
          trust {
            file {
              certificate_chain = "/etc/pki/tls/certs/ca-bundle.crt"
            }
          }
        }
      }
    }

    service_discovery {
      dns {
        hostname = "api-customer.default.svc.cluster.local"
      }
    }
  }
}