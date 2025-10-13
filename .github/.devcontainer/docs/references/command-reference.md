# Command Reference

Complete reference for all `ide-backend-manager` commands.

## Quick Reference

```bash
ide-backend-manager <command>
```

### Available Commands

| Command           | Description                           |
| ----------------- | ------------------------------------- |
| `start`           | Start all IDE backends                |
| `stop`            | Stop all IDE backends                 |
| `status`          | Show status of all backends           |
| `check-ssh`       | Check if SSH server is running        |
| `start-ssh`       | Start SSH server                      |
| `stop-ssh`        | Stop SSH server                       |
| `check-vscode`    | Check if code-server is running       |
| `start-vscode`    | Start code-server                     |
| `stop-vscode`     | Stop code-server                      |
| `check-tunnel`    | Check if VS Code tunnel is running    |
| `start-tunnel`    | Start VS Code tunnel                  |
| `stop-tunnel`     | Stop VS Code tunnel                   |
| `check-jetbrains` | Check if JetBrains Rider is installed |
| `help`            | Display help message                  |

---

## Global Commands

### start

Start all IDE backend services.

**Usage:**
```bash
ide-backend-manager start
```

**What it does:**
- Starts SSH server
- Starts code-server on port 8080
- Starts VS Code tunnel service

**Output:**
```
Starting all IDE backends...
Starting SSH...
 * Starting OpenBSD Secure Shell server sshd                              [ OK ]
SSH server started successfully.
Starting code-server...
code-server started on http://0.0.0.0:8080
Starting VS Code tunnel...
VS Code tunnel started (check /tmp/vscode-tunnel.log for details)
All IDE backends started.
```

**Exit Codes:**
- `0` - All services started successfully
- Non-zero - One or more services failed to start

---

### stop

Stop all IDE backend services.

**Usage:**
```bash
ide-backend-manager stop
```

**What it does:**
- Stops SSH server
- Stops code-server
- Stops VS Code tunnel service

**Output:**
```
Stopping all IDE backends...
Stopping SSH...
 * Stopping OpenBSD Secure Shell server sshd                              [ OK ]
SSH server stopped.
Stopping code-server...
code-server stopped.
Stopping VS Code tunnel...
VS Code tunnel stopped.
All IDE backends stopped.
```

**Exit Codes:**
- `0` - All services stopped successfully
- Non-zero - One or more services failed to stop

**Note:** JetBrains Rider backend is not stopped as it's managed by Gateway.

---

### status

Display status of all IDE backends.

**Usage:**
```bash
ide-backend-manager status
```

**Output:**
```
IDE Backends Status:
--------------------

SSH Server:
 * sshd is running
SSH is running.

code-server:
vscode    1234  0.5  1.2  1234567 123456 ?      Ssl  10:30   0:05 /usr/local/bin/code-server
code-server is running (PID: 1234)

VS Code Tunnel:
vscode    5678  0.3  0.8  987654 87654 ?        Sl   10:31   0:02 /usr/local/bin/code tunnel
VS Code tunnel is running (PID: 5678)
Log: /tmp/vscode-tunnel.log

JetBrains Rider:
JETBRAINS_IDE_HOME is set to: /opt/ide-backends/rider
total 123456
drwxr-xr-x 10 root root  4096 Jan 15 10:00 .
JetBrains IDE (Rider) is installed at /opt/ide-backends/rider
```

**Exit Codes:**
- `0` - Status retrieved successfully

---

## SSH Commands

### check-ssh

Check if SSH server is running.

**Usage:**
```bash
ide-backend-manager check-ssh
```

**Output (Running):**
```
SSH is running.
```

**Output (Not Running):**
```
SSH is not running.
```

**Exit Codes:**
- `0` - SSH is running
- `1` - SSH is not running

**Use Cases:**
- Before attempting SSH connection
- In scripts to verify SSH availability
- Debugging connection issues

---

### start-ssh

Start the SSH server.

**Usage:**
```bash
ide-backend-manager start-ssh
```

**Output (Success):**
```
SSH server started successfully.
```

**Output (Already Running):**
```
SSH is already running.
```

**Output (Failed):**
```
Failed to start SSH server.
```

**What it does:**
1. Checks if SSH is already running
2. Starts `/usr/sbin/sshd` service
3. Verifies service started correctly

**Requirements:**
- Root/sudo access (handled automatically)
- SSH server installed

