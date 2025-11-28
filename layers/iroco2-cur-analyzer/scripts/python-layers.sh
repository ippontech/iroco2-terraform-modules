#!/usr/bin/env sh

# This script is used within GitLab CI to create the proper zip file for the lambda layer.

set -o errexit
set -o nounset

if [ -z "$1" ]; then
  echo "Error: Output zip file path is required as the first argument." >&2
  exit 1
fi

OUTPUT_ZIP_PATH=$1

echo "Creating zip file for lambda layers at ${OUTPUT_ZIP_PATH}"

# Create a temporary directory for building the layer to avoid polluting the source tree
BUILD_DIR=$(mktemp -d)

# Create the python directory structure required by Lambda
mkdir -p "${BUILD_DIR}/python"

echo "Installing all dependencies into ${BUILD_DIR}/python"
pip install --platform manylinux2014_x86_64 --only-binary=:all: --target "${BUILD_DIR}/python" -r requirements.txt

echo "Compressing dependencies into ${OUTPUT_ZIP_PATH}"
cd "${BUILD_DIR}/python"
zip -r "${OUTPUT_ZIP_PATH}" .

# Clean up the temporary directory
rm -rf "${BUILD_DIR}"

echo "Layer zip created successfully."
