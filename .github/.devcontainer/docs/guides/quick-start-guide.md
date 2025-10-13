# Quick Start Guide

Get up and running with IDE backends in 5 minutes.

## Prerequisites

- Docker Desktop or Docker Engine
- VS Code with Dev Containers extension
- JetBrains Gateway (optional, for Rider)

---

## Step 1: Start the Container

1. Open the project in VS Code
2. Press `F1` → "Dev Containers: Reopen in Container"
3. Wait for container to build (first time only)

**Status check:**
```bash
ide-backend-manager status
```

---

## Step 2: Choose Your Backend

### Option A: Browser-Based (Easiest)

**Start code-server:**
```bash
ide-backend-manager start-vscode
```

**Access:**
```
http://localhost:8080
```

✅ Works in any browser  
✅ No setup required  
✅ Perfect for quick edits

---

### Option B: VS Code Remote-SSH (Best Performance)

**1. Ensure SSH is running:**
```bash
ide-backend-manager check-ssh
```

**2. In VS Code, connect:**
- Press `F1`
- "Remote-SSH: Connect to Host"
- Enter: `vscode@localhost -p 2222`
- Password: `vscode`

✅ Full VS Code features  
✅ Best performance  
✅ Native experience

---

### Option C: VS Code Tunnel (Remote Access)

**1. Start tunnel:**
```bash
ide-backend-manager start-tunnel
```

**2. Authenticate:**
```bash
# Get auth URL
cat /tmp/vscode-tunnel.log | grep http
```
Open URL, sign in with Microsoft/GitHub

**3. Access from anywhere:**
- Go to https://vscode.dev
- Click "Open a Remote Window"
- Select "Connect to Tunnel"
- Choose your tunnel

✅ No VPN needed  
✅ Works through firewalls  
✅ Access from anywhere

---

### Option D: JetBrains Rider (Professional .NET)

**1. Verify Rider is installed:**
```bash
ide-backend-manager check-jetbrains
```

**2. Open JetBrains Gateway**

**3. Connect via SSH:**
- New Connection → SSH
- Host: `localhost`
- Port: `2222`
- User: `vscode`
- Password: `vscode`

**4. Gateway discovers Rider automatically**

✅ Professional .NET IDE  
✅ Advanced refactoring  
✅ ReSharper included

---

## Step 3: Start Coding

Regardless of which backend you chose, you now have full access to:
- ✅ All project files
- ✅ .NET SDK
- ✅ Terminal access
- ✅ Extensions/plugins
- ✅ Git integration

---

## Common Tasks

### Check What's Running
```bash
ide-backend-manager status
```

### Start Everything
```bash
ide-backend-manager start
```

### Stop Everything
```bash
ide-backend-manager stop
```

### Restart a Service
```bash
ide-backend-manager stop-vscode
ide-backend-manager start-vscode
```

---

## Ports

| Port | Service     | Access                |
| ---- | ----------- | --------------------- |
| 2222 | SSH         | Remote-SSH, Gateway   |
| 8080 | code-server | http://localhost:8080 |

---

## Troubleshooting

### Can't connect via SSH?
```bash
# Check if SSH is running
ide-backend-manager check-ssh

# Start it if needed
ide-backend-manager start-ssh
```

### code-server won't start?
```bash
# Check if already running
ide-backend-manager check-vscode

# Kill and restart
ide-backend-manager stop-vscode
ide-backend-manager start-vscode
```

### Port already in use?
```bash
# See what's using the port
sudo lsof -i :8080
sudo lsof -i :2222

# Kill the process
sudo kill -9 <PID>
```

---

## Next Steps

### Set Up SSH Keys (Recommended)
See: [Security Guide](security-guide.md)

### Learn All Commands
See: [Command Reference](../references/command-reference.md)

### Compare Backends
See: [Backend Comparison](../references/backend-comparison.md)

### Having Issues?
See: [Troubleshooting Guide](troubleshooting-guide.md)

---

## Quick Reference Card

```bash
# Management
ide-backend-manager start        # Start all
ide-backend-manager stop         # Stop all
ide-backend-manager status       # Check all

# SSH
ide-backend-manager start-ssh    # Start SSH
ide-backend-manager check-ssh    # Check SSH

# code-server
ide-backend-manager start-vscode # Start code-server
ide-backend-manager check-vscode # Check code-server

# Tunnel
ide-backend-manager start-tunnel # Start tunnel
ide-backend-manager check-tunnel # Check tunnel

# Rider
ide-backend-manager check-jetbrains # Check installation
```

---

## Need Help?

- 📖 [Full Documentation](../README.md)
- 🔧 [Troubleshooting Guide](troubleshooting-guide.md)
- 📚 [Detailed IDE Backends Guide](ide-backends-guide.md)
- 🔐 [Security Best Practices](security-guide.md)
