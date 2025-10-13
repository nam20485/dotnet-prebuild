- # GPG Agent Forwarding Setup for DevContainer

## Overview
This guide explains how to set up GPG agent forwarding so you can sign Git commits inside the devcontainer using your host machine's GPG keys.

## How It Works
- Your host machine's `~/.gnupg` directory is mounted into the container at `~/.gnupg-host`
- The GPG agent sockets from the host are symlinked into the container's `~/.gnupg` directory
- When you sign commits in the container, the signing operation is forwarded to your host's GPG agent
- Your private keys never enter the container - they stay secure on your host

## Prerequisites on Host Machine

### For Linux/WSL2:
1. Ensure GPG is installed and your key is set up:
   ```bash
   gpg --list-secret-keys
   ```

2. Ensure GPG agent is running:
   ```bash
   gpgconf --launch gpg-agent
   ```

3. Verify agent socket exists:
   ```bash
   ls -la ~/.gnupg/S.gpg-agent
   ```
   You should see a socket file (starts with 's' in permissions).

4. Configure Git on host (if not already done):
   ```bash
   git config --global user.signingkey YOUR_KEY_ID
   git config --global commit.gpgsign true
   ```

### For Windows (non-WSL):
GPG agent forwarding from Windows to WSL2 devcontainers is more complex and may require additional tools like npiperelay. Consider using Option 2 (Import Keys) instead.

## Setup Steps

### Step 1: Rebuild DevContainer
The `.devcontainer/devcontainer.json` has been updated with GPG forwarding configuration. You need to rebuild the container:

1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
2. Type "Dev Containers: Rebuild Container"
3. Select it and wait for the container to rebuild

### Step 2: Verify Setup
After the container rebuilds, the `postCreateCommand` will automatically run setup. Verify by running:

```bash
ls -la ~/.gnupg/
```

You should see symlinks for `S.gpg-agent` pointing to `~/.gnupg-host/S.gpg-agent`.

### Step 3: Test GPG Signing
Try to sign some test content:

```bash
export GPG_TTY=$(tty)
echo "test" | gpg --clearsign
```

If this works, test Git commit signing:

```bash
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgsign true
git commit --allow-empty -m "Test signed commit"
```

## Troubleshooting

### Issue: "gpg: signing failed: No secret key"
**Cause:** GPG agent on host is not running or sockets are not properly forwarded.

**Fix:**
1. On host, restart GPG agent:
   ```bash
   gpgconf --kill gpg-agent
   gpgconf --launch gpg-agent
   ```
2. Verify socket exists: `ls -la ~/.gnupg/S.gpg-agent`
3. Rebuild devcontainer

### Issue: "gpg: problem with fast path key listing: Forbidden"
**Cause:** This is a warning about restricted mode, but shouldn't prevent signing if sockets are properly forwarded.

**Fix:** Usually safe to ignore, but if signing fails, check socket permissions and agent status on host.

### Issue: Sockets not appearing in container
**Cause:** Mount path is incorrect or host directory doesn't exist.

**Fix:**
1. Check host path: `echo $HOME/.gnupg`
2. Verify mounts in devcontainer.json use correct syntax
3. For WSL2, ensure you're using the WSL home directory, not Windows

### Issue: "Input/output error" on socket
**Cause:** Host GPG agent stopped or socket became stale.

**Fix:**
1. Restart host GPG agent
2. Reconnect to devcontainer: "Dev Containers: Reopen in Container"

## Manual Setup (If Automatic Setup Fails)

If the automatic setup doesn't work, run the setup script manually:

```bash
bash /workspaces/dotnet-prebuild/.devcontainer/setup-gpg-forwarding.sh
```

Or set up manually:

```bash
# Link the agent socket
mkdir -p ~/.gnupg
chmod 700 ~/.gnupg
ln -sf ~/.gnupg-host/S.gpg-agent ~/.gnupg/S.gpg-agent

# Copy public keyring
cp ~/.gnupg-host/pubring.kbx ~/.gnupg/

# Set GPG_TTY
export GPG_TTY=$(tty)
echo 'export GPG_TTY=$(tty)' >> ~/.bashrc

# Test
gpg --list-keys
```

## Alternative: Import Keys Instead

If GPG agent forwarding proves too difficult, you can import your keys into the container instead:

**On host:**
```bash
gpg --export-secret-keys --armor YOUR_KEY_ID > ~/my-key.asc
```

**In container:**
```bash
gpg --import ~/my-key.asc
rm ~/my-key.asc  # Delete immediately after import
```

**Warning:** This stores your private key inside the container. Only do this if you trust the container environment.

## Security Considerations

### ✅ Pros of Agent Forwarding:
- Private keys never enter the container
- Keys remain protected by host's security
- Passphrase prompts handled by host
- Easy to revoke access (just stop container)

### ⚠️ Considerations:
- Anyone with access to the container can use your GPG key while container is running
- Socket forwarding creates a trust boundary
- Container processes can sign anything while connected

### 🔒 Best Practices:
1. Only forward GPG agent to containers you trust
2. Use short-lived containers when possible
3. Stop/remove containers when not in use
4. Consider using separate keys for container development
5. Monitor GPG agent activity on host

## References
- [GnuPG Agent Documentation](https://www.gnupg.org/documentation/manuals/gnupg/Invoking-GPG_002dAGENT.html)
- [Git Commit Signing](https://git-scm.com/book/en/v2/Git-Tools-Signing-Your-Work)
- [Dev Containers Documentation](https://containers.dev/)
