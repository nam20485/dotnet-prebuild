# Security Guide

This guide covers security best practices for the IDE backends in your devcontainer.

## SSH Key Authentication

For better security than password authentication, set up SSH key-based authentication.

### Generate an SSH Key

If you don't already have an SSH key:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

Follow the prompts to save the key (default location is fine).

### Copy Your Public Key to the Container

```bash
ssh-copy-id -p 2222 vscode@localhost
```

This copies your public key to the container's `~/.ssh/authorized_keys` file.

### Test Key-Based Authentication

```bash
ssh -p 2222 vscode@localhost
```

You should now connect without being prompted for a password.

### Disable Password Authentication (Optional)

For maximum security, you can disable password authentication once SSH keys are working:

```bash
# Connect to the container
ssh -p 2222 vscode@localhost

# Edit SSH config
sudo nano /etc/ssh/sshd_config

# Change this line:
# PasswordAuthentication yes
# To:
# PasswordAuthentication no

# Restart SSH
sudo service ssh restart
```

⚠️ **Warning**: Make sure SSH key authentication is working before disabling password auth!

## VS Code Tunnel Authentication

The VS Code tunnel requires authentication with a Microsoft or GitHub account.

### First-Time Setup

1. Start the tunnel:
   ```bash
   ide-backend-manager start-tunnel
   ```

2. You'll see a URL for authentication
3. Open the URL in your browser
4. Sign in with Microsoft or GitHub
5. The tunnel is now registered to your account

### Re-authentication

If you need to re-authenticate:

```bash
# Stop the tunnel
ide-backend-manager stop-tunnel

# Clear stored credentials (if needed)
rm -rf ~/.vscode-cli

# Start again
ide-backend-manager start-tunnel
```

## code-server Authentication

By default, code-server runs without authentication when started with:
```bash
code-server --bind-addr 0.0.0.0:8080
```

### Enable Password Authentication

For added security:

```bash
code-server --bind-addr 0.0.0.0:8080 --auth password
```

code-server will generate a random password stored in:
```
~/.config/code-server/config.yaml
```

View the password:
```bash
cat ~/.config/code-server/config.yaml
```

### Set a Custom Password

Edit the config file:
```bash
nano ~/.config/code-server/config.yaml
```

Change the password field, then restart code-server.

## Network Security

### Port Exposure

The devcontainer forwards these ports:

| Port | Service     | Risk Level          |
| ---- | ----------- | ------------------- |
| 2222 | SSH         | Low (with key auth) |
| 8080 | code-server | Medium (local only) |

### Recommendations

1. **For local development**: Current setup is fine
2. **For shared environments**: 
   - Enable SSH key authentication only
   - Add password to code-server
   - Use firewall rules to restrict access
3. **For production**: 
   - Don't expose ports publicly
   - Use VPN for remote access
   - Enable all authentication methods

## User Permissions

The default user (`vscode`) has:
- ✅ Sudo privileges (no password required)
- ✅ Docker access (via docker-in-docker feature)
- ✅ SSH access

### Restrict Sudo Access (Optional)

If you want to require a password for sudo:

```bash
# Edit sudoers file
sudo visudo

# Find the line:
# vscode ALL=(ALL) NOPASSWD:ALL

# Change to:
# vscode ALL=(ALL) ALL
```

## Secrets Management

### Environment Variables

Never hardcode secrets. Use environment variables:

```bash
# In devcontainer.json, add:
"remoteEnv": {
  "MY_SECRET": "${localEnv:MY_SECRET}"
}
```

### Git Credentials

Use credential helpers:

```bash
# Store credentials in memory (for the session)
git config --global credential.helper cache

# Or use the system keychain (if available)
git config --global credential.helper store
```

### Docker Secrets

For sensitive data in Docker:

```bash
# Use Docker secrets (if in Swarm mode)
# Or mount secrets as files:
docker run -v /path/to/secret:/run/secrets/my_secret
```

## JetBrains Gateway Security

Gateway connections use SSH, so:
- SSH key authentication is recommended
- Gateway stores connection details locally
- Sessions are encrypted via SSH tunnel

## Best Practices Checklist

- [ ] Use SSH key authentication
- [ ] Disable SSH password authentication (after keys work)
- [ ] Add password to code-server if exposed
- [ ] Don't commit secrets to git
- [ ] Use environment variables for sensitive data
- [ ] Keep software updated (rebuild container periodically)
- [ ] Review sudo access requirements
- [ ] Use firewall rules in shared environments
- [ ] Regularly rotate passwords and keys
- [ ] Monitor SSH access logs: `sudo journalctl -u ssh`

## Incident Response

### Suspected Unauthorized Access

1. **Immediately**:
   ```bash
   # Check active SSH sessions
   who
   
   # Check SSH logs
   sudo journalctl -u ssh | tail -50
   
   # Kill suspicious sessions
   sudo pkill -u <username>
   ```

2. **Secure the system**:
   ```bash
   # Change passwords
   passwd
   
   # Regenerate SSH keys
   ssh-keygen -t ed25519 -C "new_email@example.com"
   
   # Restart services
   ide-backend-manager stop
   ```

3. **Investigate**:
   ```bash
   # Check command history
   history
   
   # Check recent file modifications
   find /home/vscode -type f -mtime -1
   
   # Check running processes
   ps aux
   ```

## Additional Resources

- [SSH Best Practices](https://www.ssh.com/academy/ssh/best-practices)
- [VS Code Security](https://code.visualstudio.com/docs/editor/workspace-trust)
- [Docker Security](https://docs.docker.com/engine/security/)
- [GitHub Security Best Practices](https://docs.github.com/en/code-security)
