# A Service Account to do the work
resource "google_service_account" "function_worker" {
  account_id = "function-worker"
  display_name = "Function Worker"
}

# The project service of the function
resource "google_project_service" "cloudfunctions" {
  service = "cloudfunctions.googleapis.com"
  disable_on_destroy = false
}