# Latest Changes

**Last Updated:** January 2025

For complete version history, see [Version History](version-history.md).

---

## Most Recent: VS Code Tunnel Addition

### What Changed
Added VS Code Tunnel service for secure remote access without VPN or port forwarding.

### New Features
- **VS Code Tunnel Service:** Accessible via vscode.dev from anywhere
- **Authentication:** Microsoft/GitHub account integration
- **Management Commands:** `start-tunnel`, `stop-tunnel`, `check-tunnel`
- **Logging:** Tunnel output captured in `/tmp/vscode-tunnel.log`

### Updated Files
- `Dockerfile` - No changes (VS Code CLI already installed)
- `ide-backend-manager.sh` - Added tunnel management functions
- Documentation - Added tunnel information

### Usage
```bash
# Start tunnel
ide-backend-manager start-tunnel

# Check status
ide-backend-manager check-tunnel

# Access via browser
# 1. Go to https://vscode.dev
# 2. Connect to Tunnel
# 3. Select your tunnel name
```

### When to Use
- Working remotely without VPN
- Behind strict firewall
- Need access from multiple locations
- Can't forward ports

### Documentation
- [VS Code Tunnel Guide](../guides/ide-backends-guide.md#vs-code-tunnel)
- [Backend Comparison](../references/backend-comparison.md)

---

## Previous: JetBrains IDEA → Rider Replacement

### What Changed
Replaced IntelliJ IDEA Community Edition with JetBrains Rider 2024.2.7.

### Reason
- **Better .NET Support:** Rider is purpose-built for .NET development
- **ReSharper Integration:** Built-in advanced code analysis
- **Professional Tool:** Full IDE vs Community Edition

### New Features
- JetBrains Rider 2024.2.7 installed at `/opt/ide-backends/rider`
- Environment variable: `JETBRAINS_IDE_HOME=/opt/ide-backends/rider`
- Accessible via JetBrains Gateway

### Usage
```bash
# Check installation
ide-backend-manager check-jetbrains

# Access via Gateway
# 1. Open JetBrains Gateway
# 2. Connect via SSH to localhost:2222
# 3. Gateway discovers Rider automatically
```

### Requirements
- JetBrains Gateway installed locally
- Rider license (or free trial)

### Documentation
- [Rider Setup Guide](../guides/ide-backends-guide.md#jetbrains-rider)

---

## Initial: IDE Backends Setup

### What Was Added
Complete IDE backend infrastructure for remote development.

### Components
1. **SSH Server**
   - Port 2222
   - Password and key authentication
   - Required for Remote-SSH and Gateway

2. **code-server**
   - Port 8080
   - VS Code in browser
   - Full extension support

3. **VS Code CLI**
   - Remote-SSH support
   - Tunnel capability

4. **JetBrains Rider**
   - Professional .NET IDE
   - Gateway access

5. **Management Script**
   - `ide-backend-manager` with 14 commands
   - Start/stop/status for all backends

### Configuration
- `devcontainer.json` updated with features and ports
- `Dockerfile` includes all backend installations
- Automatic SSH start on container creation

### Documentation
See [IDE Backends Guide](../guides/ide-backends-guide.md) for complete setup.

---

## Quick Links

- 📖 [Complete Version History](version-history.md)
- 🚀 [Quick Start Guide](../guides/quick-start-guide.md)
- 📚 [IDE Backends Guide](../guides/ide-backends-guide.md)
- 🔧 [Troubleshooting](../guides/troubleshooting-guide.md)
- 📊 [Backend Comparison](../references/backend-comparison.md)
