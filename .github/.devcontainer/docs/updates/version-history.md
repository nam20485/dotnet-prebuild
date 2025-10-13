# Version History

Complete chronological history of IDE backend changes.

---

## Version 1.3 - VS Code Tunnel Addition (January 2025)

### Summary
Added VS Code Tunnel service for secure remote access without VPN or port forwarding.

### What's New
- ✨ **VS Code Tunnel Service:** Access devcontainer from vscode.dev
- ✨ **Tunnel Management:** New commands in ide-backend-manager
- ✨ **Logging:** Tunnel output captured for debugging
- ✨ **Documentation:** Comprehensive tunnel guides added

### Technical Changes

#### ide-backend-manager.sh
Added three new functions:
- `check_vscode_tunnel()` - Check if tunnel is running
- `start_vscode_tunnel()` - Start tunnel in background
- `stop_vscode_tunnel()` - Stop tunnel service

#### Commands Added
```bash
ide-backend-manager check-tunnel
ide-backend-manager start-tunnel
ide-backend-manager stop-tunnel
```

#### Files Modified
- `.devcontainer/ide-backend-manager.sh` - Added tunnel functions
- Documentation updated with tunnel information

#### Files Added
- `VSCODE_TUNNEL_ADDITION.md` - Detailed tunnel documentation

### Why This Change
- User identified that tunnel server wasn't being started
- Enables remote access without VPN
- Provides alternative to SSH for restricted networks

### Usage
```bash
# Start tunnel
ide-backend-manager start-tunnel

# Authenticate on first run
cat /tmp/vscode-tunnel.log | grep http

# Access from anywhere
https://vscode.dev → Connect to Tunnel
```

### Breaking Changes
None - purely additive.

### Migration Notes
No migration needed. Existing setups continue working unchanged.

---

## Version 1.2 - Rider Replacement (January 2025)

### Summary
Replaced IntelliJ IDEA Community Edition with JetBrains Rider 2024.2.7.

### What's New
- ✨ **JetBrains Rider 2024.2.7:** Professional .NET IDE
- ✨ **Better .NET Support:** Purpose-built for .NET development
- ✨ **ReSharper Integration:** Advanced code analysis and refactoring
- ✨ **Environment Variable:** `JETBRAINS_IDE_HOME` for easy access

### Technical Changes

#### Dockerfile
```dockerfile
# Removed: IntelliJ IDEA Community Edition
# Added: JetBrains Rider 2024.2.7

ENV JETBRAINS_IDE_HOME=/opt/ide-backends/rider
RUN mkdir -p /opt/ide-backends && \
    curl -L "https://download.jetbrains.com/rider/JetBrains.Rider-2024.2.7.tar.gz" \
      -o /tmp/rider.tar.gz && \
    tar -xzf /tmp/rider.tar.gz -C /opt/ide-backends && \
    mv /opt/ide-backends/JetBrains\ Rider-* /opt/ide-backends/rider && \
    rm /tmp/rider.tar.gz
```

#### Installation Path
- **Old:** `/opt/ide-backends/idea-IC-*`
- **New:** `/opt/ide-backends/rider`

#### Version
- **Rider:** 2024.2.7 (latest stable at time of change)

### Why This Change
1. **Better .NET Integration:** Rider is specifically designed for .NET
2. **Professional Features:** ReSharper, better debugging, advanced refactoring
3. **Industry Standard:** Most .NET developers use Rider or Visual Studio
4. **User Request:** Explicit request to replace IDEA with Rider

### Breaking Changes
- IntelliJ IDEA no longer available
- Different IDE, different shortcuts and UI
- Requires Rider license (free trial available)

### Migration Notes

**For existing users:**
1. Rebuild container to get Rider
2. Install JetBrains Gateway if not already installed
3. Connect via Gateway (same SSH port 2222)
4. Gateway will auto-discover Rider

**Settings migration:**
- Rider can import IntelliJ IDEA settings
- In Rider: File → Import Settings

---

## Version 1.1 - Real VS Code Backend (January 2025)

### Summary
Added VS Code CLI to support full Remote-SSH functionality alongside code-server.

### What's New
- ✨ **VS Code CLI:** Real VS Code remote backend
- ✨ **Remote-SSH Support:** Connect with VS Code Desktop
- ✨ **Dual Access:** Both browser (code-server) and desktop (Remote-SSH)

### Technical Changes

#### Dockerfile
```dockerfile
# Install VS Code CLI for Remote-SSH support
RUN curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' \
      --output /tmp/vscode_cli.tar.gz && \
    tar -xf /tmp/vscode_cli.tar.gz -C /usr/local/bin && \
    rm /tmp/vscode_cli.tar.gz && \
    chmod +x /usr/local/bin/code
```

#### Binary Added
- `/usr/local/bin/code` - VS Code CLI

### Why This Change
User requested "real vs code backend" in addition to web-based code-server.

### Usage
```bash
# Connect via VS Code Desktop
# 1. Install Remote-SSH extension
# 2. Connect to localhost:2222
# 3. VS Code installs server automatically
```

### Breaking Changes
None - purely additive.

---

