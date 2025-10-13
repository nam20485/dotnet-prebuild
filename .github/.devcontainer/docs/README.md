# IDE Backends Documentation

Welcome to the IDE backends documentation for the dotnet-prebuild devcontainer.

## 📚 Documentation Structure

### Quick Start
- **[Quick Start Guide](QUICK_START.md)** - Get up and running in minutes

### Complete Guides
- **[IDE Backends Guide](guides/ide-backends-guide.md)** - Complete setup and usage for all IDE backends
- **[Security Guide](guides/security-guide.md)** - SSH keys, authentication, and best practices
- **[Troubleshooting Guide](guides/troubleshooting-guide.md)** - Common issues and solutions

### References
- **[Backend Comparison](references/backend-comparison.md)** - Compare all IDE backend options
- **[Port Reference](references/ports-and-services.md)** - Port mappings and services
- **[Command Reference](references/command-reference.md)** - All ide-backend-manager commands

### Update History
- **[Latest Changes](updates/LATEST.md)** - Most recent updates
- **[Version History](updates/version-history.md)** - Complete changelog

## 🚀 Quick Links

### I want to...
- **Start coding right away** → [Quick Start Guide](QUICK_START.md)
- **Connect from my local VS Code** → [VS Code Remote-SSH Guide](guides/ide-backends-guide.md#3-vs-code-remote-ssh)
- **Access from anywhere** → [VS Code Tunnel Guide](guides/ide-backends-guide.md#4-vs-code-tunnel)
- **Use JetBrains Rider** → [Rider Gateway Guide](guides/ide-backends-guide.md#5-jetbrains-rider-gateway)
- **Work from a browser** → [code-server Guide](guides/ide-backends-guide.md#2-code-server-vs-code-in-browser)
- **Fix connection issues** → [Troubleshooting Guide](guides/troubleshooting-guide.md)

## 🎯 Available IDE Backends

This devcontainer provides **5 different ways** to develop:

| Backend                  | Access Method | Best For              |
| ------------------------ | ------------- | --------------------- |
| 🔧 **Direct SSH**         | Terminal      | Command-line work     |
| 🌐 **code-server**        | Browser       | Quick edits, mobile   |
| 💻 **VS Code Remote-SSH** | Local VS Code | Full local experience |
| 🌍 **VS Code Tunnel**     | Anywhere      | Remote access, no VPN |
| 🚀 **JetBrains Rider**    | Gateway       | Professional .NET dev |

## 📖 Getting Started

1. **Rebuild the container** (if you haven't already)
   ```bash
   # In VS Code Command Palette
   Dev Containers: Rebuild Container
   ```

2. **Check backend status**
   ```bash
   ide-backend-manager status
   ```

3. **Choose your IDE** and follow the appropriate guide:
   - [Quick Start](QUICK_START.md) for immediate access
   - [Complete Guide](guides/ide-backends-guide.md) for detailed setup

## 🔗 External Resources

- [VS Code Remote Development](https://code.visualstudio.com/docs/remote/remote-overview)
- [VS Code Remote-SSH](https://code.visualstudio.com/docs/remote/ssh)
- [VS Code Remote Tunnels](https://code.visualstudio.com/docs/remote/tunnels)
- [JetBrains Gateway](https://www.jetbrains.com/help/rider/remote-development-overview.html)
- [JetBrains Rider](https://www.jetbrains.com/rider/)
- [code-server](https://coder.com/docs/code-server/latest)

## 💬 Need Help?

- Check the [Troubleshooting Guide](guides/troubleshooting-guide.md)
- Review the [Command Reference](references/command-reference.md)
- See [Backend Comparison](references/backend-comparison.md) to choose the right tool
