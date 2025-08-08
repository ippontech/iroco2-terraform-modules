# Copyright 2025 Ippon Technologies
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

resource "aws_ssm_parameter" "docs-cloudfront-bucket-id" {
  name  = upper("/${var.namespace}/PARAMETERS/FRONTEND/DOCUMENTATION_CLOUDFRONT_BUCKET_ID")
  type  = "SecureString"
  value = aws_s3_bucket.docs_bucket.id
}

resource "aws_ssm_parameter" "docs-cloudfront-distribution-id" {
  name  = upper("/${var.namespace}/PARAMETERS/FRONTEND/DOCUMENTATION_CLOUDFRONT_DISTRIBUTION_ID")
  type  = "SecureString"
  value = aws_cloudfront_distribution.docs_distribution.id
}