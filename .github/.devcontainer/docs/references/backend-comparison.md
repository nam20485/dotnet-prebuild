# IDE Backend Comparison

Detailed comparison of the available IDE backends and when to use each.

## Quick Comparison Table

| Feature               | SSH + Remote-SSH    | code-server         | VS Code Tunnel    | JetBrains Rider         |
| --------------------- | ------------------- | ------------------- | ----------------- | ----------------------- |
| **Access Method**     | SSH connection      | Browser (HTTP)      | vscode.dev        | JetBrains Gateway       |
| **Network Required**  | Direct/VPN          | Direct/VPN          | Internet only     | Direct/VPN              |
| **Client Software**   | VS Code Desktop     | Any browser         | Any browser       | Gateway + Rider license |
| **Port Required**     | 2222                | 8080                | None (outbound)   | 2222                    |
| **Authentication**    | SSH keys/password   | Token/password      | Microsoft account | SSH keys/password       |
| **Best For**          | Power users         | Quick access        | Remote work       | .NET development        |
| **Performance**       | Excellent           | Good                | Good              | Excellent               |
| **Extension Support** | Full                | Full                | Full              | N/A (Rider plugins)     |
| **Offline Capable**   | Yes (local network) | Yes (local network) | No                | Yes (local network)     |
| **Setup Complexity**  | Medium              | Low                 | Low               | High                    |

---

## SSH + VS Code Remote-SSH

### Overview
Traditional SSH access with VS Code connecting via the Remote-SSH extension.

### Architecture
```
Your Machine (VS Code Desktop)
       ↓ SSH (port 2222)
    Container (VS Code Server)
```

### Strengths
- ✅ **Best performance** - Direct binary protocol
- ✅ **Full VS Code features** - Native extension support
- ✅ **Secure** - SSH key authentication
- ✅ **Works offline** - No internet required
- ✅ **Most control** - Full SSH shell access
- ✅ **Persistent sessions** - Reconnects automatically

### Limitations
- ❌ Requires VS Code Desktop installed
- ❌ Need SSH client configured
- ❌ Requires network access to container
- ❌ Port forwarding setup needed

### Best For
- **Daily development work**
- **Power users comfortable with SSH**
- **When you need full VS Code features**
- **Corporate networks with VPN access**
- **Local Docker development**

### Setup Effort
🔧 **Medium** - Requires SSH key setup and VS Code Remote-SSH extension.

### When to Choose
Choose this when:
- You're developing on this container regularly
- You want the best performance
- You have VS Code Desktop installed
- You're on a trusted network

---

## code-server (Browser-Based VS Code)

### Overview
Full VS Code in your browser, no desktop client needed.

### Architecture
```
Your Browser
    ↓ HTTP (port 8080)
Container (code-server)
```

### Strengths
- ✅ **No client install** - Works in any browser
- ✅ **Easy to share** - Send URL + password
- ✅ **Cross-platform** - Works on any OS
- ✅ **Full VS Code UI** - Nearly identical to desktop
- ✅ **Extension support** - OpenVSX marketplace
- ✅ **Quick access** - Just open a URL

### Limitations
- ❌ Slightly slower than native
- ❌ Some extensions unavailable
- ❌ Browser limitations (file downloads, etc.)
- ❌ Requires port forwarding
- ❌ Token/password authentication only

### Best For
- **Quick code reviews**
- **Accessing from non-dev machines**
- **Chromebook or tablet access**
- **When you can't install VS Code**
- **Demonstration purposes**
- **Shared access scenarios**

### Setup Effort
🔧 **Low** - Just start the service and open browser.

### When to Choose
Choose this when:
- You don't want to install anything
- You're on a restricted device (work laptop, tablet)
- You need quick, temporary access
- You want to demo code to someone

---

## VS Code Tunnel

### Overview
Secure remote access via Microsoft's cloud relay, accessible from vscode.dev.

### Architecture
```
Your Browser (vscode.dev)
       ↓ Microsoft Relay
    Container (VS Code CLI)
```

### Strengths
- ✅ **No port forwarding** - Works through firewalls
- ✅ **No VPN needed** - Access from anywhere
- ✅ **Secure** - Microsoft authentication
- ✅ **No client install** - Use vscode.dev
- ✅ **Easy setup** - Just authenticate once
- ✅ **Works from anywhere** - Hotel, café, etc.

### Limitations
- ❌ **Requires internet** - Won't work offline
- ❌ **Requires Microsoft account**
- ❌ **Latency** - Goes through Microsoft servers
- ❌ **Less private** - Traffic routes through MS
- ❌ **Requires authentication** - One-time setup

### Best For
- **Remote work from anywhere**
- **Behind restrictive firewalls**
- **Working from home/travel**
- **No VPN access to corporate network**
- **Occasional access from various locations**

### Setup Effort
🔧 **Low** - Just authenticate with Microsoft account.

### When to Choose
Choose this when:
- You're working remotely with no VPN
- You're behind a strict firewall
- You need to access from multiple locations
- You don't want to manage SSH keys
- Port forwarding isn't an option

---

## JetBrains Rider (via Gateway)

### Overview
Professional .NET IDE from JetBrains, accessed via Gateway.

### Architecture
```
Your Machine (Gateway)
       ↓ SSH (port 2222)
    Container (Rider Backend)
```

