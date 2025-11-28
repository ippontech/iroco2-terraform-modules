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
import requests

class IrocoService:

    def __init__(self):
        self.api_key = os.environ.get("IROCO2_API_KEY")
        self.iroco_endpoint = os.environ.get("IROCO2_API_ENDPOINT")
        self.gateway_endpoint  = os.environ.get("IROCO2_GATEWAY_ENDPOINT")

    def __build_header(self):
        """
        Build header
        """
        return {
            'Authorization': f"Bearer {self.api_key}",
            'Content-Type': "application/json",
        }

    def create_scan(self):
        """
        Create a scan
        """
        try:
            response = requests.post(self.iroco_endpoint, headers=self.__build_header())
            response.raise_for_status()
        except requests.exceptions.HTTPError as errh:
            print("HTTP Error")
            print(errh)
            return None
        return response.json()

    def send_payload(self, payload):
        """
        Send a payload
        """
        try:
            send_report = requests.post(self.gateway_endpoint, json=payload, headers=self.__build_header())
            send_report.raise_for_status()
            return send_report.status_code
        except requests.exceptions.HTTPError as errh:
            print("HTTP Error")
            print(errh.args[0])
            return send_report.status_code
        except requests.exceptions.ConnectionError as conerr:
            print("Connection error")
            print(conerr)
            return send_report.status_code
        except requests.exceptions.RequestException as errex:
            print("Exception request")
            print(errex)
        return send_report.status_code
