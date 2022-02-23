resource "google_storage_bucket" "clvqa-storage-bucket" {
  name          = "clvqa-storage-bucket"
  location      = "EU"
  force_destroy = true

  uniform_bucket_level_access = false        #CKV_GCP_29
  logging {
        //log_bucket = none                          
		log_bucket = "clvqa-storage-bucket"          #CKV_GCP_63
	 }
}

resource "google_storage_bucket_iam_binding" "binding" {
  bucket = google_storage_bucket.clvqa-storage-bucket.name
  role = "roles/storage.admin"
  members = [
    "allUsers",                           #CKV_GCP_28
	"allAuthenticatedUsers"               #CKV_GCP_28
  ]
}

resource "google_storage_bucket_iam_member" "member" {
  bucket = google_storage_bucket.clvqa-storage-bucket.name
  role = "roles/storage.admin"
  member = "allUsers"                             #CKV_GCP_28
  //member = "allAuthenticatedUsers"                #CKV_GCP_28
}