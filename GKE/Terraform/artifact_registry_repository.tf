#GCP Artifactory Repository Registry
resource "google_artifact_registry_repository" "my-repo" {
  location      = var.region
  repository_id = "${var.project_id}-gke"
  description   = "Docker Registry for GKE"
  format        = "DOCKER"
}
