provider "google" {
    project = var.project
    region = var.region
    zone = var.zone
}

resource "google_monitoring_notification_channel" "slack-channel" {
  display_name = "Test Slack Channel"
  type         = "slack"
  description = "Terraform configured notification channel"
  labels = {
    "channel_name" = "#test"
  }
  sensitive_labels {
    auth_token = var.slack_token
  }
}