#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

errors=0

dotnet_home="$(dirname "$(readlink -f "$(command -v dotnet)")")"
test -d "${dotnet_home}"

# Get the symbolic mode (same format as 'stat -c %A') and path of every file
# from a single find invocation and do the checks with bash builtins only.
# Spawning stat/tr/awk/grep several times per file (there are thousands) is too
# slow on some architectures (e.g. s390x) and makes this test time out.
while IFS= read -r -d '' entry; do
    perms="${entry%% *}"
    file="${entry#* }"
    echo "${perms} ${file}"

    # Everything should be readable by user, group, and other. There's no secret data in any of these files.
    readable="${perms//[^r]/}"
    if [[ "${#readable}" -ne 3 ]]; then
        echo "error: Missing read permissions on ${file}"
        errors=1
    fi

    # If it's executable, it must be executable by all
    if [[ "${perms}" == *x* ]]; then
        executable="${perms//[^x]/}"
        if [[ "${#executable}" -ne 3 ]]; then
            echo "error: Missing some execute permissions on ${file}"
            errors=1
        fi
    fi

done < <(find "${dotnet_home}" -type f -printf '%M %p\0')

if [[ "$errors" == 1 ]]; then
  echo "Errors detected"
  exit 1
else
  echo "OK"
  exit 0
fi
