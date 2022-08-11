#!/usr/bin/python3
#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

import sys
import os
import hashlib
from dotenv import load_dotenv
from github import Github

# Pre-checks
if len(sys.argv) < 4:
    print(
        "\nPlease mention in which repo you want to create the releaase\n\n    ex: ./github_releases.py ItsVixano-releases LineageOS_lisa 20220713\n"
    )
    exit()

try:
    if len(os.listdir("uploads")) == 0:
        print(
            "\nPlease make sure to create a folder named `uploads` with all the assets you want to upload inside it\n"
        )
        exit()
except FileNotFoundError:
    # Print out the same error
    print(
        "\nPlease make sure to create a folder named `uploads` with all the assets you want to upload inside it\n"
    )
    exit()

# defs
def get_device(var):
    return {
        "LineageOS_ysl": {1: "Redmi S2/Y2", 2: "19.1"},
        "LineageOS_daisy": {1: "Mi A2 Lite", 2: "19.1"},
        "LineageOS_lisa": {1: "Xiaomi 11 Lite 5g NE", 2: "19.1"},
    }.get(var)


def sha1sum(var):
    file_hash = hashlib.sha1()
    BLOCK_SIZE = 15728640  # 15mb
    with open("uploads/" + var, "rb") as f:
        fb = f.read(BLOCK_SIZE)
        while len(fb) > 0:
            file_hash.update(fb)
            fb = f.read(BLOCK_SIZE)

    return file_hash.hexdigest()


# Vars
load_dotenv()
GH_TOKEN = os.getenv("TOKEN")
GH_ASSETS = os.listdir("uploads")
GH_OWNER = sys.argv[1]  # Github profile name
GH_REPO = sys.argv[2]  # Github repo name
GH_TAG = sys.argv[3]  # Github release tag name
GH_NAME = f"LineageOS {get_device(GH_REPO)[2]} for {get_device(GH_REPO)[1]} ({GH_TAG})"
GH_BODY = """### Changelog
- ...

### Notes
- ...

### Sha1sums"""

# Calculate the sha1sums of the assets
for asset in GH_ASSETS:
    print(f"\nCalculating sha1sum for `{asset}`")
    GH_BODY += f"\n- {asset}: `{sha1sum(asset)}`"

# Create release
print("\nCreating a release page ...")
repo = Github(GH_TOKEN).get_repo(GH_OWNER + "/" + GH_REPO)
repo.create_git_release(
    GH_TAG, GH_NAME, GH_BODY, True
)  # tag_name, release_name, release_body, draft

# Upload assets
GH_DRAFT_TAG = input(
    f"""
For uploading the assets, you must provide the draft tag value of the release page

> Go on https://github.com/{GH_OWNER}/{GH_REPO}/releases
> Select the draft release
> Copy and paste here the tag from the url (it starts with `untagged-`)\n
"""
)
for asset in GH_ASSETS:
    print(f"\nUploading `{asset}`")
    repo.get_release(GH_DRAFT_TAG).upload_asset(f"uploads/{asset}")

print("\nDone!")
