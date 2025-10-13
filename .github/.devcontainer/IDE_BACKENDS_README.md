# IDE Backends and Remote Development Setup

This devcontainer includes multiple IDE backends for flexible remote development options.

## Installed IDE Backends

### 1. **SSH Server**
The devcontainer includes an SSH server for remote development access.

- **Port**: 2222 (forwarded)
- **Configuration**: Configured via the `sshd` feature
- **Usage**: Connect using SSH from your local machine or JetBrains Gateway

**Connect via SSH:**
```bash
ssh -p 2222 vscode@localhost
```

### 2. **Code-Server (VS Code in Browser)**
Code-server provides a full VS Code experience in your browser.

- **Port**: 8080 (forwarded)
- **Start Command**: 
  ```bash
  code-server --bind-addr 0.0.0.0:8080
  ```
- **Access**: Navigate to `http://localhost:8080` in your browser

**Optional: Run code-server with authentication:**
```bash
code-server --bind-addr 0.0.0.0:8080 --auth password
```

### 3. **JetBrains Gateway Support**
IntelliJ IDEA Community backend is installed for JetBrains Gateway connections.

- **Location**: `/opt/ide-backends/idea`
- **Usage**: Connect via JetBrains Gateway using SSH

**Steps to connect with JetBrains Gateway:**
1. Open JetBrains Gateway
2. Select "Connect via SSH"
3. Use connection details: `ssh://vscode@localhost:2222`
4. Gateway will automatically detect and use the installed backend

## Port Forwarding

The following ports are automatically forwarded:

| Port | Service     | Description                  |
| ---- | ----------- | ---------------------------- |
| 2222 | SSH         | SSH server for remote access |
| 8080 | code-server | VS Code in browser           |

## Security Notes

- The default user is `vscode` with sudo privileges
- Password authentication is enabled for SSH
- For production use, consider using SSH key authentication
- Change default passwords and restrict access as needed

## Setting Up SSH Keys

For better security, set up SSH key authentication:

1. Generate an SSH key on your local machine (if you don't have one):
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```

2. Copy your public key to the devcontainer:
   ```bash
   ssh-copy-id -p 2222 vscode@localhost
   ```

3. Connect without a password:
   ```bash
   ssh -p 2222 vscode@localhost
   ```

## Customization

To add more IDE backends or modify the configuration:

1. Edit `Dockerfile` to install additional IDE backends
2. Update `devcontainer.json` to forward additional ports
3. Rebuild the container: `Dev Containers: Rebuild Container`

## Troubleshooting

### SSH Connection Issues
- Ensure port 2222 is not blocked by firewall
- Check SSH service status: `sudo service ssh status`
- Restart SSH service: `sudo service ssh restart`

### Code-Server Issues
- Ensure code-server is running: `ps aux | grep code-server`
- Check port 8080 is available: `netstat -tuln | grep 8080`
- View logs: `code-server --bind-addr 0.0.0.0:8080 --verbose`

### JetBrains Gateway Issues
- Verify IDEA backend is installed: `ls -la /opt/ide-backends/idea`
- Check SSH connection works first
- Ensure Gateway has the latest version

## Additional Resources

- [VS Code Remote Development](https://code.visualstudio.com/docs/remote/remote-overview)
- [JetBrains Gateway Documentation](https://www.jetbrains.com/help/idea/remote-development-overview.html)
- [code-server Documentation](https://coder.com/docs/code-server/latest)
