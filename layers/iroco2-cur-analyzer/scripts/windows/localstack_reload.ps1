.\scripts\windows\build_python_zip.ps1

# Variables
$FunctionName = "lambda-cur-processor-iroco2"
$LocalZipFile = ".\src.zip"

# Update the Lambda function code from a local zip file
aws lambda update-function-code --function-name $FunctionName --zip-file fileb://$LocalZipFile

Set-Location ..

Write-Output "Update of Lambda function $FunctionName complete."