**Exit Codes:**
- `0` - SSH started successfully or already running
- `1` - Failed to start SSH

---

### stop-ssh

Stop the SSH server.

**Usage:**
```bash
ide-backend-manager stop-ssh
```

**Output (Success):**
```
SSH server stopped.
```

**Output (Not Running):**
```
SSH is not running.
```

**What it does:**
1. Checks if SSH is running
2. Stops `/usr/sbin/sshd` service
3. Verifies service stopped

**Warning:** Stopping SSH will disconnect any active SSH sessions, including:
- VS Code Remote-SSH connections
- JetBrains Gateway connections
- Manual SSH shells

**Exit Codes:**
- `0` - SSH stopped successfully or not running
- `1` - Failed to stop SSH

---

## code-server Commands

### check-vscode

Check if code-server is running.

**Usage:**
```bash
ide-backend-manager check-vscode
```

**Output (Running):**
```
vscode    1234  0.5  1.2  1234567 123456 ?      Ssl  10:30   0:05 /usr/local/bin/code-server
code-server is running (PID: 1234)
```

**Output (Not Running):**
```
code-server is not running.
```

**Exit Codes:**
- `0` - code-server is running
- `1` - code-server is not running

---

### start-vscode

Start code-server.

**Usage:**
```bash
ide-backend-manager start-vscode
```

**Output (Success):**
```
code-server started on http://0.0.0.0:8080
```

**Output (Already Running):**
```
code-server is already running.
```

**What it does:**
1. Checks if code-server is already running
2. Starts code-server in background
3. Binds to `0.0.0.0:8080` (accessible from outside container)
4. Redirects output to `/dev/null`

**Configuration:**
Uses settings from `~/.config/code-server/config.yaml`

**Access After Start:**
```
http://localhost:8080
```

**Exit Codes:**
- `0` - code-server started successfully or already running

---

### stop-vscode

Stop code-server.

**Usage:**
```bash
ide-backend-manager stop-vscode
```

**Output (Success):**
```
code-server stopped.
```

**Output (Not Running):**
```
code-server is not running.
```

**What it does:**
1. Checks if code-server is running
2. Kills code-server process using `pkill -f code-server`
3. Verifies process terminated

**Warning:** This will immediately terminate the code-server process. Any unsaved work in browser sessions may be lost.

**Exit Codes:**
- `0` - code-server stopped successfully or not running

---

## VS Code Tunnel Commands

### check-tunnel

Check if VS Code tunnel is running.

**Usage:**
```bash
ide-backend-manager check-tunnel
```

**Output (Running):**
```
vscode    5678  0.3  0.8  987654 87654 ?        Sl   10:31   0:02 /usr/local/bin/code tunnel
VS Code tunnel is running (PID: 5678)
Log: /tmp/vscode-tunnel.log
```

**Output (Not Running):**
```
VS Code tunnel is not running.
```

**Exit Codes:**
- `0` - Tunnel is running
- `1` - Tunnel is not running

**Checking Logs:**
```bash
cat /tmp/vscode-tunnel.log
```

---

### start-tunnel

Start VS Code tunnel service.

**Usage:**
```bash
ide-backend-manager start-tunnel
```

**Output (Success):**
```
VS Code tunnel started (check /tmp/vscode-tunnel.log for details)
```

**Output (Already Running):**
```
VS Code tunnel is already running.
```

**What it does:**
1. Checks if tunnel is already running
2. Starts `code tunnel --accept-server-license-terms` in background
3. Redirects output to `/tmp/vscode-tunnel.log`

**First Time Setup:**
On first run, you'll need to authenticate:

1. Start the tunnel
2. Check the log for authentication URL:
   ```bash
   cat /tmp/vscode-tunnel.log | grep -i "http"
   ```
3. Open the URL in your browser
4. Sign in with Microsoft or GitHub account
5. Tunnel will be ready

**Subsequent Runs:**
After initial authentication, tunnel starts automatically.

**Access After Start:**
1. Go to https://vscode.dev
2. Click "Open a Remote Window"
3. Select "Connect to Tunnel"
4. Choose your tunnel by name

**Exit Codes:**
- `0` - Tunnel started successfully or already running

---

### stop-tunnel

Stop VS Code tunnel service.

**Usage:**
```bash
ide-backend-manager stop-tunnel
```

**Output (Success):**
```
VS Code tunnel stopped.
```

