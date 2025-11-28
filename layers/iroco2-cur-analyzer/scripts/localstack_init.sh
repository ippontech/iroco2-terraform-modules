#!/usr/bin/env bash

set -o errexit # This flag is a MUST HAVE!

GIT_ROOT=$(git rev-parse --show-toplevel)
LAMBDA_BUCKET_NAME="lambda-cur-iroco2-local"

start_containers() {
  echo "Starting local stack containers..."
  if command -v podman; then
    podman compose up -d
  else
    docker compose up -d
  fi

}

deploy_lambda() {
  # Build Python dependencies and zip sources
  python3 -m venv venv
  . venv/bin/activate
  mkdir -p cur_processor
  cp -r src cur_processor/
  pip install --platform manylinux2014_x86_64 --target cur_processor/ -r requirements.txt --only-binary=:all:
  cd cur_processor
  zip -r src.zip .

  aws --endpoint-url="$AWS_ENDPOINT_URL" --region="$AWS_REGION" s3 cp ../cur_processor/src.zip s3://$LAMBDA_BUCKET_NAME/lambda/cur/iroco2/cur_processor --checksum-algorithm SHA256

  aws --endpoint-url="$AWS_ENDPOINT_URL" --region="$AWS_REGION" lambda update-function-code \
      --function-name lambda-cur-processor-iroco2 \
      --s3-bucket $LAMBDA_BUCKET_NAME \
      --s3-key lambda/cur/iroco2/cur_processor
      --no-cli-pager
  deactivate
}

# Moves to root repository
pushd "$GIT_ROOT"

echo "Setting environment variables"
export AWS_REGION="eu-west-3"
export AWS_ACCESS_KEY_ID="test"
export AWS_SECRET_ACCESS_KEY="test"
export AWS_ENDPOINT_URL="http://localhost:4566"

# Start docker compose stack
start_containers

pushd "$GIT_ROOT/tf"
terraform init -reconfigure
terraform apply -var-file="tfvars/local.tfvars" -var-file="env-configs/local.tfvars" -auto-approve

popd

deploy_lambda

# Reset for the user
popd

