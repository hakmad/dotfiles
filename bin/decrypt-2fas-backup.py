#!/usr/bin/env python3
"""Script to decrypt a backup file from 2FAS."""
import argparse
import json
import base64
import getpass
import sys

from cryptography.hazmat.primitives.ciphers.aead import AESGCM
from cryptography.hazmat.primitives.hashes import SHA256
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC


# Create a parser and set it up with a few arguments.
parser = argparse.ArgumentParser(prog="decrypt-2fas-backup.py",
                                 description="Tool to decrypt a 2FAS backup file")

parser.add_argument("backup_file",
                    help="File containing encrypted 2FAS backup")

args = parser.parse_args()

password = getpass.getpass()

with open(args.backup_file, "r") as file:
    data = json.load(file)

encrypted, salt, nonce = map(base64.b64decode, data["servicesEncrypted"].split(":"))

kdf = PBKDF2HMAC(salt=salt, algorithm=SHA256(), length=32, iterations=10000)
key = kdf.derive(password.encode("utf-8"))
aes_gcm = AESGCM(key)

services = aes_gcm.decrypt(nonce, encrypted, None)

services = json.loads(services)

json.dump(services, sys.stdout, indent=4)
