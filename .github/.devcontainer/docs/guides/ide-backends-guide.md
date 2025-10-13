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

### 3. **VS Code Remote-SSH**
VS Code Server is installed for connecting with the Remote-SSH extension from your local VS Code.

- **Connection**: Use VS Code Remote-SSH extension
- **Host**: `vscode@localhost`
- **Port**: 2222

**Steps to connect with VS Code Remote-SSH:**
1. Install the "Remote - SSH" extension in your local VS Code
2. Press `F1` and select "Remote-SSH: Connect to Host..."
3. Enter: `ssh vscode@localhost -p 2222`
4. VS Code will connect and install the server automatically

### 4. **VS Code Tunnel**
VS Code CLI with tunnel support allows you to connect from anywhere using vscode.dev or your local VS Code.

- **Start Command**: 
  ```bash
  code tunnel --accept-server-license-terms
  ```
  Or use: `ide-backend-manager start-tunnel`
- **Access**: Via vscode.dev or local VS Code using the tunnel URL

**Steps to use VS Code Tunnel:**
1. Start the tunnel: `ide-backend-manager start-tunnel`
2. On first run, authenticate via browser
3. Get the connection URL from `/tmp/vscode-tunnel.log`
4. Open vscode.dev or your local VS Code
5. Connect using the provided tunnel name/URL

**Note**: The tunnel creates a secure connection without needing port forwarding or SSH access.

### 5. **JetBrains Rider Gateway**
JetBrains Rider backend is installed for JetBrains Gateway connections, optimized for .NET development.

- **Location**: `/opt/ide-backends/rider`
- **Usage**: Connect via JetBrains Gateway using SSH

**Steps to connect with JetBrains Gateway:**
1. Open JetBrains Gateway
2. Select "Connect via SSH"
3. Use connection details: `ssh://vscode@localhost:2222`
4. Gateway will automatically detect and use the installed Rider backend

## Port Forwarding

The following ports are automatically forwarded:

| Port | Service     | Description                  |
| ---- | ----------- | ---------------------------- |
| 2222 | SSH         | SSH server for remote access |
| 8080 | code-server | VS Code in browser           |

**Note**: 
- VS Code Remote-SSH and JetBrains Gateway both use the SSH port (2222) and don't require additional ports.
- VS Code Tunnel doesn't require port forwarding - it creates a secure tunnel through VS Code's infrastructure.

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

### VS Code Remote-SSH Issues
- Ensure SSH connection works first: `ssh -p 2222 vscode@localhost`
- Check VS Code Remote-SSH extension is installed
- Try removing and re-adding the SSH host
- Check VS Code logs: View → Output → Remote-SSH

### VS Code Tunnel Issues
- Check if tunnel is running: `ide-backend-manager check-tunnel`
- View tunnel logs: `cat /tmp/vscode-tunnel.log`
- Restart tunnel: `ide-backend-manager stop-tunnel && ide-backend-manager start-tunnel`
- Manual start: `code tunnel --accept-server-license-terms`
- Check authentication status and re-authenticate if needed

### JetBrains Gateway Issues
- Verify Rider backend is installed: `ls -la /opt/ide-backends/rider`
- Check SSH connection works first
- Ensure Gateway has the latest version
- Clear Gateway cache if needed

## Additional Resources

- [VS Code Remote Development](https://code.visualstudio.com/docs/remote/remote-overview)
- [VS Code Remote-SSH](https://code.visualstudio.com/docs/remote/ssh)
- [VS Code Remote Tunnels](https://code.visualstudio.com/docs/remote/tunnels)
- [JetBrains Gateway Documentation](https://www.jetbrains.com/help/rider/remote-development-overview.html)
- [JetBrains Rider](https://www.jetbrains.com/rider/)
- [code-server Documentation](https://coder.com/docs/code-server/latest)
