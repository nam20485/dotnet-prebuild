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
ARG GRAPHITE_VERSION=1.4.6

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
    openssh-server \
    libicu-dev \
    libkrb5-dev \
    zlib1g \
    libssl-dev \
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
COPY setup-bash-completions.sh /tmp/
RUN chmod +x /tmp/setup-bash-completions.sh && \
    /tmp/setup-bash-completions.sh && \
    rm /tmp/setup-bash-completions.sh

# Copy IDE backend manager script
COPY ide-backend-manager.sh /usr/local/bin/ide-backend-manager
RUN chmod +x /usr/local/bin/ide-backend-manager

# PowerShell profile setup for completions
RUN mkdir -p /home/vscode/.config/powershell
COPY Microsoft.PowerShell_profile.ps1 /home/vscode/.config/powershell/
RUN chown -R vscode:vscode /home/vscode/.config

# Install IDE backends for remote development
# Install JetBrains Rider backend for Gateway
RUN mkdir -p /opt/ide-backends && \
    curl -L "https://download.jetbrains.com/rider/JetBrains.Rider-2024.2.7.tar.gz" -o /tmp/rider.tar.gz && \
    tar -xzf /tmp/rider.tar.gz -C /opt/ide-backends && \
    mv /opt/ide-backends/JetBrains\ Rider-* /opt/ide-backends/rider && \
    rm /tmp/rider.tar.gz && \
    chown -R vscode:vscode /opt/ide-backends

# Install code-server (VS Code in browser)
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Install VS Code Server CLI (for Remote-SSH and Tunnel)
RUN curl -fsSL "https://code.visualstudio.com/sha/download?build=stable&os=cli-linux-x64" -o /tmp/vscode-cli.tar.gz && \
    tar -xzf /tmp/vscode-cli.tar.gz -C /usr/local/bin && \
    rm /tmp/vscode-cli.tar.gz && \
    chmod +x /usr/local/bin/code && \
    chown vscode:vscode /usr/local/bin/code

# Setup SSH for IDE backends
RUN mkdir -p /run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Add IDE backend environment variables
ENV JETBRAINS_IDE_HOME=/opt/ide-backends/rider
ENV PATH="${JETBRAINS_IDE_HOME}/bin:${PATH}"


# NPM global packages (most likely to change versions frequently)
RUN npm install -g \
    firebase-tools@${FIREBASE_VERSION} \
    cdktf-cli@${CDKTF_VERSION} \
    @withgraphite/graphite-cli@${GRAPHITE_VERSION} && \
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
    gt --version; \
    ansible --version; \
    uv --version; \
    pwsh -v

# Switch to vscode user for development
USER vscode
WORKDIR /home/vscode

LABEL maintainer="nmiller@intel-agency.com"
LABEL version="1.0"
