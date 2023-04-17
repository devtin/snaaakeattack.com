#!/bin/bash

set -e

DOMAIN="snaaakeattack.com"

# Create S3 bucket
BUCKET_NAME="${DOMAIN}-$(date +%s)"
aws s3api create-bucket --bucket "${BUCKET_NAME}" --region us-east-1

# Enable static website hosting
aws s3api put-bucket-website \
  --bucket "${BUCKET_NAME}" \
  --website-configuration '{"IndexDocument": {"Suffix": "index.html"}}'

# Update S3 bucket policy to allow public read access
BUCKET_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${BUCKET_NAME}/*"
    }
  ]
}
EOF
)

aws s3api put-bucket-policy \
  --bucket "${BUCKET_NAME}" \
  --policy "${BUCKET_POLICY}"

# Sync files to S3 bucket
aws s3 sync . "s3://${BUCKET_NAME}" \
  --exclude "*" \
  --include "index.html" \
  --include "logo.png" \
  --acl public-read

echo "Game deployed! Access it at http://${BUCKET_NAME}.s3-website-us-east-1.amazonaws.com"
