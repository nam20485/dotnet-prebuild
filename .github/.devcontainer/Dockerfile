FROM mcr.microsoft.com/devcontainers/dotnet:1.5.1-9.0-noble

# Ensure we have root privileges for package installs during build
USER root

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y -q --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    gnupg \
    software-properties-common \
    unzip \
    xz-utils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Add .NET global tools path
ENV PATH=$PATH:/home/vscode/.dotnet:/home/vscode/.dotnet/tools

# install wasm-tools workload
RUN dotnet workload update && \
    dotnet workload install wasm-tools

# aspire templates
#RUN dotnet new install Aspire.ProjectTemplates
# avalonia templates
RUN dotnet new install Avalonia.Templates
# Aspire CLI install disabled for now (script can be flaky in CI environments)
# To re-enable later, prefer a pinned versioned install method.
# RUN curl -fsSL -o /tmp/aspire-install.sh https://aspire.dev/install.sh && \
#     chmod +x /tmp/aspire-install.sh && \
#     bash /tmp/aspire-install.sh && \
#     rm /tmp/aspire-install.sh

# powershell core
RUN apt-get update -y && \
    apt-get install -y -q --no-install-recommends wget gpg && \
    wget -q https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb && \
    dpkg -i /tmp/packages-microsoft-prod.deb && \
    apt-get update -y && \
    apt-get install -y -q --no-install-recommends powershell && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/packages-microsoft-prod.deb && \
    pwsh -v

# nerd fonts
#RUN & ([scriptblock]::Create((iwr 'https://to.loredo.me/Install-NerdFont.ps1'))) -Confirm:$false -Name hack, heavy-data

# Install Node.js via NodeSource (stable and simpler in CI)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y -q --no-install-recommends nodejs && \
    node --version && npm --version && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

### We don't need to install Node.js and npm separately since we're using nvm
# # node / npm
# RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
#     apt-get install -y -q nodejs \
#     build-essential && \
#     node --version && \ 
#     npm --version

# install Bun (single, official method) and expose globally
RUN curl -fsSL https://bun.sh/install | bash && \
    ln -sf /root/.bun/bin/bun /usr/local/bin/bun && \
    bun --version

# gcloud CLI (non-interactive install)
ENV CLOUDSDK_CORE_DISABLE_PROMPTS=1
RUN curl -fsSL https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz -o /tmp/google-cloud-sdk.tar.gz
# Installing the package
RUN mkdir -p /usr/local/gcloud \
    && tar -C /usr/local/gcloud -xzf /tmp/google-cloud-sdk.tar.gz \
    && /usr/local/gcloud/google-cloud-sdk/install.sh --quiet \
    && ln -sf /usr/local/gcloud/google-cloud-sdk/bin/gcloud /usr/local/bin/gcloud
ENV PATH="/usr/local/gcloud/google-cloud-sdk/bin:$PATH"
#RUN gcloud components update
# beta components
RUN /usr/local/gcloud/google-cloud-sdk/bin/gcloud components install beta --quiet && \
    gcloud components list --quiet | grep -i "beta" || true

# install firebase CLI
RUN npm install -g firebase-tools@14.6.0

# GitHub CLI
RUN mkdir -p -m 755 /etc/apt/keyrings \
    && out=$(mktemp) && curl -fsSL -o "$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && cat "$out" | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg\
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install gh -y -q --no-install-recommends \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# terraform
RUN set -eux; \
    curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg; \
    . /etc/os-release; CODENAME=${UBUNTU_CODENAME:-$VERSION_CODENAME}; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com ${CODENAME} main" > /etc/apt/sources.list.d/hashicorp.list; \
    apt-get update; \
    apt-get install -y -q --no-install-recommends terraform; \
    apt-get clean; rm -rf /var/lib/apt/lists/*

# terraform CDK for C#
RUN npm install --global cdktf-cli@0.21.0

# Ansible
RUN apt-get update -y && \
    apt-get install -y -q --no-install-recommends \
    ansible \
    sshpass \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    ansible --version

# Ansible extras: ansible-lint (via pip) and community.general collection + bash completions
RUN apt-get update -y && apt-get install -y -q --no-install-recommends python3-pip bash-completion && \
    pip3 install --no-cache-dir ansible-lint && \
    ansible-galaxy collection install community.general && \
    mkdir -p /etc/ansible && \
    echo 'collections_paths = ~/.ansible/collections:/usr/share/ansible/collections' > /etc/ansible/ansible.cfg && \
    ansible-lint --version && \
    # Generate bash completion scripts
    if command -v ansible >/dev/null 2>&1; then ansible-config dump --only-changed >/dev/null 2>&1 || true; fi && \
    if command -v ansible >/dev/null 2>&1; then ansible localhost -m debug -a 'msg=completion-priming' >/dev/null 2>&1 || true; fi && \
    # Add dynamic completion loader lines
    printf '\n# Ansible & ansible-lint completion\n' >> /etc/bash.bashrc && \
    printf 'if [ -f /usr/share/bash-completion/bash_completion ]; then\n  . /usr/share/bash-completion/bash_completion\nfi\n' >> /etc/bash.bashrc && \
    printf 'if command -v register-python-argcomplete >/dev/null 2>&1; then eval "$(register-python-argcomplete ansible)"; fi\n' >> /etc/bash.bashrc && \
    printf 'if command -v register-python-argcomplete >/dev/null 2>&1; then eval "$(register-python-argcomplete ansible-galaxy)"; fi\n' >> /etc/bash.bashrc && \
    printf 'if command -v register-python-argcomplete >/dev/null 2>&1; then eval "$(register-python-argcomplete ansible-lint)"; fi\n' >> /etc/bash.bashrc && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# install uv
RUN curl -fsSL -o /uv-installer.sh https://astral.sh/uv/0.8.17/install.sh && \
    sh /uv-installer.sh && rm /uv-installer.sh
ENV PATH="/root/.local/bin/:$PATH"

# LLM agents?
# gemini CLI
# augment
# claude 
# opencode

# check CLI commands working
RUN npm --version && \
    node --version && \
    gh --version && \
    gcloud --version && \
    firebase --version && \
    terraform --version && \
    cdktf --version \
    && ansible --version \
    && uv --version

# Return to non-root user for devcontainer usage
USER vscode
