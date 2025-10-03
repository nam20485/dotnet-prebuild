# dotnet-prebuild

Dev container image and automation for a full-stack .NET development environment.

## Image Overview
- **Base image**: `mcr.microsoft.com/devcontainers/dotnet:1.5.4-9.0-noble`
- **Operating system**: Ubuntu 24.04 (Noble)
- **Target architecture**: linux/amd64 (multi-platform ready)
- **Primary consumer**: `ghcr.io/nam20485/dotnet-prebuild:main-latest`

### Pinned toolchain
| Tool | Version | Install Source |
| --- | --- | --- |
| .NET SDK | 9.0 (from base image) | Microsoft Dev Container base |
| Node.js | 22.x | NodeSource APT repo |
| Firebase CLI | 14.6.0 | npm global package |
| CDK for Terraform (cdktf) | 0.21.0 | npm global package |
| Aspire CLI | 9.5.0 | `dotnet tool install` |
| Avalonia templates | 11.2.2 | `dotnet new install` |
| Bun | 1.1.38 | Official install script |
| uv | 0.5.11 | Astral install script |
| Google Cloud CLI / Terraform / gh / Ansible / PowerShell | Latest from upstream APT repos |

### Additional configuration highlights
- Installs the `wasm-tools` workload and Avalonia templates without running `dotnet workload update`, keeping builds deterministic against the base SDK.
- Combines npm installations into a single layer and cleans the npm cache to reduce image size.
- Adds shell completions for Ansible commands and configures a shared collections path.
- Leaves Docker-in-Docker, SSH, and Python tooling to devcontainer Features so they can evolve independently of the base image.

## Devcontainer configuration
- `devcontainer.json` consumes the published base image and layers the features:
  - `ghcr.io/devcontainers/features/python:1`
  - `ghcr.io/devcontainers/features/docker-in-docker:2`
  - `ghcr.io/devcontainers/features/sshd:1`
- VS Code extensions focus on .NET, infrastructure, GitHub Actions, and cloud tooling.
- Containers run as `root` by default for maximum flexibility during prebuilds.

### Local validation
Build the container locally with the Dev Containers CLI:

```pwsh
devcontainer build `
  --workspace-folder . `
  --config .github/.devcontainer/devcontainer.json `
  --image-name devcontainer-local:latest
```

## Automation

### `Publish Docker`
- Builds `.github/.devcontainer/Dockerfile` directly.
- Tags images as `main-latest` and `main-<run_number>` via `docker/metadata-action`.
- Pushes to GHCR with BuildKit cache outputs.
- Signs the pushed digest using Cosign keyless signatures.

### `Pre-build dev container image`
- Triggers after `Publish Docker` completes.
- Rebuilds the image with devcontainer Features using `devcontainers/ci` (with `push: never`).
- Manually pushes the resulting image to GHCR with tags:
  - `${branch}-latest`
  - `${branch}-${VERSION_PREFIX}.${run_number}`
- Performs a pull immediately after pushing so Docker records `RepoDigests`; those digests are then used for:
  1. SLSA build provenance attestation (`actions/attest-build-provenance`)
  2. Cosign signing of the exact image digest
- Frees disk space before running Trivy to avoid runner exhaustion and scans only HIGH/CRITICAL findings.
- Uploads the SARIF report to Code Scanning (requires `security-events: write`).

This sequencing keeps the build reproducible, produces verifiable artifacts, and avoids duplicate pushes from the `devcontainers/ci` post-job cleanup.

## Tags and versioning
- Permanent tags follow `main-<VERSION_PREFIX>.<run_number>` (example: `main-1.0.41`).
- Floating tags:
  - `main-latest` (latest successful prebuild for the branch)
  - `main-<run_number>` (raw Dockerfile build output)

`VERSION_PREFIX` is maintained in repository variables so you can bump major/minor versions without code changes.

## Contributing
- Update package versions by editing ARGs at the top of the Dockerfile.
- Regenerate the image locally with the Dev Containers CLI before pushing.
- Keep README in sync with tooling and workflow behaviour.

## Troubleshooting
- **Digest missing:** ensure the push step stays before attestation/signing. Docker only sets `RepoDigests` after an image exists in the registry.
- **Trivy out-of-disk:** the workflow prunes Docker images and removes large toolchains (dotnet/android/CodeQL) before scanning; keep that step intact when modifying the pipeline.
- **Feature updates:** when features change, rerun `devcontainer build` locally to confirm compatibility before committing.
