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
import os
import boto3


class SQSRepository:
    def __init__(self):
        self.sqs_client = boto3.client(
            'sqs',        
            region_name=os.environ.get('REGION')                
        )

    def send_message(self, queue_url: str, message_body: str):
    
        response = self.sqs_client.send_message(
            QueueUrl=queue_url,
            MessageBody=message_body
        )
        return response
