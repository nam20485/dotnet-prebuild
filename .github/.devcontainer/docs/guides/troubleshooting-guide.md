# Troubleshooting Guide

Common issues and solutions for IDE backends.

## Quick Diagnosis

```bash
# Check status of all backends
ide-backend-manager status

# Check specific backend
ide-backend-manager check-ssh
ide-backend-manager check-vscode
ide-backend-manager check-tunnel
ide-backend-manager check-jetbrains
```

---

## SSH Connection Issues

### Problem: Cannot connect via SSH

**Symptoms:**
- `Connection refused` error
- `Connection timed out` error

**Solutions:**

1. **Check if SSH is running:**
   ```bash
   sudo service ssh status
   ```

2. **Start SSH if needed:**
   ```bash
   ide-backend-manager start-ssh
   # Or manually:
   sudo service ssh start
   ```

3. **Check port forwarding:**
   - Ensure port 2222 is forwarded in `devcontainer.json`
   - Check firewall isn't blocking port 2222

4. **Test from within container:**
   ```bash
   ssh -p 2222 vscode@localhost
   ```

5. **Check SSH logs:**
   ```bash
   sudo journalctl -u ssh -n 50
   ```

### Problem: SSH asks for password every time

**Solution:**

Set up SSH key authentication (see [Security Guide](security-guide.md#ssh-key-authentication)).

### Problem: Permission denied (publickey)

**Solutions:**

1. **Check authorized_keys permissions:**
   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/authorized_keys
   ```

2. **Verify key is added:**
   ```bash
   cat ~/.ssh/authorized_keys
   ```

3. **Check SSH logs for details:**
   ```bash
   sudo tail -f /var/log/auth.log
   ```

---

## code-server Issues

### Problem: code-server won't start

**Symptoms:**
- Command hangs or fails
- Port 8080 not accessible

**Solutions:**

1. **Check if already running:**
   ```bash
   ps aux | grep code-server
   ```

2. **Kill existing process:**
   ```bash
   pkill -f code-server
   ```

3. **Check port availability:**
   ```bash
   netstat -tuln | grep 8080
   # Or:
   sudo lsof -i :8080
   ```

4. **Start with verbose logging:**
   ```bash
   code-server --bind-addr 0.0.0.0:8080 --verbose
   ```

5. **Check logs:**
   ```bash
   cat ~/.local/share/code-server/coder-logs/*.log
   ```

### Problem: code-server works but can't access in browser

**Solutions:**

1. **Verify port forwarding:**
   - Check `devcontainer.json` has port 8080 forwarded
   - In VS Code, check Ports panel

2. **Try direct connection:**
   ```
   http://localhost:8080
   ```

3. **Check if authentication is enabled:**
   - code-server may require a password
   - Check: `cat ~/.config/code-server/config.yaml`

### Problem: Extensions won't install in code-server

**Solutions:**

1. **Check internet connectivity:**
   ```bash
   ping -c 3 open-vsx.org
   ```

2. **Clear extension cache:**
   ```bash
   rm -rf ~/.local/share/code-server/extensions
   ```

3. **Install manually:**
   ```bash
   code-server --install-extension <extension-id>
   ```

---

## VS Code Remote-SSH Issues

### Problem: Remote-SSH won't connect

**Symptoms:**
- Connection fails in VS Code
- "Could not establish connection" error

**Solutions:**

1. **Test SSH directly first:**
   ```bash
   ssh -p 2222 vscode@localhost
   ```
   If this fails, fix SSH first (see above).

2. **Check Remote-SSH extension is installed:**
   - In VS Code: Extensions → Search "Remote - SSH"

3. **Remove and re-add host:**
   - F1 → "Remote-SSH: Kill VS Code Server on Host"
   - Remove host from SSH config
   - Re-add and try again

4. **Check VS Code logs:**
   - View → Output → Remote-SSH

5. **Try with verbose logging:**
   - F1 → "Remote-SSH: Show Log"
   - Attempt connection
   - Review logs for specific errors

### Problem: VS Code Server version mismatch

**Solution:**

```bash
# Remove server installations
rm -rf ~/.vscode-server

# Reconnect - VS Code will reinstall
```

### Problem: Extensions don't sync

**Solutions:**

1. **Enable Settings Sync:**
   - F1 → "Settings Sync: Turn On"

2. **Manually install extensions:**
   - View → Extensions
   - Install needed extensions in remote

---

## VS Code Tunnel Issues

### Problem: Tunnel won't start

**Symptoms:**
- `ide-backend-manager start-tunnel` fails
- No tunnel process running

**Solutions:**

1. **Check if code CLI is installed:**
   ```bash
   which code
   code --version
   ```

2. **Try manual start to see errors:**
   ```bash
   code tunnel --accept-server-license-terms
   ```

3. **Check logs:**
   ```bash
   cat /tmp/vscode-tunnel.log
   ```

4. **Verify permissions:**
   ```bash
   ls -la /usr/local/bin/code
   ```

### Problem: Authentication fails

**Solutions:**

1. **Clear stored credentials:**
   ```bash
   rm -rf ~/.vscode-cli
   ```

2. **Start tunnel and re-authenticate:**
   ```bash
   ide-backend-manager start-tunnel
   ```

3. **Use a different browser for authentication:**
   - Some browsers block the auth flow
   - Try Chrome, Firefox, or Edge

### Problem: Can't find tunnel connection URL

**Solutions:**

1. **Check the log file:**
   ```bash
   cat /tmp/vscode-tunnel.log | grep -i "tunnel"
   ```

2. **Look for authentication URL:**
   ```bash
   cat /tmp/vscode-tunnel.log | grep -i "http"
   ```

3. **Restart tunnel with output:**
   ```bash
   ide-backend-manager stop-tunnel
   code tunnel --accept-server-license-terms
   ```

### Problem: Tunnel disconnects frequently

**Solutions:**

1. **Check network stability:**
   ```bash
   ping -c 10 vscode.dev
   ```

2. **Monitor tunnel process:**
   ```bash
   ps aux | grep "code tunnel"
   ```

3. **Run tunnel in foreground to see errors:**
   ```bash
   code tunnel --accept-server-license-terms
   ```

---

## JetBrains Rider / Gateway Issues

### Problem: Gateway can't find Rider backend

**Symptoms:**
- Gateway connects via SSH but no IDE detected
- "No backend found" error

**Solutions:**

1. **Verify Rider is installed:**
   ```bash
   ls -la /opt/ide-backends/rider
   ```

2. **Check environment variable:**
   ```bash
   echo $JETBRAINS_IDE_HOME
   # Should output: /opt/ide-backends/rider
   ```

3. **Verify in PATH:**
   ```bash
   echo $PATH | grep rider
   ```

4. **Test SSH connection first:**
   ```bash
   ssh -p 2222 vscode@localhost
   ```

### Problem: Gateway connection is slow

**Solutions:**

1. **Check network latency:**
   ```bash
   ping localhost
   ```

2. **Reduce indexing:**
   - In Rider: File → Settings → Directories
   - Mark build/output folders as Excluded

3. **Increase Gateway memory:**
   - In Gateway settings
   - Increase heap size for remote IDE

### Problem: Rider backend crashes

**Solutions:**

1. **Check logs:**
   ```bash
   ls -la /opt/ide-backends/rider/log/
   cat /opt/ide-backends/rider/log/idea.log
   ```

2. **Check system resources:**
   ```bash
   free -h
   df -h
   ```

3. **Restart the backend:**
   - Disconnect from Gateway
   - `ide-backend-manager stop`
   - `ide-backend-manager start`
   - Reconnect

4. **Clear caches:**
   ```bash
   rm -rf ~/.cache/JetBrains/
   ```

---

## General Issues

### Problem: Container is slow

**Solutions:**

1. **Check resource usage:**
   ```bash
   top
   # Or:
   htop  # if installed
   ```

2. **Check disk space:**
   ```bash
   df -h
   ```

3. **Clean up Docker:**
   ```bash
   docker system prune -a
   ```

4. **Increase container resources:**
   - Docker Desktop → Settings → Resources
   - Increase CPU and Memory allocation

### Problem: Port already in use

**Symptoms:**
- "Address already in use" errors
- Services won't start

**Solutions:**

1. **Find process using the port:**
   ```bash
   sudo lsof -i :2222
   # Or:
   sudo netstat -tulpn | grep 2222
   ```

2. **Kill the process:**
   ```bash
   sudo kill -9 <PID>
   ```

3. **Change port in devcontainer.json:**
   - Use a different port number
   - Rebuild container

### Problem: ide-backend-manager command not found

**Solutions:**

1. **Check if script exists:**
   ```bash
   ls -la /usr/local/bin/ide-backend-manager
   ```

2. **Make executable:**
   ```bash
   sudo chmod +x /usr/local/bin/ide-backend-manager
   ```

3. **Rebuild container:**
   - The script should be installed during build
   - Rebuild to ensure it's copied correctly

---

## Getting More Help

### Enable Debug Logging

Most services support verbose/debug modes:

```bash
# SSH debug
sudo /usr/sbin/sshd -d

# code-server verbose
code-server --bind-addr 0.0.0.0:8080 --verbose

# VS Code tunnel with logging
code tunnel --accept-server-license-terms --verbose
```

### Collect Diagnostic Information

```bash
# System info
uname -a
cat /etc/os-release

# Network info
ip addr
netstat -tulpn

# Service status
ide-backend-manager status

# Recent logs
sudo journalctl -n 100
```

### Reset Everything

If all else fails:

```bash
# Stop all services
ide-backend-manager stop

# Clean up
rm -rf ~/.vscode-server
rm -rf ~/.vscode-cli
rm -rf ~/.config/code-server
rm -rf ~/.cache/JetBrains

# Rebuild container
# In VS Code: Dev Containers: Rebuild Container
```

---

## Still Having Issues?

1. Check the [IDE Backends Guide](ide-backends-guide.md) for detailed setup
2. Review the [Security Guide](security-guide.md) for authentication issues
3. Check the [Command Reference](../references/command-reference.md) for available commands
4. Review container logs: `docker logs <container-id>`
