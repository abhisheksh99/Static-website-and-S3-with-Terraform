
# Static Website on AWS S3 with Terraform

This project provides the configuration and resources necessary to deploy a static website to AWS S3 using Terraform. The setup includes creating an S3 bucket, configuring it for static website hosting, and setting public access and permissions for files such as `index.html` and `error.html`.

## Prerequisites

Before you begin, ensure you have the following installed and configured on your local environment:

- **Terraform**: Download and install Terraform from the [official website](https://www.terraform.io/downloads.html).
- **AWS CLI**: Download and install the AWS CLI from [here](https://aws.amazon.com/cli/).
- **AWS Account**: Access to an AWS account with permissions to create and manage S3 buckets and IAM roles/policies.

### AWS CLI Configuration

To configure your AWS CLI with credentials, run the following command:

```bash
aws configure
```

You will be prompted to enter your `AWS Access Key`, `Secret Key`, and `Default Region`. This project assumes the `us-east-1` region, but you can adjust this as needed.

## Project Structure

The project includes the following key files:

- `main.tf`: The main Terraform file that configures the AWS S3 bucket and its settings.
- `variables.tf`: File to define variables used within the Terraform configuration, such as `bucket_name`.
- `index.html`: The homepage of the static website.
- `error.html`: A custom error page.
- `profile.png`: A sample image to be displayed on the website.
- `README.md`: This guide.

## Configuration Overview

This Terraform configuration performs the following tasks:

1. **Creates an S3 Bucket**: Sets up an S3 bucket with a specified name for hosting the static website.
2. **Configures Ownership Controls**: Ensures that the bucket owner has control over all objects stored within the bucket.
3. **Public Access Configuration**: Sets up public-read access on the bucket to allow website visitors to access the files.
4. **Static Website Hosting**: Enables static website hosting on the bucket, specifying `index.html` as the main page and `error.html` as the error page.
5. **Uploads Website Files**: Uploads `index.html`, `error.html`, and `profile.png` to the S3 bucket, making them accessible through the public website URL.

## Step-by-Step Setup Guide

### 1. Clone the Repository

Clone the repository or download the project files to your local machine.

```bash
git clone <repository-url>
cd Static-Website-and-S3-with-Terraform
```

### 2. Initialize Terraform

In the project directory, initialize Terraform to download the necessary provider plugins:

```bash
terraform init
```

### 3. Customize Variables (Optional)

Open `variables.tf` and update the `bucket_name` variable with your desired S3 bucket name:

```hcl
variable "bucket_name" {
  default = "your-unique-bucket-name"
  description = "The name of the S3 bucket for static website hosting"
}
```

Alternatively, you can specify the bucket name during `apply` by using the `-var` flag.

### 4. Review the Terraform Plan

Before applying the configuration, run `terraform plan` to review the resources that Terraform will create:

```bash
terraform plan
```

Verify the output and ensure the resources match your expectations.

### 5. Deploy the Infrastructure

Apply the configuration to create the S3 bucket and configure it for static website hosting:

```bash
terraform apply
```

Terraform will prompt for confirmation. Type `yes` to proceed.

### 6. Verify the S3 Website

Once the resources are created, you can verify the static website by following these steps:

1. Go to the AWS Management Console.
2. Navigate to the S3 service and select the created bucket.
3. In the **Properties** tab, locate **Static website hosting**.
4. Copy the **Bucket website endpoint** URL and open it in your browser. You should see the content from `index.html`.

### 7. Clean Up Resources

To avoid AWS charges, you can destroy the infrastructure when it’s no longer needed:

```bash
terraform destroy
```

Type `yes` to confirm the deletion.

## Detailed Explanation of Terraform Resources

### main.tf

This file contains the Terraform configuration to create and configure an S3 bucket.

```hcl
# Create an S3 bucket
resource "aws_s3_bucket" "static_website_bucket" {
  bucket = var.bucket_name
}

# Set bucket ownership controls
resource "aws_s3_bucket_ownership_controls" "ownership_controls" {
  bucket = aws_s3_bucket.static_website_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Set bucket ACL to allow public read access
resource "aws_s3_bucket_acl" "bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.ownership_controls]
  bucket = aws_s3_bucket.static_website_bucket.id
  acl = "public-read"
}

# Upload index.html file
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.static_website_bucket.id
  key = "index.html"
  source = "index.html"
  acl = "public-read"
  content_type = "text/html"
}

# Upload error.html file
resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.static_website_bucket.id
  key = "error.html"
  source = "error.html"
  acl = "public-read"
  content_type = "text/html"
}

# Upload profile.png image
resource "aws_s3_object" "image" {
  bucket = aws_s3_bucket.static_website_bucket.id
  key = "profile.png"
  source = "profile.png"
  acl = "public-read"
  content_type = "image/png"
}

# Configure static website hosting
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.static_website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  depends_on = [aws_s3_bucket_acl.bucket_acl]
}
```

### variables.tf

This file defines the variables used in the Terraform configuration:

```hcl
variable "bucket_name" {
  default = "your-unique-bucket-name"
  description = "The name of the S3 bucket for static website hosting"
}
```

## Accessing the Website

After deploying, you can access your static website using the URL shown in the **Static website hosting** section of your S3 bucket properties in the AWS Console.

### Example URL

```
http://your-unique-bucket-name.s3-website-us-east-1.amazonaws.com
```

Replace `your-unique-bucket-name` and `us-east-1` with your actual bucket name and region.

## Troubleshooting

- **Permission Errors**: Ensure the `aws_s3_bucket_acl` resource is set to `public-read`.
- **Missing Website URL**: Verify that `aws_s3_bucket_website_configuration` is applied correctly in the AWS Console.
- **404 Not Found**: Confirm that `index.html` and `error.html` have been uploaded correctly to the bucket.

