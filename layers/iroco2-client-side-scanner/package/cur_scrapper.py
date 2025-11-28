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

from s3_repository_parser import S3Repository
from ec2_service import CurProcessorEC2Service
from s3_service import CurProcessorS3Service
from iroco_service import IrocoService

class CurProcessorService:

    def __init__(self):
        self.s3_repository = S3Repository()
        self.cur_processor_ec2_service = CurProcessorEC2Service()
        self.cur_processor_s3_service = CurProcessorS3Service()
        self.iroco_service = IrocoService()

    def parsing_cur_and_send_to_api(self, bucket_name, s3_file_name):
        cur_file_type = os.path.splitext(s3_file_name)[1].replace(".", "")
        print(cur_file_type)
        cur = self.s3_repository.read_file(bucket_name, urllib.parse.unquote_plus(s3_file_name))
        message_parsed = []
        parsed_ec2_message = self.cur_processor_ec2_service.creating_message_from_cur(cur, cur_file_type)
        print(f'EC2 messages: {parsed_ec2_message}')
        parsed_s3_message = self.cur_processor_s3_service.creating_message_from_cur(cur, cur_file_type)
        print(f'S3 messages: {parsed_s3_message}')
        message_parsed.extend(parsed_ec2_message)
        message_parsed.extend(parsed_s3_message)
        self.__send_message_parsed_to_api(message_parsed)

    def __send_message_parsed_to_api(self, messages_parsed):
        total_message_sent = len(messages_parsed)
        correlation_id = self.iroco_service.create_scan()

        for message_parsed in messages_parsed:
            message_parsed["numberOfMessageExpected"] = total_message_sent
            message_parsed["correlationId"] = correlation_id
            self.iroco_service.send_payload(message_parsed)

def handler(event,context):
    print(f"Event Name: {event['Records'][0]['eventName']}")
    print(f"S3 Bucket Name: {event['Records'][0]['s3']['bucket']['name']}")
    print(f"Object Key: {event['Records'][0]['s3']['object']['key']}")
    print(f"Event: {event}")
    cur_processor_service = CurProcessorService()
    cur_processor_service.parsing_cur_and_send_to_api(
        bucket_name=event['Records'][0]['s3']['bucket']['name'],
        s3_file_name=event['Records'][0]['s3']['object']['key'],
    )
