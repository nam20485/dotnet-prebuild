# Ports and Services Reference

Complete reference for all ports, services, and network configuration.

## Port Mappings

### Forwarded Ports

| Port     | Service     | Protocol | Purpose               | Required For        |
| -------- | ----------- | -------- | --------------------- | ------------------- |
| **2222** | SSH Server  | SSH      | Remote shell access   | Remote-SSH, Gateway |
| **8080** | code-server | HTTP     | Browser-based VS Code | code-server         |

### Internal Ports

These ports are used internally but not typically forwarded:

| Port | Service        | Notes                          |
| ---- | -------------- | ------------------------------ |
| 22   | SSH (default)  | Not used - we use 2222         |
| 443  | HTTPS outbound | For VS Code Tunnel, extensions |
| 80   | HTTP outbound  | For package downloads          |

---

## Service Details

### SSH Server (OpenSSH)

**Port:** 2222  
**Protocol:** SSH v2  
**Binary:** `/usr/sbin/sshd`  
**Config:** `/etc/ssh/sshd_config`

**Purpose:**
- Remote shell access to container
- Required for VS Code Remote-SSH
- Required for JetBrains Gateway

**Authentication Methods:**
- SSH key (recommended)
- Password (less secure)

**Management:**
```bash
# Status
sudo service ssh status
ide-backend-manager check-ssh

# Start
sudo service ssh start
ide-backend-manager start-ssh

# Stop
sudo service ssh stop
ide-backend-manager stop-ssh

# Restart
sudo service ssh restart
```

**Configuration:**
```bash
# Main config
/etc/ssh/sshd_config

# User keys
~/.ssh/authorized_keys

# Host keys
/etc/ssh/ssh_host_*
```

**Logs:**
```bash
# System logs
sudo journalctl -u ssh

# Auth logs
sudo tail -f /var/log/auth.log
```

---

### code-server

**Port:** 8080  
**Protocol:** HTTP/HTTPS  
**Binary:** `/usr/local/bin/code-server`  
**Config:** `~/.config/code-server/config.yaml`

**Purpose:**
- Browser-based VS Code interface
- Full VS Code functionality in browser
- No client installation required

**Authentication:**
- Password/token in config.yaml
- Can be disabled for local dev

**Management:**
```bash
# Check status
ide-backend-manager check-vscode
ps aux | grep code-server

# Start
ide-backend-manager start-vscode
# Or manually:
code-server --bind-addr 0.0.0.0:8080

# Stop
ide-backend-manager stop-vscode
# Or manually:
pkill -f code-server
```

**Configuration:**
```yaml
# ~/.config/code-server/config.yaml
bind-addr: 0.0.0.0:8080
auth: password
password: your-password-here
cert: false
```

**Access:**
```
http://localhost:8080
```

**Logs:**
```bash
~/.local/share/code-server/coder-logs/
```

---

### VS Code Tunnel

**Port:** None (outbound only)  
**Protocol:** WebSocket over HTTPS  
**Binary:** `/usr/local/bin/code`  
**Config:** `~/.vscode-cli/`

**Purpose:**
- Remote access without port forwarding
- Works through firewalls and NAT
- Accessible via vscode.dev

**Authentication:**
- Microsoft account
- GitHub account

**Management:**
```bash
# Check status
ide-backend-manager check-tunnel

# Start
ide-backend-manager start-tunnel

# Stop
ide-backend-manager stop-tunnel

# Start manually with logs
code tunnel --accept-server-license-terms
```

**Configuration:**
```bash
# Tunnel data
~/.vscode-cli/

# Logs
/tmp/vscode-tunnel.log
```

**Access:**
1. Start tunnel
2. Authenticate via provided URL
3. Access from vscode.dev
4. Open tunnel by name

**Network Requirements:**
- Outbound HTTPS (443) access
- No inbound ports needed
- Works through NAT/firewall

---

### JetBrains Rider Backend

**Port:** 2222 (via SSH)  
**Protocol:** JetBrains Remote Development  
**Install:** `/opt/ide-backends/rider`  
**Version:** 2024.2.7

**Purpose:**
- Professional .NET IDE
- Advanced refactoring and analysis
- Remote development via Gateway

**Authentication:**
- SSH key (via port 2222)
- Gateway handles connection

**Management:**
```bash
# Check installation
ide-backend-manager check-jetbrains
ls -la $JETBRAINS_IDE_HOME

# Rider is accessed via Gateway, not directly managed
```

**Configuration:**
```bash
# Installation directory
/opt/ide-backends/rider

# Environment variable
JETBRAINS_IDE_HOME=/opt/ide-backends/rider

# Logs
/opt/ide-backends/rider/log/
```

**Access:**
1. Open JetBrains Gateway
2. Connect via SSH (localhost:2222)
3. Gateway auto-discovers Rider backend
4. IDE opens in remote mode

**Requirements:**
- JetBrains Gateway installed locally
- Rider license (or trial)
- SSH access (port 2222)

---

## Network Configuration

### devcontainer.json Port Forwarding

```json
{
  "forwardPorts": [2222, 8080]
}
```

**What this does:**
- Forwards container port 2222 → host port 2222
- Forwards container port 8080 → host port 8080
- Allows access from host machine to services

