FROM mcr.microsoft.com/devcontainers/dotnet:1.3.7-9.0-bookworm-slim

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y -q --no-install-recommends \
        build-essential \
        apt-transport-https \
        ca-certificates \
        gnupg \ 
        curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN dotnet workload install wasm-tools
RUN dotnet workload update

#RUN apt-get install -y -q --no-install-recommends python3

#RUN & ([scriptblock]::Create((iwr 'https://to.loredo.me/Install-NerdFont.ps1'))) -Confirm:$false -Name hack, heavy-data

# node / npm
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs \
    build-essential && \
    node --version && \ 
    npm --version

# Add Google Cloud SDK repository
# Install Google Cloud CLI
# RUN bash -c 'echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list' && \
#     curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
#     apt-get update -y && \
#     apt-get install -y -q --no-install-recommends \
#         google-cloud-cli \ 
#         google-cloud-cli-enterprise-certificate-proxy google-cloud-cli-app-engine-java google-cloud-cli-bigtable-emulator google-cloud-cli-app-engine-python-extras google-cloud-cli-cbt google-cloud-cli-minikube google-cloud-cli-anthos-auth google-cloud-cli-datastore-emulator google-cloud-cli-app-engine-go kubectl google-cloud-cli google-cloud-cli-skaffold google-cloud-cli-nomos google-cloud-cli-pubsub-emulator google-cloud-cli-local-extract google-cloud-cli-spanner-migration-tool google-cloud-cli-docker-credential-gcr google-cloud-cli-config-connector google-cloud-cli-spanner-emulator google-cloud-cli-package-go-module google-cloud-cli-gke-gcloud-auth-plugin google-cloud-cli-app-engine-grpc google-cloud-cli-firestore-emulator google-cloud-cli-cloud-run-proxy google-cloud-cli-kubectl-oidc google-cloud-cli-istioctl google-cloud-cli-app-engine-python google-cloud-cli-cloud-build-local google-cloud-cli-kpt google-cloud-cli-anthoscli google-cloud-cli-terraform-tools google-cloud-cli-log-streaming google-cloud-cli-managed-flink-client

# gcloud CLI
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz
# Installing the package
RUN mkdir -p /usr/local/gcloud \
  && tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz \
  && /usr/local/gcloud/google-cloud-sdk/install.sh
ENV PATH=$PATH:/usr/local/gcloud/google-cloud-sdk/bin
#RUN gcloud components update

# install firebase CLI
RUN npm install -g firebase-tools@latest

RUN mkdir -p -m 755 /etc/apt/keyrings \
    && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y

# check CLI commands working
RUN npm --version && \
    node --version && \
    gh --version && \
    gcloud --version && \
    firebase --version
