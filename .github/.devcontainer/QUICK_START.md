# Quick Start Guide - IDE Backends

## 🚀 Quick Commands

### Check Status
```bash
ide-backend-manager status
```

### Start All Backends
```bash
ide-backend-manager start
```

### Stop All Backends
```bash
ide-backend-manager stop
```

## 🔌 Connection Details

### SSH
```bash
# Connect via SSH
ssh -p 2222 vscode@localhost

# Copy files to container
scp -P 2222 file.txt vscode@localhost:/home/vscode/

# Port forwarding through SSH
ssh -p 2222 -L 8000:localhost:8000 vscode@localhost
```

### Code-Server (VS Code in Browser)
```bash
# Start code-server
code-server --bind-addr 0.0.0.0:8080

# Access in browser
http://localhost:8080
```

### JetBrains Gateway
1. Open JetBrains Gateway
2. Click "New Connection" → "SSH"
3. Enter: `vscode@localhost`
4. Port: `2222`
5. Connect

## 📋 Port Reference

| Port | Service     | URL/Command                    |
| ---- | ----------- | ------------------------------ |
| 2222 | SSH         | `ssh -p 2222 vscode@localhost` |
| 8080 | code-server | `http://localhost:8080`        |

## 🔐 Security Setup (Recommended)

### Generate SSH Key
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

### Copy Key to Container
```bash
ssh-copy-id -p 2222 vscode@localhost
```

### Connect Without Password
```bash
ssh -p 2222 vscode@localhost
```

## 🛠️ Individual Backend Commands

### SSH Only
```bash
ide-backend-manager start-ssh  # Start SSH
ide-backend-manager stop-ssh   # Stop SSH
```

### Code-Server Only
```bash
ide-backend-manager start-code  # Start code-server
ide-backend-manager stop-code   # Stop code-server
```

### JetBrains Check
```bash
ide-backend-manager check-jetbrains  # Verify installation
```

## 📖 Full Documentation

For detailed information, see:
- `IDE_BACKENDS_README.md` - Complete documentation
- `CHANGES_SUMMARY.md` - Summary of changes made

## 💡 Tips

- SSH is automatically started by the `sshd` feature
- code-server needs to be started manually
- JetBrains Gateway works through SSH (no separate server needed)
- Use `ide-backend-manager help` for more options
