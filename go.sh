#!/usr/bin/env bash
# 用法: bash go.sh   （需要克隆本仓库后在本目录执行）
cd "$(dirname "$0")" || exit 1
read -rsp "pi 暗号: " P; echo
export PASS="$P"
openssl enc -d -aes-256-cbc -pbkdf2 -iter 600000 -in pi-setup.enc -pass env:PASS | bash -s -- "$(pwd)"
