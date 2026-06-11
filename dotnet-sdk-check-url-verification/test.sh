#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'
set -x

RELEASES_URI=$(jq -r '.ReleasesUri' /usr/lib/dotnet/sdk/*/sdk-check-config.json)
RELEASE=$(echo "$RELEASES_URI" | awk -F'/' '{print $(NF-1)}')
if ! distro-info --all | grep -q "$RELEASE"; then
    echo "Release $RELEASE is not a valid release name"
    exit 1
fi