### Strengths
- ✅ **Best for .NET** - Built specifically for .NET
- ✅ **Powerful refactoring** - Industry-leading tools
- ✅ **Advanced debugging** - Superior to VS Code
- ✅ **Code analysis** - ReSharper built-in
- ✅ **Database tools** - Integrated DB support
- ✅ **Full IDE** - More features than VS Code

### Limitations
- ❌ **Requires license** - Paid software (or free trial)
- ❌ **Higher resource usage** - Needs more RAM/CPU
- ❌ **Complex setup** - Gateway + backend installation
- ❌ **Learning curve** - Different from VS Code
- ❌ **Requires Gateway** - Must install client

### Best For
- **Professional .NET development**
- **Large codebases** - Better navigation
- **Complex refactoring** - When you need power tools
- **Teams using JetBrains** - Consistent tooling
- **Advanced debugging scenarios**

### Setup Effort
🔧 **High** - Requires Rider license, Gateway install, and backend configuration.

### When to Choose
Choose this when:
- You have a Rider license
- You're working on serious .NET projects
- You need advanced refactoring tools
- Your team uses JetBrains IDEs
- VS Code feels too limited for your needs

---

## Decision Matrix

### By Use Case

| Use Case                   | Best Choice      | Alternative      |
| -------------------------- | ---------------- | ---------------- |
| **Daily .NET development** | SSH + Remote-SSH | JetBrains Rider  |
| **Quick edits/reviews**    | code-server      | VS Code Tunnel   |
| **Remote work (no VPN)**   | VS Code Tunnel   | code-server      |
| **Corporate network**      | SSH + Remote-SSH | code-server      |
| **Tablet/Chromebook**      | code-server      | VS Code Tunnel   |
| **Professional .NET**      | JetBrains Rider  | SSH + Remote-SSH |
| **Teaching/Demo**          | code-server      | -                |
| **Behind firewall**        | VS Code Tunnel   | -                |

### By Network Scenario

| Network Situation        | Recommended Backend             |
| ------------------------ | ------------------------------- |
| **Direct Docker access** | SSH + Remote-SSH                |
| **Local network**        | SSH + Remote-SSH or code-server |
| **VPN to network**       | SSH + Remote-SSH                |
| **Public internet only** | VS Code Tunnel                  |
| **Strict firewall**      | VS Code Tunnel                  |
| **No port forwarding**   | VS Code Tunnel                  |

### By Experience Level

| User Level       | Best Starting Point       |
| ---------------- | ------------------------- |
| **Beginner**     | code-server (easiest)     |
| **Intermediate** | SSH + Remote-SSH          |
| **Advanced**     | SSH + Remote-SSH or Rider |
| **.NET Pro**     | JetBrains Rider           |

---

## Can I Use Multiple Backends?

**Yes!** All backends can run simultaneously. Common combinations:

### Development + Demo
- **Primary:** SSH + Remote-SSH (your daily work)
- **Secondary:** code-server (when showing code to others)

### Local + Remote
- **Local:** SSH + Remote-SSH (office work)
- **Remote:** VS Code Tunnel (work from home)

### Power User Setup
- **Primary:** JetBrains Rider (heavy .NET work)
- **Secondary:** code-server (quick edits, reviews)
- **Backup:** VS Code Tunnel (emergency remote access)

---

## Migration Between Backends

### From code-server to SSH
Easy - same VS Code, same settings sync.

### From SSH to Tunnel
Easy - same VS Code, just different connection method.

### From VS Code to Rider
Moderate - Different IDE, but Rider imports VS Code settings.

### Settings Sync
All VS Code-based backends (SSH, code-server, Tunnel) can share:
- Settings
- Extensions
- Keybindings
- Snippets

Enable Settings Sync in VS Code to sync across all methods.

---

## Performance Comparison

### Latency (Typical)
| Backend          | Latency  | Notes                            |
| ---------------- | -------- | -------------------------------- |
| SSH + Remote-SSH | 5-20ms   | Local network                    |
| code-server      | 10-30ms  | Local network + browser overhead |
| VS Code Tunnel   | 50-200ms | Goes through Microsoft relay     |
| Rider Gateway    | 5-20ms   | Local network                    |

### Resource Usage (Container)
| Backend          | RAM    | CPU    | Disk   |
| ---------------- | ------ | ------ | ------ |
| SSH + Remote-SSH | ~200MB | Low    | ~100MB |
| code-server      | ~300MB | Low    | ~200MB |
| VS Code Tunnel   | ~200MB | Low    | ~100MB |
| Rider            | ~1GB   | Medium | ~2GB   |

---

## Recommendations by Role

### Full-Stack Developer
**Primary:** SSH + Remote-SSH  
**Why:** Best performance, full features, works with any language

### .NET Specialist
**Primary:** JetBrains Rider  
**Why:** Superior .NET tooling, advanced refactoring

### DevOps Engineer
**Primary:** code-server  
**Why:** Quick access from anywhere, no client setup

### Remote Worker
**Primary:** VS Code Tunnel  
**Why:** Works without VPN, access from anywhere

### Student/Learner
**Primary:** code-server  
**Why:** Easy to use, works on any device

### Team Lead
**Use all:** Different tools for different tasks  
**Why:** Flexibility for code reviews, demos, development

---

See Also:
- [Ports and Services](ports-and-services.md) - Port mappings for each backend
- [Quick Start Guide](../guides/quick-start-guide.md) - Getting started
- [Command Reference](command-reference.md) - Backend management commands
