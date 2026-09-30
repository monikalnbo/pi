#!/usr/bin/env bash
set -o pipefail
cd "$(dirname "$0")" || exit 1
read -rsp "pi 暗号: " P; echo
export PASS="$P"
openssl enc -d -aes-256-cbc -pbkdf2 -iter 600000 -in pi-setup.enc -pass env:PASS | bash -s -- "$(pwd)" || { echo "✗ 暗号错误或文件损坏"; exit 1; }
