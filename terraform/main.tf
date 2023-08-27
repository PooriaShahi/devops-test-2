resource "helm_release" "wp-app" {
  name       = var.name
  chart      = var.chart

  set {
    name  = "wordpress.image"
    value = var.wordpress.name
  }
}