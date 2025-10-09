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
import boto3

class S3Repository:

    def __init__(self):
        self.s3_ressource = boto3.resource('s3')

    def read_file(self, bucket_name: str, key_to_read: str):
        obj = self.s3_ressource.Object(bucket_name, key_to_read)
        response = obj.get()
        raw_content = response['Body'].read()
        return raw_content

