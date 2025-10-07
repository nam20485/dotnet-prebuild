FROM mcr.microsoft.com/devcontainers/dotnet:1.5.4-9.0-noble

ARG DEBIAN_FRONTEND=noninteractive

# Version pinning for all tools
ARG NODE_VERSION=22
ARG FIREBASE_VERSION=14.6.0
ARG CDKTF_VERSION=0.21.0
ARG ASPIRE_VERSION=9.5.0
ARG AVALONIA_VERSION=11.2.2
ARG BUN_VERSION=1.1.38
ARG UV_VERSION=0.5.11

# Base system packages (least likely to change)
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    apt-get update -y && \
    apt-get install -y -q --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    gnupg2 \
    software-properties-common \
    unzip \
    jq \
    apt-transport-https \
    lsb-release \
    wget \
    xz-utils \
    python3 \
    sshpass \
    sudo \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# System-level repositories and keys (stable)
RUN curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list && \
    mkdir -p -m 755 /etc/apt/keyrings && \
    curl -fsSL -o /etc/apt/keyrings/githubcli-archive-keyring.gpg https://cli.github.com/packages/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list

# PowerShell Core repository setup
ADD https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb /tmp/packages-microsoft-prod.deb
RUN dpkg -i /tmp/packages-microsoft-prod.deb && \
    rm /tmp/packages-microsoft-prod.deb

# Node.js repository setup (stable versions)
RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | bash -

