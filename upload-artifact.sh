
S3_BUCKET_NAME=""

echo ""
read -p "Enter a unique s3 bucket name [helloworld-lambda-example-32431]: " S3_BUCKET_NAME
S3_BUCKET_NAME=${S3_BUCKET_NAME:-helloworld-lambda-example-32431}

# installing packages
echo ""
echo "Installing packages required..."
echo ""
npm install


# creates lambda artifact
echo ""
echo "Creating lambda artifact..."
echo ""
zip ../helloworld-lambda.zip index.js package.json node_modules/

# creates s3 bucket to upload lambda artifact
echo ""
echo "Creating s3 bucket : $S3_BUCKET_NAME "
echo ""
aws s3api create-bucket --bucket "$S3_BUCKET_NAME" --region us-east-1
  if [ $? -eq 0 ]; then
    echo ""
    echo "Uploading lambda artifact to s3..."
    echo ""
    # uploads lambda artifact to s3 bucket
    aws s3 cp ../helloworld-lambda.zip s3://"$S3_BUCKET_NAME"/v1.0.0/helloworld-lambda.zip
    if [ $? -eq 0 ]; then
      echo ""
      echo "Successfully uploaded lambda artifact to s3..."
      echo ""
      rm ../helloworld-lambda.zip
    else
      echo ""
      echo "Failed to upload lambda artifact to s3 !!"
      echo ""
      exit 1
    fi

  else
    echo "Failed to create s3 bucket : $S3_BUCKET_NAME !!"
    echo ""
    exit 1
  fi
