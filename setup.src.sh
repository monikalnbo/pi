#!/usr/bin/env bash
set -euo pipefail
PASSPH="${PASS:?need passphrase}"
D="$(cd "$(dirname "$0")" && pwd)"

log(){ echo -e "\033[1;32m▸\033[0m $*"; }

if ! command -v pi >/dev/null 2>&1; then
  log "安装 Node 26 + pi"
  export NVM_DIR="$HOME/.nvm"
  if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  fi
  . "$NVM_DIR/nvm.sh"
  nvm install 26.7.0 >/dev/null 2>&1 && nvm alias default 26.7.0 >/dev/null
  npm i -g @earendil-works/pi-coding-agent@0.84.1 --silent
fi
command -v pi >/dev/null || { echo "pi 安装失败"; exit 1; }

log "铺开技能与配置"
mkdir -p "$HOME/.pi/agent"
tar xf "$D/payload.tar" -C "$HOME/.pi/agent"
chmod -R u+rwX "$HOME/.pi/agent"

log "解密密钥库"
TMP=$(mktemp -d)
openssl enc -d -aes-256-cbc -pbkdf2 -iter 600000 -in "$D/vault.pienc" -pass env:PASSPH | tar xf - -C "$TMP"
install -D -m600 "$TMP/auth.json"            "$HOME/.pi/agent/auth.json"
install -D -m600 "$TMP/gh/hosts.yml"         "$HOME/.config/gh/hosts.yml"
install -D -m600 "$TMP/ssh/id_ed25519"       "$HOME/.ssh/id_ed25519"
install -D -m644 "$TMP/ssh/id_ed25519.pub"   "$HOME/.ssh/id_ed25519.pub"
install -D -m600 "$TMP/ssh/authorized_keys"  "$HOME/.ssh/authorized_keys"
rm -rf "$TMP"

pip3 install -q jmcomic jmcomic-ai 2>/dev/null || true

if command -v systemctl >/dev/null && [ -f /etc/systemd/system/hermes-pi-bridge.service ]; then
  systemctl enable --now hermes-pi-bridge 2>/dev/null || true
fi

echo "══════ pi 自检 ══════"
pi --version || true
echo "skills : $(ls "$HOME/.pi/agent/skills" 2>/dev/null | tr '\n' ' ')"
[ -s "$HOME/.pi/agent/auth.json" ] && echo "auth   : ✓ 模型密钥已就位" || echo "auth   : ✗"
[ -s "$HOME/.config/gh/hosts.yml" ] && echo "gh     : ✓ token 已就位" || echo "gh     : ✗"
echo "══════ 完成，运行: pi ══════"
