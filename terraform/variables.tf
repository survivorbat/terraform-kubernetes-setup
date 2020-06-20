variable "domain_name" {
  type    = string
  default = "__domainName__"
}

variable "api_token" {
  type    = string
  default = "__apiToken__"
}

variable "kubernetes_min_nodes" {
  type    = number
  default = "__kubernetesMinNodeCount__"
}

variable "kubernetes_max_nodes" {
  type    = number
  default = "__kubernetesMaxNodeCount__"
}

variable "kubernetes_node_size" {
  type    = string
  default = "__kubernetesNodeSize__"
}

variable "database_node_count" {
  type    = number
  default = "__databaseNodeCount__"
}

variable "database_size" {
  type    = string
  default = "__databaseSize__"
}

variable "region" {
  type    = string
  default = "__region__"
}

variable "namespace_name" {
  type    = string
  default = "__namespaceName__"
}
