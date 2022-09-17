provider "google" {
    project = "PROJECT-ID"
}

resource "google_artifact_registry_repository" "my-repo" {
  provider = google-beta

  location = var.region
  repository_id = "${var.project_id}-gke"
  description   = "Docker Registry for GKE"
  format        = "DOCKER"
}