## Version 1.0 - Initial IDE Backends Setup (January 2025)

### Summary
Initial implementation of complete IDE backend infrastructure for remote development.

### What's New
- ✨ **SSH Server:** Port 2222 with password and key authentication
- ✨ **code-server:** VS Code in browser on port 8080
- ✨ **IntelliJ IDEA:** Community Edition for Java/Kotlin (later replaced)
- ✨ **Management Script:** ide-backend-manager with 11 commands
- ✨ **Documentation:** Comprehensive setup guides

### Technical Changes

#### Dockerfile
- Installed OpenSSH server
- Installed code-server via official install script
- Downloaded IntelliJ IDEA Community Edition
- Copied ide-backend-manager script
- Configured SSH with custom settings

#### devcontainer.json
- Added `ghcr.io/devcontainers/features/sshd` feature
- Configured port forwarding: 2222, 8080
- Set `postCreateCommand` to show status on startup

#### SSH Configuration
```bash
# /etc/ssh/sshd_config
Port 2222
PermitRootLogin no
PasswordAuthentication yes
PubkeyAuthentication yes
PrintMotd no
X11Forwarding no
```

#### Management Script
Created `ide-backend-manager` with commands:
- `start` / `stop` / `status` - Global control
- `check-ssh` / `start-ssh` / `stop-ssh` - SSH control
- `check-vscode` / `start-vscode` / `stop-vscode` - code-server control
- `check-jetbrains` - Check IDE installation
- `help` - Show usage

### Files Created
- `.devcontainer/Dockerfile` - Modified with backends
- `.devcontainer/devcontainer.json` - Updated configuration
- `.devcontainer/ide-backend-manager.sh` - Management script
- `IDE_BACKENDS_README.md` - Main documentation
- `QUICK_START.md` - Quick reference guide
- `CHANGES_SUMMARY.md` - Initial summary

### Why These Choices

**SSH (port 2222):**
- Industry standard for remote access
- Required for Remote-SSH and Gateway
- Port 2222 to avoid conflicts with host SSH

**code-server (port 8080):**
- No client installation required
- Access from any device with browser
- Perfect for quick edits and reviews

**IntelliJ IDEA (later replaced):**
- Initial choice for JetBrains backend
- Later replaced with Rider for better .NET support

**Management Script:**
- Simplify backend management
- Consistent interface for all services
- Easy to extend with new backends

### Original Requirements
User requested:
1. Install IDE backends in Docker
2. Add SSH feature to devcontainer

### Delivered
- ✅ Multiple IDE backends (SSH + code-server + IDEA)
- ✅ SSH feature with full configuration
- ✅ Management tooling
- ✅ Comprehensive documentation

---

## Summary by Component

### SSH Server
- **v1.0:** Initial setup on port 2222
- **v1.1:** No changes
- **v1.2:** No changes
- **v1.3:** No changes

### code-server
- **v1.0:** Initial installation on port 8080
- **v1.1:** No changes
- **v1.2:** No changes
- **v1.3:** No changes

### VS Code CLI
- **v1.0:** Not included
- **v1.1:** ✨ Added for Remote-SSH support
- **v1.2:** No changes
- **v1.3:** ✨ Used for Tunnel service

### JetBrains IDE
- **v1.0:** IntelliJ IDEA Community Edition
- **v1.1:** No changes
- **v1.2:** ✨ Replaced with Rider 2024.2.7
- **v1.3:** No changes

### Management Script
- **v1.0:** 11 commands (SSH, code-server, JetBrains check)
- **v1.1:** No changes
- **v1.2:** No changes
- **v1.3:** ✨ Added 3 tunnel commands (14 total)

---

## File History

### Configuration Files

**Dockerfile:**
- v1.0 - Created with SSH, code-server, IDEA
- v1.1 - Added VS Code CLI installation
- v1.2 - Replaced IDEA with Rider
- v1.3 - No changes

**devcontainer.json:**
- v1.0 - Added sshd feature, port forwarding
- v1.1 - No changes
- v1.2 - No changes
- v1.3 - No changes

**ide-backend-manager.sh:**
- v1.0 - Created with 11 commands
- v1.1 - No changes
- v1.2 - No changes
- v1.3 - Added tunnel commands (14 total)

### Documentation Files

**Created in v1.0:**
- IDE_BACKENDS_README.md
- QUICK_START.md
- CHANGES_SUMMARY.md

**Created in v1.2:**
- UPDATE_NOTES.md (Rider replacement)

**Created in v1.3:**
- VSCODE_TUNNEL_ADDITION.md

**Created in Docs Reorganization:**
- docs/README.md
- docs/guides/*.md
- docs/references/*.md
- docs/updates/*.md

---

## Quick Navigation

- 📖 [Latest Changes](LATEST.md)
- 🚀 [Quick Start Guide](../guides/quick-start-guide.md)
- 📚 [IDE Backends Guide](../guides/ide-backends-guide.md)
- 🔧 [Troubleshooting](../guides/troubleshooting-guide.md)
- 📊 [Backend Comparison](../references/backend-comparison.md)
- 📝 [Command Reference](../references/command-reference.md)
