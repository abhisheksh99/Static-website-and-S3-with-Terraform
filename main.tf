# Create an S3 bucket
resource "aws_s3_bucket" "static_website_bucket" {
  bucket = var.bucketname
}

# Set bucket ownership controls
resource "aws_s3_bucket_ownership_controls" "ownership_controls" {
  # Link the ownership controls to the created bucket
  bucket = aws_s3_bucket.static_website_bucket.id

  # Define the ownership rule
  rule {
    object_ownership = "BucketOwnerPreferred" # Ensures the bucket owner takes control of all objects
  }
}

# Set bucket ACL to allow public read access
resource "aws_s3_bucket_acl" "bucket_acl" {
  # Define dependencies to ensure ownership controls are set before the ACL
  depends_on = [aws_s3_bucket_ownership_controls.ownership_controls]

  # Link the ACL to the created bucket
  bucket = aws_s3_bucket.static_website_bucket.id

  # Set access control list to public read
  acl = "public-read" # Allows public read access to the bucket contents
}

# Upload index.html file to the bucket
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.static_website_bucket.id
  key    = "index.html"           # S3 object key (filename)
  source = "index.html"           # Local file to upload
  acl    = "public-read"          # Set ACL to public read for website access
  content_type = "text/html"      # Set content type to HTML
}

# Upload error.html file to the bucket
resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.static_website_bucket.id
  key    = "error.html"           # S3 object key (filename)
  source = "error.html"           # Local file to upload
  acl    = "public-read"          # Set ACL to public read for website access
  content_type = "text/html"      # Set content type to HTML
}

# Upload profile.png image to the bucket
resource "aws_s3_object" "image" {
  bucket = aws_s3_bucket.static_website_bucket.id
  key    = "profile.png"          # S3 object key (filename)
  source = "profile.png"          # Local file to upload
  acl    = "public-read"          # Set ACL to public read for website access
  content_type = "image/png"      # Set content type for image file
}

# Configure the bucket as a static website
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.static_website_bucket.id

  # Specify index document
  index_document {
    suffix = "index.html"         # Default file to serve
  }

  # Specify error document
  error_document {
    key = "error.html"            # File to serve in case of an error
  }

  # Ensure dependencies are set
  depends_on = [aws_s3_bucket_acl.bucket_acl]
}
