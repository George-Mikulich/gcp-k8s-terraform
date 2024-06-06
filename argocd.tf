provider "helm" {
  kubernetes {
    config_path = "~/.kube/config" ## issues? (old config may be loaded)
  }
}

resource "helm_release" "argocd" {
  name  = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "7.1.1"
  create_namespace = true

  values = [
    file("argocd/app.yaml")
  ]
}