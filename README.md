# dotnet-prebuild
devcontainer prebuild for my dotnet dev environment

## Installed Software and Tools

This devcontainer provides a comprehensive .NET development environment with the following software and tools:

### Base Environment
- **Base Image**: `mcr.microsoft.com/devcontainers/dotnet:1.3.7-9.0-bookworm-slim`
- **Operating System**: Debian Bookworm (slim)
- **Architecture**: Multi-platform (supports AMD64, ARM64)

### Development Platforms & Runtimes

#### .NET
- **.NET SDK**: 9.0 (from base image)
- **.NET Workloads**: 
  - `wasm-tools` - WebAssembly tools for Blazor development
  - Workloads are kept updated via `dotnet workload update`

#### Node.js & JavaScript
- **Node.js**: Version 22.x (LTS from NodeSource repository)
- **NPM**: Latest version (bundled with Node.js)

#### Python
- **Python**: Latest version (via devcontainer feature `ghcr.io/devcontainers/features/python:1`)

### Development Tools & CLIs

#### Version Control & GitHub
- **Git**: Pre-installed in base image
- **GitHub CLI (`gh`)**: Latest stable version (from official GitHub repository)

#### Cloud Development
- **Google Cloud CLI (`gcloud`)**: Latest version (installed from official tarball)
- **Firebase CLI**: Latest version (installed via NPM global package)

#### Container & Infrastructure
- **Docker**: Docker-in-Docker support (via devcontainer feature `ghcr.io/devcontainers/features/docker-in-docker:2`)

#### Remote Access
- **SSH Daemon**: Enabled (via devcontainer feature `ghcr.io/devcontainers/features/sshd:1`)

### System Packages & Dependencies
- **build-essential**: GCC compiler and build tools
- **apt-transport-https**: Secure package downloads
- **ca-certificates**: SSL certificate authorities
- **gnupg**: GNU Privacy Guard for package verification
- **curl**: Command-line HTTP client

### VS Code Extensions
The following extensions are pre-installed for enhanced development experience:

#### .NET Development
- `ms-dotnettools.csharp` - C# language support
- `ms-dotnettools.csharp-devkit` - Enhanced C# development tools
- `ms-dotnettools.csharp-extensions` - Additional C# utilities
- `ms-dotnettools.vscodeintellicode-csharp` - AI-powered IntelliSense for C#
- `ms-dotnettools.dotnet-maui` - .NET Multi-platform App UI development
- `aliasadidev.nugetpackagemanagergui` - Visual NuGet package manager

#### AI & Productivity
- `github.copilot` - GitHub Copilot AI coding assistant
- `github.copilot-chat` - GitHub Copilot Chat interface

#### API & Configuration
- `42crunch.vscode-openapi` - OpenAPI/Swagger specification support
- `ahmadalli.vscode-nginx-conf` - Nginx configuration file support

#### Web Development
- `christian-kohler.npm-intellisense` - NPM package IntelliSense
- `dbaeumer.vscode-eslint` - ESLint JavaScript linting

#### DevOps & CI/CD
- `github.vscode-github-actions` - GitHub Actions workflow support

#### Cloud Development
- `googlecloudtools.cloudcode` - Google Cloud development tools

#### Testing & Quality
- `hbenl.vscode-test-explorer` - Unified test runner interface

#### System Tools
- `ms-vscode.powershell` - PowerShell language support

### Container Configuration
- **User**: Root user (for development flexibility)
- **Cache Strategy**: Uses GitHub Container Registry (`ghcr.io/nam20485/dotnet-prebuild:latest`)
- **Build Context**: Local directory with Dockerfile
- **Post-Create Command**: `./scripts/onPostCreateCommand.ps1` (when available)

### Development Features
- **WebAssembly Support**: Full .NET to WebAssembly compilation support
- **Multi-platform Development**: Support for web, desktop, and mobile .NET applications
- **Cloud-Native Development**: Integrated tools for Azure, Google Cloud, and Firebase
- **Modern JavaScript Development**: Node.js 22.x with latest NPM tooling
- **Container Development**: Docker-in-Docker for containerized application development
- **AI-Assisted Coding**: GitHub Copilot integration for enhanced productivity

This environment is optimized for modern .NET development with full-stack capabilities, cloud deployment, and DevOps integration.
