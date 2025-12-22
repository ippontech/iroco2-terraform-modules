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
output "analyzer_sqs_cur_name" {
  value       = aws_sqs_queue.analyzer_sqs_queue.name
  description = "The name of the SQS queue for the analyzer"
}

output "analyzer_sqs_cur_url" {
  value       = aws_sqs_queue.analyzer_sqs_queue.url
  description = "The url of the SQS queue for the analyzer"
}

output "scanner_sqs_cur_name" {
  value       = aws_sqs_queue.scanner_sqs_queue.name
  description = "The name of the SQS queue for the scanner"
}

output "scanner_sqs_cur_url" {
  value       = aws_sqs_queue.scanner_sqs_queue.url
  description = "The url of the SQS queue for the scanner"
}

output "s3_cur_bucket_id" {
  value       = aws_s3_bucket.cur_s3_bucket.id
  description = "The ID of the S3 bucket for the CUR"
}

output "s3_cur_bucket_arn" {
  value       = aws_s3_bucket.cur_s3_bucket.arn
  description = "The ARN of the S3 bucket for the CUR"
}
