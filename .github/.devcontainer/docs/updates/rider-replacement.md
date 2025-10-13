# Update Notes - Rider and VS Code Server

## Changes Summary

This update replaces IntelliJ IDEA with JetBrains Rider and adds VS Code Server support for Remote-SSH connections.

## What Changed

### 1. Replaced IDEA with Rider
- **Old**: IntelliJ IDEA Community Edition (2024.2.4)
- **New**: JetBrains Rider (2024.2.7)
- **Why**: Rider is optimized for .NET development, making it a better fit for this dotnet-prebuild project

### 2. Added VS Code Server
- Installed VS Code CLI for Remote-SSH extension support
- Allows connecting from local VS Code instance to the container
- No additional port required - uses existing SSH connection (port 2222)

## IDE Backend Options Now Available

You now have **4 ways** to develop in this container:

### 1. 🌐 Code-Server (VS Code in Browser)
- **Access**: `http://localhost:8080`
- **Use Case**: Quick edits from any device with a browser
- **Pros**: No local software needed, works on tablets/phones
- **Cons**: Requires manual start, browser-based experience

### 2. 💻 VS Code Remote-SSH (Local VS Code)
- **Access**: Connect via Remote-SSH extension
- **Use Case**: Full VS Code experience with all your local settings
- **Pros**: Native performance, use your existing VS Code setup
- **Cons**: Requires VS Code installed locally

### 3. 🚀 JetBrains Rider (via Gateway)
- **Access**: Connect via JetBrains Gateway
- **Use Case**: Professional .NET development
- **Pros**: Best-in-class .NET tooling, refactoring, debugging
- **Cons**: Requires Gateway installation

### 4. 🔧 Direct SSH
- **Access**: `ssh -p 2222 vscode@localhost`
- **Use Case**: Command-line work, terminal operations
- **Pros**: Lightweight, always available
- **Cons**: Terminal-only, no GUI

## Quick Start

### Using VS Code Remote-SSH (New!)
```bash
# 1. Install Remote-SSH extension in your local VS Code
# 2. Press F1 and select "Remote-SSH: Connect to Host..."
# 3. Enter: ssh vscode@localhost -p 2222
# 4. VS Code will connect automatically
```

### Using Code-Server (Browser)
```bash
# Start code-server
code-server --bind-addr 0.0.0.0:8080

# Open browser to http://localhost:8080
```

### Using JetBrains Rider
```bash
# 1. Open JetBrains Gateway
# 2. Select "Connect via SSH"
# 3. Host: vscode@localhost
# 4. Port: 2222
# 5. Gateway will detect Rider backend automatically
```

## Technical Details

### Dockerfile Changes
```dockerfile
# Before:
curl -L "https://download.jetbrains.com/idea/ideaIC-2024.2.4.tar.gz"
mv /opt/ide-backends/idea-IC-* /opt/ide-backends/idea
ENV JETBRAINS_IDE_HOME=/opt/ide-backends/idea

# After:
curl -L "https://download.jetbrains.com/rider/JetBrains.Rider-2024.2.7.tar.gz"
mv /opt/ide-backends/JetBrains\ Rider-* /opt/ide-backends/rider
ENV JETBRAINS_IDE_HOME=/opt/ide-backends/rider

# Added:
curl -fsSL "https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64"
tar -xzf /tmp/vscode-cli.tar.gz -C /usr/local/bin
```

### Environment Variables
- `JETBRAINS_IDE_HOME`: Changed from `/opt/ide-backends/idea` to `/opt/ide-backends/rider`
- VS Code Server: Installed to `/usr/local/bin/code`

### Script Updates
- `ide-backend-manager.sh`: Updated to check for Rider instead of IDEA
- Added `check-vscode` command to verify VS Code Server CLI installation
- Updated status output to show all 4 backend options

## Verification

After rebuilding the container, verify installations:

```bash
# Check all backends
ide-backend-manager status

# Expected output:
# ✓ SSH server is running on port 2222
# ✓ code-server is installed
# ✓ VS Code Server CLI is installed
# ✓ JetBrains Rider backend is installed at /opt/ide-backends/rider
```

## Ports

| Port | Service     | Notes                          |
| ---- | ----------- | ------------------------------ |
| 2222 | SSH         | Used by all SSH-based backends |
| 8080 | code-server | Browser-based VS Code          |

## Recommendations

### For .NET Development
- **Primary**: JetBrains Rider (best tooling, refactoring, debugging)
- **Alternative**: VS Code Remote-SSH (lightweight, fast)

### For Quick Edits
- **Browser**: code-server (no installation needed)
- **Mobile**: code-server (works on tablets)

### For Terminal Work
- **Direct SSH**: Traditional SSH connection

## Troubleshooting

### VS Code Remote-SSH Not Connecting
1. Verify SSH works: `ssh -p 2222 vscode@localhost`
2. Check Remote-SSH extension is installed
3. Remove and re-add the host in VS Code
4. Check VS Code logs: View → Output → Remote-SSH

### Rider Backend Not Detected
1. Verify installation: `ls -la /opt/ide-backends/rider`
2. Check SSH connection first
3. Ensure Gateway is up to date
4. Try clearing Gateway cache

### Code-Server Issues
1. Check if running: `ps aux | grep code-server`
2. Start manually: `code-server --bind-addr 0.0.0.0:8080`
3. Check port: `netstat -tuln | grep 8080`

## Files Modified

- ✏️ `Dockerfile` - Replaced IDEA with Rider, added VS Code CLI
- ✏️ `ide-backend-manager.sh` - Updated checks and status output
- ✏️ `IDE_BACKENDS_README.md` - Updated documentation
- ✏️ `QUICK_START.md` - Updated quick reference
- ✏️ `CHANGES_SUMMARY.md` - Updated summary
- 🆕 `UPDATE_NOTES.md` - This file

## Next Steps

1. **Rebuild container**: `Dev Containers: Rebuild Container`
2. **Test VS Code Remote-SSH**: Connect from your local VS Code
3. **Test Rider**: Connect via JetBrains Gateway
4. **Configure preferences**: Set up your preferred IDE

---

**Note**: All backends are optional. Choose the one that fits your workflow best!
