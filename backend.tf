terraform {
  backend "gcs" {
    bucket = "staging.inlaid-backbone-439613-b9.appspot.com" # Set this to your GCS bucket name
    prefix = "github-actions/test"                           # Set this to a unique path for the state file
  }
}
