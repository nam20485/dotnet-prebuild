## GPG Setup - Quick Start (Option 1: Copy Keys)

### ✅ Works On: Windows, macOS, Linux, WSL2

### Before Rebuilding Container

**On your host machine, run:**

**Windows (PowerShell):**
```powershell
# Verify your GPG key exists
gpg --list-secret-keys

# Check GPG directory
dir $env:USERPROFILE\.gnupg
```

**Linux/macOS/WSL:**
```bash
# 1. Verify your GPG key exists
gpg --list-secret-keys

# 2. Check GPG directory
ls -la ~/.gnupg
```

### Rebuild DevContainer

1. Press `Ctrl+Shift+P`
2. Type: **"Dev Containers: Rebuild Container"**
3. Wait for rebuild to complete

### After Container Starts

**Keys should be automatically copied!** Verify:

```bash
# Set GPG_TTY (important!)
export GPG_TTY=$(tty)

# Check if keys were copied
gpg --list-keys
gpg --list-secret-keys

# Test signing
echo "test" | gpg --clearsign
```

### If It Works

Configure Git (if not already):
```bash
git config --global user.signingkey 4B4DC9F934E7686957BDA07417CB1E1DE824343F
git config --global commit.gpgsign true
```

Test commit signing:
```bash
git commit --allow-empty -m "Test signed commit"
```

### If It Doesn't Work

Manually copy keys:
```bash
cp -r ~/.gnupg-host/* ~/.gnupg/
chmod 700 ~/.gnupg
chmod 600 ~/.gnupg/*
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent
```

Or see: `.devcontainer/GPG-SETUP-OPTION1.md` for full troubleshooting guide.

### Common Issues

**"No secret key"** → Keys weren't copied
- Fix: Manually copy with commands above

**"Inappropriate ioctl"** → GPG_TTY not set
- Fix: Run `export GPG_TTY=$(tty)` and add to ~/.bashrc

**Mount not found** → Host path wrong
- Fix: Check `~/.gnupg` exists on host, rebuild container

**Permission denied** → Wrong permissions
- Fix: Run `chmod 700 ~/.gnupg && chmod 600 ~/.gnupg/*`

### Security Note

⚠️ **Option 1 copies private keys into the container**
- Keys accessible while container exists
- Deleted when container is removed
- Use only in trusted containers
- Consider creating a separate "dev" GPG key

See full guide: `.devcontainer/GPG-SETUP-OPTION1.md`