# Install apt packages (grouped by stability)
RUN apt-get update -y && \
    apt-get install -y -q --no-install-recommends \
    google-cloud-cli \
    terraform \
    gh \
    ansible \
    powershell \
    nodejs && \
    rm -rf /var/lib/apt/lists/*

# Environment variables (stable)
ENV PATH="/home/vscode/.dotnet:/home/vscode/.dotnet/tools:/home/vscode/.local/bin:$PATH"

# Configure vscode user with sudo access
RUN usermod -aG sudo vscode && \
    echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/vscode && \
    chmod 0440 /etc/sudoers.d/vscode

# .NET workloads (moderately stable - SDK updates)
# Note: MAUI workload is not supported on Linux containers and skipping
# dotnet workload update keeps build deterministic against the base image
RUN dotnet workload install wasm-tools && \
    dotnet tool install -g aspire.cli --version ${ASPIRE_VERSION} && \
    dotnet new install Avalonia.Templates

# Static tool installations (less likely to change frequently)
RUN curl -fsSL https://bun.sh/install | BUN_INSTALL=/usr/local bash -s -- "bun-v${BUN_VERSION}"

# Install uv for the vscode user
USER vscode
RUN curl -LsSf https://astral.sh/uv/${UV_VERSION}/install.sh | sh && \
    mkdir -p /home/vscode/.local/bin
USER root
RUN ln -sf /home/vscode/.local/bin/uv /usr/local/bin/uv

# Ansible configuration (fairly stable)
RUN ansible-galaxy collection install community.general && \
    mkdir -p /etc/ansible && \
    printf '[defaults]\ncollections_paths = ~/.ansible/collections:/usr/share/ansible/collections\n' > /etc/ansible/ansible.cfg

# Shell completions setup (stable)
RUN printf '\n# Tool completions\n' >> /etc/bash.bashrc && \
    printf 'if [ -f /usr/share/bash-completion/bash_completion ]; then . /usr/share/bash-completion/bash_completion; fi\n' >> /etc/bash.bashrc && \
    # Ansible completions (argcomplete-based)
    for c in ansible ansible-galaxy; do \
    echo "if command -v register-python-argcomplete >/dev/null 2>&1; then eval \"\$(register-python-argcomplete $c)\"; fi" >> /etc/bash.bashrc; \
    done && \
    # dotnet CLI completions
    printf '\n# dotnet completions\n' >> /etc/bash.bashrc && \
    printf 'export DOTNET_CLI_TELEMETRY_OPTOUT=1\n' >> /etc/bash.bashrc && \
    printf '_dotnet_bash_complete() {\n' >> /etc/bash.bashrc && \
    printf '  local cur="${COMP_WORDS[COMP_CWORD]}" IFS=$'"'"'\\n'"'"'\n' >> /etc/bash.bashrc && \
    printf '  local candidates=$(dotnet complete --position "${COMP_POINT}" "${COMP_LINE}" 2>/dev/null)\n' >> /etc/bash.bashrc && \
    printf '  COMPREPLY=($(compgen -W "$candidates" -- "$cur"))\n' >> /etc/bash.bashrc && \
    printf '}\n' >> /etc/bash.bashrc && \
    printf 'complete -f -F _dotnet_bash_complete dotnet\n' >> /etc/bash.bashrc && \
    # GitHub CLI completions
    printf '\n# gh completions\n' >> /etc/bash.bashrc && \
    printf 'if command -v gh >/dev/null 2>&1; then eval "$(gh completion -s bash)"; fi\n' >> /etc/bash.bashrc && \
    # Google Cloud CLI completions
    printf '\n# gcloud completions\n' >> /etc/bash.bashrc && \
    printf 'if [ -f /usr/lib/google-cloud-sdk/completion.bash.inc ]; then . /usr/lib/google-cloud-sdk/completion.bash.inc; fi\n' >> /etc/bash.bashrc && \
    # Terraform completions
    printf '\n# terraform completions\n' >> /etc/bash.bashrc && \
    printf 'if command -v terraform >/dev/null 2>&1; then complete -C /usr/bin/terraform terraform; fi\n' >> /etc/bash.bashrc && \
    # npm completions
    printf '\n# npm completions\n' >> /etc/bash.bashrc && \
    printf 'if command -v npm >/dev/null 2>&1; then eval "$(npm completion 2>/dev/null)"; fi\n' >> /etc/bash.bashrc && \
    # bun completions
    printf '\n# bun completions\n' >> /etc/bash.bashrc && \
    printf 'if command -v bun >/dev/null 2>&1; then\n' >> /etc/bash.bashrc && \
    printf '  [ -s "/home/vscode/.bun/_bun" ] && . "/home/vscode/.bun/_bun"\n' >> /etc/bash.bashrc && \
    printf 'fi\n' >> /etc/bash.bashrc && \
    # uv completions
    printf '\n# uv completions\n' >> /etc/bash.bashrc && \
    printf 'if command -v uv >/dev/null 2>&1; then eval "$(uv generate-shell-completion bash)"; fi\n' >> /etc/bash.bashrc

# PowerShell profile setup for completions
RUN mkdir -p /home/vscode/.config/powershell && \
    printf '# PowerShell completions and settings\n' > /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    printf 'Set-PSReadLineOption -PredictionSource History\n' >> /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    printf 'Set-PSReadLineOption -PredictionViewStyle ListView\n' >> /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    printf 'Set-PSReadLineOption -EditMode Windows\n' >> /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    printf '# dotnet CLI completions\n' >> /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    printf 'Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {\n' >> /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    printf '    param($commandName, $wordToComplete, $cursorPosition)\n' >> /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    printf '    dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {\n' >> /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    printf '        [System.Management.Automation.CompletionResult]::new($_, $_, '"'"'ParameterValue'"'"', $_)\n' >> /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    printf '    }\n' >> /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    printf '}\n' >> /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    printf '# gh CLI completions\n' >> /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    printf 'if (Get-Command gh -ErrorAction SilentlyContinue) {\n' >> /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    printf '    Invoke-Expression -Command $(gh completion -s powershell | Out-String)\n' >> /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    printf '}\n' >> /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    printf '# terraform completions\n' >> /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    printf 'if (Get-Command terraform -ErrorAction SilentlyContinue) {\n' >> /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    printf '    Register-ArgumentCompleter -Native -CommandName terraform -ScriptBlock {\n' >> /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    printf '        param($wordToComplete, $commandAst, $cursorPosition)\n' >> /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    printf '        $env:COMP_LINE = $commandAst.ToString()\n' >> /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    printf '        $env:COMP_POINT = $cursorPosition\n' >> /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    printf '        terraform | ForEach-Object {\n' >> /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    printf '            [System.Management.Automation.CompletionResult]::new($_, $_, '"'"'ParameterValue'"'"', $_)\n' >> /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    printf '        }\n' >> /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    printf '        Remove-Item Env:\\COMP_LINE, Env:\\COMP_POINT -ErrorAction SilentlyContinue\n' >> /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    printf '    }\n' >> /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    printf '}\n' >> /home/vscode/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    chown -R vscode:vscode /home/vscode/.config



# NPM global packages (most likely to change versions frequently)
RUN npm install -g \
    firebase-tools@${FIREBASE_VERSION} \
    cdktf-cli@${CDKTF_VERSION} && \
    npm cache clean --force

# Final verification (changes when tool versions change)
RUN set -e; \
    node --version; \
    npm --version; \
    bun --version; \
    gh --version; \
    gcloud --version; \
    firebase --version; \
    terraform --version; \
    cdktf --version; \
    ansible --version; \
    uv --version; \
    pwsh -v

# Switch to vscode user for development
USER vscode
WORKDIR /home/vscode

LABEL maintainer="your-email@example.com"
LABEL version="1.0"