**Output (Not Running):**
```
VS Code tunnel is not running.
```

**What it does:**
1. Checks if tunnel is running
2. Kills tunnel process using `pkill -f "code tunnel"`
3. Verifies process terminated

**Effect:**
- Active vscode.dev connections will be disconnected
- Tunnel will no longer be accessible from vscode.dev
- Can be restarted anytime with `start-tunnel`

**Exit Codes:**
- `0` - Tunnel stopped successfully or not running

---

## JetBrains Commands

### check-jetbrains

Check if JetBrains Rider is installed and configured.

**Usage:**
```bash
ide-backend-manager check-jetbrains
```

**Output (Installed):**
```
JETBRAINS_IDE_HOME is set to: /opt/ide-backends/rider
total 123456
drwxr-xr-x 10 root root  4096 Jan 15 10:00 .
drwxr-xr-x  3 root root  4096 Jan 15 09:59 ..
drwxr-xr-x  2 root root  4096 Jan 15 10:00 bin
drwxr-xr-x  2 root root  4096 Jan 15 10:00 lib
...
JetBrains IDE (Rider) is installed at /opt/ide-backends/rider
```

**Output (Not Installed):**
```
JETBRAINS_IDE_HOME is not set or directory does not exist.
```

**What it checks:**
1. `$JETBRAINS_IDE_HOME` environment variable is set
2. Directory exists
3. Lists directory contents

**Note:** This command only checks installation. Rider backend is started automatically by JetBrains Gateway when you connect.

**Exit Codes:**
- `0` - Rider is installed and configured
- `1` - Rider is not installed or not configured

---

## Help Command

### help

Display help message with all available commands.

**Usage:**
```bash
ide-backend-manager help
```

**Output:**
```
Usage: ide-backend-manager <command>

Available commands:
  start              Start all IDE backends
  stop               Stop all IDE backends
  status             Show status of all IDE backends
  
  check-ssh          Check if SSH server is running
  start-ssh          Start SSH server
  stop-ssh           Stop SSH server
  
  check-vscode       Check if code-server is running
  start-vscode       Start code-server
  stop-vscode        Stop code-server
  
  check-tunnel       Check if VS Code tunnel is running
  start-tunnel       Start VS Code tunnel
  stop-tunnel        Stop VS Code tunnel
  
  check-jetbrains    Check if JetBrains IDE is installed
  
  help               Display this help message
```

**Exit Codes:**
- `0` - Always

---

## Usage Examples

### Starting Everything

```bash
# Start all backends at once
ide-backend-manager start

# Check they're all running
ide-backend-manager status
```

### Selective Startup

```bash
# Only start SSH and code-server
ide-backend-manager start-ssh
ide-backend-manager start-vscode

# Verify
ide-backend-manager check-ssh
ide-backend-manager check-vscode
```

### Restart a Service

```bash
# Restart code-server
ide-backend-manager stop-vscode
ide-backend-manager start-vscode

# Verify it's running
ide-backend-manager check-vscode
```

### Debugging

```bash
# Check what's running
ide-backend-manager status

# Check specific service
ide-backend-manager check-tunnel

# View tunnel logs
cat /tmp/vscode-tunnel.log
```

### Scripting

```bash
#!/bin/bash
# Start only if not running
if ! ide-backend-manager check-vscode; then
    echo "Starting code-server..."
    ide-backend-manager start-vscode
fi
```

```bash
#!/bin/bash
# Ensure all backends are running
ide-backend-manager start

# Wait for services
sleep 2

# Verify
ide-backend-manager status
```

---

## Script Location

The `ide-backend-manager` script is installed at:
```
/usr/local/bin/ide-backend-manager
```

**Source:** Copied during Docker build from `.devcontainer/ide-backend-manager.sh`

**Permissions:** Executable by all users (755)

---

## Exit Codes Summary

| Code | Meaning               |
| ---- | --------------------- |
| `0`  | Success               |
| `1`  | Failure / Not Running |

**Usage in Scripts:**
```bash
if ide-backend-manager check-ssh; then
    echo "SSH is running"
else
    echo "SSH is not running"
    ide-backend-manager start-ssh
fi
```

---

## See Also

- [Quick Start Guide](../guides/quick-start-guide.md) - Getting started
- [Troubleshooting Guide](../guides/troubleshooting-guide.md) - Fixing issues
- [Ports and Services](ports-and-services.md) - Port mappings and services
