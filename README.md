# pi — 开箱即用加密发行包

```bash
git clone https://github.com/monikalnbo/pi.git
cd pi && bash go.sh        # 输入暗号后自动: 装pi → 技能 → 写密钥 → 自检
```

## 结构
| 文件 | 性质 |
|---|---|
| go.sh | 明文入口（仅 5 行：读暗号→解密执行） |
| pi-setup.enc | 🔐 AES-256 加密的安装脚本（含写密钥逻辑） |
| vault.pienc | 🔐 AES-256 加密的密钥库（auth.json / gh token / ssh） |
| payload.tar | 明文载荷（skills / AGENTS.md / mcp.json / models.json / 桥接） |

- 两个 .enc 共用同一暗号（PBKDF2 60万轮）
- 忘记暗号 = 密钥丢失，务必备份到密码管理器
- 换暗号: `openssl enc -d ... -in pi-setup.enc | vi` 改完重新加密
