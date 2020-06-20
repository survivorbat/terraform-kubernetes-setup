# Provider to connect to DO
provider "digitalocean" {
  token = var.api_token
}

# Project that will contain all our resources

resource "digitalocean_project" "project" {
  name        = "Example"

  resources = [
    digitalocean_domain.domain.urn,
    digitalocean_database_cluster.database.urn,
    "do:kubernetes:${digitalocean_kubernetes_cluster.kubernetes_cluster.id}"
  ]
}

# The domain

resource "digitalocean_domain" "domain" {
  name = var.domain_name
}

# Record to point to the load balancer

resource "digitalocean_record" "record_a" {
  domain = digitalocean_domain.domain.id
  name   = "@"
  type   = "A"
  value  = kubernetes_ingress.ingress.load_balancer_ingress[0].ip
}

resource "digitalocean_record" "record_a_subdomains" {
  domain = digitalocean_domain.domain.id
  name   = "*"
  type   = "A"
  value  = kubernetes_ingress.ingress.load_balancer_ingress[0].ip
}

# Database cluster for all our data

resource "digitalocean_database_cluster" "database" {
  engine     = "mysql"
  name       = "exampledatabase"
  node_count = var.database_node_count
  region     = var.region
  size       = var.database_size
  version    = "8"
}

# Firewall that only allows k8s to connect to this database

resource "digitalocean_database_firewall" "firewall" {
  cluster_id = digitalocean_database_cluster.database.id
  rule {
    type  = "k8s"
    value = digitalocean_kubernetes_cluster.kubernetes_cluster.id
  }
}

# Our main database

resource "digitalocean_database_db" "exampledb" {
  cluster_id = digitalocean_database_cluster.database.id
  name       = "Example"
}

# First user

resource "digitalocean_database_user" "exampleuser" {
  cluster_id = digitalocean_database_cluster.database.id
  name       = "example"
}

# Registry for our containers

resource "digitalocean_container_registry" "container_registry" {
  name = "exampleregistry"
}

# Kubernetes cluster

resource "digitalocean_kubernetes_cluster" "kubernetes_cluster" {
  name    = "examplecluster"
  region  = var.region
  version = "1.15.11-do.0"

  node_pool {
    name       = "main"
    size       = var.kubernetes_node_size
    max_nodes  = var.kubernetes_max_nodes
    auto_scale = true
    min_nodes  = var.kubernetes_min_nodes
  }

  provisioner "local-exec" {
    # Echo kubeconfig and apply ingress
    command = <<EOT
      echo ${jsonencode(digitalocean_kubernetes_cluster.kubernetes_cluster.kube_config)} > .kubeconfig,
      kubectl apply --config .kubeconfig -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud/deploy.yaml
    EOT
  }
}

# Connect to our k8s cluster
# TODO: Prevent it from booting if cluster doesn't exist yet

provider "kubernetes" {
  load_config_file = false
  host             = digitalocean_kubernetes_cluster.kubernetes_cluster.endpoint
  token            = digitalocean_kubernetes_cluster.kubernetes_cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.kubernetes_cluster.kube_config[0].cluster_ca_certificate
  )
}

# Create our main namespace in k8s

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace_name
  }
}

# Create a secret with the database connection string

resource "kubernetes_secret" "database_secret" {
  metadata {
    name      = "database-connection-string"
    namespace = var.namespace_name
  }
  data = {
    connectionString = "Server=${digitalocean_database_cluster.database.private_host};Database=${digitalocean_database_db.exampledb.name};Port=${digitalocean_database_cluster.database.port};User ID=${digitalocean_database_user.exampleuser.name};Password=${digitalocean_database_user.exampleuser.password}"
  }
}

# This account will be able to deploy our separate applications
# Also creating kubernetes secret for pulling images

resource "kubernetes_secret" "docker_pull_secret" {
  metadata {
    name      = "docker-pull-secret"
    namespace = var.namespace_name
  }
}

resource "kubernetes_service_account" "deploy_user" {
  metadata {
    namespace = var.namespace_name
    name      = "deploy-user"
  }

  image_pull_secret {
    name = kubernetes_secret.docker_pull_secret.metadata[0].name
  }

  automount_service_account_token = true
}

# This will be its permissions

resource "kubernetes_cluster_role" "deploy_role" {
  metadata {
    name = "deploy_role"
  }
  rule {
    api_groups = ["", "apps", "extensions"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]

    resources = ["deployments", "pods", "services", "volumes", "persistentvolumeclaims", "secrets", "configmaps", "volumeattachments", "replicasets", "cronjobs"]
  }
}

# Bind this new role to our deploy_user

resource "kubernetes_cluster_role_binding" "deploy_role_binding" {
  metadata {
    name = "deploy_user_binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.deploy_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.deploy_user.metadata[0].name
    namespace = var.namespace_name
  }
}

# This will be our load balancer configuration

# Generate our letsencrypt certificates

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "request" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  # TODO
  email_address = ""
}

resource "acme_certificate" "acme_challenge" {
  account_key_pem = acme_registration.request.account_key_pem
  dns_challenge {
    provider = "digitalocean"
    config = {
      DO_AUTH_TOKEN = var.api_token
    }
  }

  subject_alternative_names = ["*.${var.domain_name}"]
  common_name = var.domain_name
}

resource "kubernetes_secret" "tls_secret" {
  metadata {
    name = "tls-secret"
    namespace = var.namespace_name
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = acme_certificate.acme_challenge.certificate_pem
    "tls.key" = acme_certificate.acme_challenge.private_key_pem
  }
}

resource "kubernetes_ingress" "ingress" {
  metadata {
    name      = "exampleingress"
    namespace = var.namespace_name
    annotations = {
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = true
      "nginx.ingress.kubernetes.io/from-to-www-redirect" = true
      "nginx.ingress.kubernetes.io/ssl-redirect": true
    }
  }

  spec {
    rule {
      host = var.domain_name
      http {
        path {
          backend {
            service_name = "example-frontend"
            service_port = 80
          }

          path = "/"
        }

        path {
          backend {
            service_name = "example-api"
            service_port = 80
          }

          path = "/api"
        }
      }
    }

    tls {
      hosts = [var.domain_name, "*.${var.domain_name}"]
      secret_name = "tls-secret"
    }
  }

  wait_for_load_balancer = true
}
