# Running the lambda locally

To test the lambda locally, we will deploy it on a local LocalStack instance.

### Prerequisites

- Python 3.11
- Terraform
- zip
- aws-cli

You can install these dependencies with Chocolatey.
To install Chocolatey, run your PowerShell as an administrator and execute:
```Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))```

Then, to install the different dependencies, simply run:

```choco install python311``` \
```choco install terraform``` \
```choco install zip``` \
```choco install awscli```

The three utility scripts to help you deploy the lambda locally are:
- localstack_init.ps1
- localstack_reload.ps1
- localstack_only_reload_src.ps1

1. The first one (localstack_init.ps1) must be run at least once. It will initialize the LocalStack Docker container and create the AWS environment with buckets, SQS queues, and the lambda (as well as the lambda trigger) via Terraform (the same one used to deploy on AWS).
2. The second one (localstack_reload) will only update the lambda with the source code (in src) and by regenerating the dependencies.
3. The third one (localstack_only_reload_src) will update the lambda from the source code (src) without regenerating the dependencies; it is faster than the previous one.