### Firewall Considerations

**Outbound (Required):**
- HTTPS (443) - For package downloads, extensions, VS Code Tunnel
- HTTP (80) - For package downloads
- DNS (53) - For name resolution

**Inbound (Optional):**
- Port 2222 - Only if accessing SSH from outside host machine
- Port 8080 - Only if accessing code-server from outside host machine

**Typical Setup:**
- **Local Docker:** No firewall changes needed
- **Remote Docker:** May need to expose ports 2222, 8080
- **VS Code Tunnel:** No inbound ports needed

---

## Service Dependencies

### SSH Server
**Depends on:**
- OpenSSH package
- `/etc/ssh/sshd_config`

**Required by:**
- VS Code Remote-SSH
- JetBrains Gateway
- Manual SSH access

### code-server
**Depends on:**
- Node.js runtime
- OpenSSL

**Required by:**
- Browser access
- Port 8080 forwarding

### VS Code Tunnel
**Depends on:**
- VS Code CLI
- Internet connectivity
- Microsoft account

**Required by:**
- vscode.dev access
- Remote access without VPN

### Rider Backend
**Depends on:**
- SSH server (for Gateway connection)
- .NET SDK
- JetBrains runtime

**Required by:**
- JetBrains Gateway
- Remote Rider access

---

## Process Management

### Viewing Running Services

```bash
# All backends status
ide-backend-manager status

# See all processes
ps aux

# See specific service
ps aux | grep ssh
ps aux | grep code-server
ps aux | grep "code tunnel"
```

### Port Usage

```bash
# See what's using each port
sudo netstat -tulpn | grep :2222
sudo netstat -tulpn | grep :8080

# Or with lsof
sudo lsof -i :2222
sudo lsof -i :8080
```

### Resource Monitoring

```bash
# CPU and memory usage
top

# htop (if installed)
htop

# Disk usage
df -h

# Network connections
netstat -an
```

---

## Startup Behavior

### Automatic Startup

**Configured in devcontainer.json:**
```json
{
  "postCreateCommand": "ide-backend-manager status"
}
```

**What starts automatically:**
- SSH server (via features.sshd)
- Nothing else by default

**What requires manual start:**
- code-server
- VS Code Tunnel
- Rider (started by Gateway)

### Starting All Services

```bash
# Start everything
ide-backend-manager start

# Or individually
ide-backend-manager start-ssh
ide-backend-manager start-vscode
ide-backend-manager start-tunnel
```

### Stopping All Services

```bash
# Stop everything
ide-backend-manager stop

# Or individually
ide-backend-manager stop-ssh
ide-backend-manager stop-vscode
ide-backend-manager stop-tunnel
```

---

## Connection Examples

### SSH Connection

```bash
# From host
ssh -p 2222 vscode@localhost

# From remote machine
ssh -p 2222 vscode@your-host.com

# With key
ssh -i ~/.ssh/id_rsa -p 2222 vscode@localhost
```

### code-server Connection

```bash
# Local
http://localhost:8080

# Remote (if exposed)
http://your-host.com:8080
```

### VS Code Remote-SSH

```
Host devcontainer
    HostName localhost
    Port 2222
    User vscode
    IdentityFile ~/.ssh/id_rsa
```

### VS Code Tunnel

```
# Access via vscode.dev after authentication
# No direct connection string needed
```

### JetBrains Gateway

```
SSH Connection:
Host: localhost
Port: 2222
User: vscode
Auth: SSH key
```

---

## Security Configuration

### SSH Security

```bash
# /etc/ssh/sshd_config
Port 2222
PermitRootLogin no
PasswordAuthentication yes  # Set to 'no' for key-only
PubkeyAuthentication yes
```

### code-server Security

```yaml
# ~/.config/code-server/config.yaml
auth: password  # Enable authentication
password: strong-password-here
cert: true  # Enable HTTPS (optional)
```

### Firewall Rules

```bash
# Allow SSH
sudo ufw allow 2222/tcp

# Allow code-server
sudo ufw allow 8080/tcp

# Enable firewall
sudo ufw enable
```

---

## Performance Tuning

### SSH Performance

```bash
# /etc/ssh/sshd_config
Compression yes
TCPKeepAlive yes
ClientAliveInterval 60
```

### code-server Performance

```bash
# Start with specific resources
code-server --bind-addr 0.0.0.0:8080 \
  --disable-telemetry \
  --disable-update-check
```

### Network Optimization

```bash
# Increase buffer sizes (if needed)
sudo sysctl -w net.core.rmem_max=16777216
sudo sysctl -w net.core.wmem_max=16777216
```

---

## Troubleshooting

See the [Troubleshooting Guide](../guides/troubleshooting-guide.md) for detailed issue resolution.

**Quick checks:**
```bash
# Port conflicts
sudo netstat -tulpn | grep -E '(2222|8080)'

# Service status
ide-backend-manager status

# Logs
sudo journalctl -n 50
sudo tail -f /var/log/auth.log
cat /tmp/vscode-tunnel.log
```

---

See Also:
- [Backend Comparison](backend-comparison.md) - Choose the right backend
- [Command Reference](command-reference.md) - All management commands
- [Security Guide](../guides/security-guide.md) - Securing your setup
