#!/usr/bin/env python3
"""Script to generate MFA tokens from a secret."""
import argparse
import base64
import hmac
import json
import struct
import sys
import time


parser = argparse.ArgumentParser(prog="generate-mfa-token.py",
                                 description="Tool to generate MFA tokens from a (decrypted) 2FAS backup file")

parser.add_argument("backup_file",
                    help="File containing (decrypted) 2FAS backup")

args = parser.parse_args()

with open(args.backup_file, "r") as file:
    services = json.load(file)

services.sort(key=lambda x: x["name"])
service_names = [service["name"] for service in services]

print("ID | Service")

for i, service in enumerate(service_names):
    print(f"{i + 1:>2} | {service}")

user_selection = int(input("Enter ID: ")) - 1

service = services[user_selection]

secret = service["secret"]
period = service["otp"]["period"]
digits = service["otp"]["digits"]
digest = service["otp"]["algorithm"]
counter = int(time.time() / period)

key = base64.b32decode(secret.upper() + "=" * ((8 - len(secret)) % 8))
counter = struct.pack(">Q", counter)
mac = hmac.new(key, counter, digest).digest()
offset = mac[-1] & 0x0f
binary = struct.unpack(">L", mac[offset:offset+4])[0] & 0x7fffffff
print(str(binary)[-digits:].zfill(digits))
