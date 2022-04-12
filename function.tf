# The Cloud Function
resource "google_cloudfunctions_function" "function" {
  name = local.function_name
  description = "A simple hello world function"
  runtime = "go116"
  region = var.region

  available_memory_mb = 128
  source_archive_bucket = google_storage_bucket.source.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http = true
  entry_point = "HelloWorld"
  service_account_email = google_service_account.function_worker.email

  depends_on = [google_project_service.cloudfunctions]
}

# A dedicated Cloud Storage bucket for the function source code as a zip file
resource "google_storage_bucket" "source" {
  name = "${var.project}-source"
  location = "US"
}

# Create a fresh archive of the current function folder
data "archive_file" "function" {
  output_path = "temp/function_code_${timestamp()}.zip"
  type        = "zip"
  source_dir = local.function_folder
}

# The archive in the Cloud Storage bucket uses the md5 of the zip file
# This ensures the Function is redeployed only when the source is changed
resource "google_storage_bucket_object" "archive" {
  name   = "${local.function_folder}_${data.archive_file.function.output_md5}.zip"
  bucket = google_storage_bucket.source.name
  source = data.archive_file.function.output_path

  depends_on = [data.archive_file.function]
}


# IAM entry for all users to invoke the function
# if not present, the function will be private by default
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project = google_cloudfunctions_function.function.project
  region = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role = "roles/cloudfunctions.invoker"
  member = "allUsers"
}