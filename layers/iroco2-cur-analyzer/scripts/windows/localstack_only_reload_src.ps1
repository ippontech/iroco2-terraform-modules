# Variables
$sourceDir = ".\src"
$targetDir = ".\cur_processor\src"

# Check if the target directory exists
if (Test-Path -Path $targetDir) {
    # Delete the target directory
    Remove-Item -Path $targetDir -Recurse -Force
    Write-Output "Target directory deleted: $targetDir"
} else {
    Write-Output "Target directory does not exist: $targetDir"
}

# Copy the source directory to the destination
Copy-Item -Path $sourceDir -Destination $targetDir -Recurse
Write-Output "Source directory copied to target directory: $sourceDir -> $targetDir"

Set-Location cur_processor
zip -r src.zip .

# Variables
$FunctionName = "lambda-cur-processor-iroco2"
$LocalZipFile = "src.zip"

# Update the Lambda function code from a local zip file
aws lambda update-function-code --function-name $FunctionName --zip-file fileb://$LocalZipFile

Set-Location ..

Write-Output "Update of Lambda function $FunctionName complete."
