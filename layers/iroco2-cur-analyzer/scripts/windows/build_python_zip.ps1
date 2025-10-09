python3.11 -m venv venv
.\venv\Scripts\Activate.ps1
Remove-Item -Recurse cur_processor
New-Item -ItemType Directory -Path cur_processor
Copy-Item -Path ".\src" -Destination ".\cur_processor\" -Recurse
pip install --platform manylinux2014_x86_64 --target .\cur_processor\ -r requirements.txt --only-binary=:all:
Set-Location cur_processor
zip -r src.zip .
deactivate