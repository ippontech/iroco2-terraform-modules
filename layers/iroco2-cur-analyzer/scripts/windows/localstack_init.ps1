# Start docker compose stack
docker-compose up -d

$env:AWS_REGION = "eu-west-3"

# Set AWS environment variables to localstack
$env:AWS_ACCESS_KEY_ID = "test"
$env:AWS_SECRET_ACCESS_KEY = "test"
$env:AWS_ENDPOINT_URL = "http://localhost:4566"

# Create mock Lambda layers so Terraform does not throw an error (Localstack free version does not handle real layers)
Compress-Archive -Path .\README.md -DestinationPath _mock_layer.zip

aws lambda publish-layer-version --layer-name boto3 `
    --description "Mock layer" `
    --license-info "MIT" `
    --zip-file fileb://_mock_layer.zip `
    --compatible-runtimes python3.11 `
    --compatible-architectures "arm64" "x86_64" `
    --region eu-west-3 `
    --no-cli-pager

aws lambda publish-layer-version --layer-name pandas `
    --description "Mock layer" `
    --license-info "MIT" `
    --zip-file fileb://_mock_layer.zip `
    --compatible-runtimes python3.11 `
    --compatible-architectures "arm64" "x86_64" `
    --region eu-west-3 `
    --no-cli-pager

aws lambda publish-layer-version --layer-name numpy `
    --description "Mock layer" `
    --license-info "MIT" `
    --zip-file fileb://_mock_layer.zip `
    --compatible-runtimes python3.11 `
    --compatible-architectures "arm64" "x86_64" `
    --region eu-west-3 `
    --no-cli-pager

aws lambda publish-layer-version --layer-name isodate `
    --description "Mock layer" `
    --license-info "MIT" `
    --zip-file fileb://_mock_layer.zip `
    --compatible-runtimes python3.11 `
    --compatible-architectures "arm64" "x86_64" `
    --region eu-west-3 `
    --no-cli-pager

aws lambda publish-layer-version --layer-name fastparquet `
    --description "Mock layer" `
    --license-info "MIT" `
    --zip-file fileb://_mock_layer.zip `
    --compatible-runtimes python3.11 `
    --compatible-architectures "arm64" "x86_64" `
    --region eu-west-3 `
    --no-cli-pager

Remove-Item _mock_layer.zip

# Build Python dependencies and zip sources
.\scripts\windows\build_python_zip.ps1

# Init and deploy with Terraform scripts
Set-Location -Path ../tf/
terraform init -reconfigure
terraform apply -var-file="tfvars/local.tfvars" -auto-approve -var="environment=ppr"

aws s3 cp ../cur_processor/src.zip s3://lambda-cur-iroco2-ppr/lambda/cur/iroco2/cur_processor

aws lambda update-function-code `
    "--function-name" "lambda-cur-processor-iroco2" `
    "--s3-bucket" "lambda-cur-iroco2-ppr" `
    "--s3-key" "lambda/cur/iroco2/cur_processor"

Set-Location -Path ..\
#Remove-Item -Recurse cur_processor
