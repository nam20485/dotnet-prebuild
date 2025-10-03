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
ARG PYTHON_VERSION=3.12

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
ENV PATH="/home/vscode/.dotnet:/home/vscode/.dotnet/tools:/root/.local/bin:$PATH"

# .NET workloads (moderately stable - SDK updates)
# Note: MAUI workload is not supported on Linux containers
RUN dotnet workload install wasm-tools && \
    dotnet workload update && \
    dotnet tool install -g aspire.cli --version ${ASPIRE_VERSION} && \
    dotnet new install Avalonia.Templates

# Static tool installations (less likely to change frequently)
RUN curl -fsSL https://bun.sh/install | BUN_INSTALL=/usr/local bash -s -- "bun-v${BUN_VERSION}" && \
    ln -sf /usr/local/bin/bun /usr/local/bin/bun

RUN curl -LsSf https://astral.sh/uv/${UV_VERSION}/install.sh | sh && \
    ln -sf /root/.local/bin/uv /usr/local/bin/uv

RUN gcloud components install beta --quiet

# Ansible configuration (fairly stable)
RUN ansible-galaxy collection install community.general && \
    mkdir -p /etc/ansible && \
    printf '[defaults]\ncollections_paths = ~/.ansible/collections:/usr/share/ansible/collections\n' > /etc/ansible/ansible.cfg

# Shell completions setup (stable)
RUN printf '\n# Tool completions\n' >> /etc/bash.bashrc && \
    printf 'if [ -f /usr/share/bash-completion/bash_completion ]; then . /usr/share/bash-completion/bash_completion; fi\n' >> /etc/bash.bashrc && \
    for c in ansible ansible-galaxy; do \
    echo "if command -v register-python-argcomplete >/dev/null 2>&1; then eval \"\$(register-python-argcomplete $c)\"; fi" >> /etc/bash.bashrc; \
    done

# NPM global packages (most likely to change versions frequently)
RUN npm install -g firebase-tools@${FIREBASE_VERSION}

RUN npm install --global cdktf-cli@${CDKTF_VERSION}

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

LABEL maintainer="your-email@example.com"
LABEL version="1.0"
