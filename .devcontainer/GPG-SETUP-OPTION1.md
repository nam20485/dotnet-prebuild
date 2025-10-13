# GPG Setup - Option 1: Copy Keys (Simple & Cross-Platform)

## Overview
This approach copies your GPG keys from the host into the devcontainer. It's the **simplest option** and works on:
- ✅ Windows (native)
- ✅ WSL2
- ✅ Linux
- ✅ macOS

## How It Works
1. Your host `~/.gnupg` directory is mounted read-only at `~/.gnupg-host`
2. During container creation, all keys are copied to the container's `~/.gnupg`
3. The container has its own GPG agent that can sign commits
4. Keys persist as long as the container exists

## Prerequisites on Host Machine

### Windows (GPG4Win):
1. Install GPG4Win: https://gpg4win.org/
2. Generate or import your GPG key using Kleopatra (comes with GPG4Win)
3. Verify in PowerShell:
   ```powershell
   gpg --list-secret-keys
   ```

### WSL2/Linux:
```bash
# Verify GPG and keys
gpg --list-secret-keys
```

### macOS:
```bash
# Install GPG via Homebrew if needed
brew install gnupg

# Verify keys
gpg --list-secret-keys
```

## Setup Steps

### Step 1: Verify Your GPG Keys Exist on Host

**Windows PowerShell:**
```powershell
gpg --list-secret-keys
# Should show your key with "sec" (secret key)
```

**Linux/macOS/WSL:**
```bash
gpg --list-secret-keys
# Should show your key with "sec" (secret key)
```

### Step 2: Check GPG Directory Location

**Windows:**
```powershell
echo $env:USERPROFILE\.gnupg
# Usually: C:\Users\YourName\.gnupg
dir $env:USERPROFILE\.gnupg
```

**Linux/macOS/WSL:**
```bash
echo ~/.gnupg
ls -la ~/.gnupg
```

### Step 3: Rebuild DevContainer

1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
2. Type: **"Dev Containers: Rebuild Container"**
3. Select it and wait for rebuild

The `postCreateCommand` will automatically copy your keys!

### Step 4: Verify Keys in Container

After container starts:

```bash
# Set GPG_TTY (add to ~/.bashrc for persistence)
export GPG_TTY=$(tty)

# Check keys were copied
gpg --list-keys
gpg --list-secret-keys

# Test signing
echo "test" | gpg --clearsign
```

### Step 5: Configure Git

```bash
# Set your signing key (use your key ID from gpg --list-secret-keys)
git config --global user.signingkey YOUR_KEY_ID

# Enable commit signing
git config --global commit.gpgsign true

# Test
git commit --allow-empty -m "Test signed commit"
```

## Troubleshooting

### Issue: "No secret key" in container

**Cause:** Keys weren't copied, or mount failed.

**Fix:**
```bash
# Check if mount exists
ls -la ~/.gnupg-host

# If it exists, manually copy
cp -r ~/.gnupg-host/* ~/.gnupg/
chmod 700 ~/.gnupg
chmod 600 ~/.gnupg/*
chmod 700 ~/.gnupg/private-keys-v1.d

# Restart GPG agent
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent
```

### Issue: "gpg: signing failed: Inappropriate ioctl for device"

**Cause:** GPG_TTY not set.

**Fix:**
```bash
export GPG_TTY=$(tty)
echo 'export GPG_TTY=$(tty)' >> ~/.bashrc
```

### Issue: Passphrase prompt not appearing

**Cause:** Pinentry not configured properly.

**Fix:**
```bash
# Configure loopback pinentry for non-interactive environments
cat > ~/.gnupg/gpg-agent.conf << 'EOF'
default-cache-ttl 600
max-cache-ttl 7200
allow-loopback-pinentry
EOF

# Restart agent
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent

# Test with loopback
echo "test" | gpg --pinentry-mode loopback --clearsign
```

### Issue: Keys not found on Windows

**Cause:** Wrong path or GPG not installed.

**Fix:**
1. Verify GPG installation: `gpg --version`
2. Check path: `echo $env:USERPROFILE\.gnupg`
3. Install GPG4Win if needed
4. Restart VS Code after installation

### Issue: Permission denied errors

**Cause:** Wrong permissions on GPG directory.

**Fix:**
```bash
chmod 700 ~/.gnupg
chmod 600 ~/.gnupg/*
chmod 700 ~/.gnupg/private-keys-v1.d
```

## Security Considerations

### ⚠️ Important:
- Your private keys ARE stored in the container
- Anyone with container access can use your keys
- Keys are deleted when container is removed
- Keys persist in container volume until explicitly removed

### 🔒 Best Practices:
1. Only use in containers you trust
2. Use a separate key for development if concerned
3. Remove old containers when done: `docker container prune`
4. Don't commit the container to an image with keys inside
5. Consider using a dedicated "development" GPG key

### 🎯 When to Use This:
- ✅ Personal development containers
- ✅ Short-lived containers
- ✅ When you need simple setup
- ✅ Cross-platform compatibility needed
- ❌ Shared containers
- ❌ Production environments
- ❌ Untrusted base images

## Pros and Cons

### ✅ Pros:
- Simple setup - just rebuild container
- Works on all platforms (Windows, Mac, Linux)
- No special tools needed
- GPG agent runs locally in container
- No socket forwarding complexity

### ⚠️ Cons:
- Private keys are copied into container
- Keys accessible to anyone with container access
- Need to rebuild/recreate when keys change
- Less secure than agent forwarding
- Keys persist in container until removed

## Comparison with Other Options

| Feature | Option 1 (Copy) | Option 4 (Forward) |
|---------|----------------|-------------------|
| Windows Support | ✅ Yes | ❌ Complex |
| Setup Complexity | ⭐ Simple | ⭐⭐⭐ Complex |
| Security | ⭐⭐ Medium | ⭐⭐⭐ High |
| Cross-platform | ✅ Yes | ❌ Linux/WSL only |
| Key Location | In container | On host only |

## Alternative: Create New Key in Container

If you prefer not to copy your main key:

```bash
# Generate new key in container
gpg --full-generate-key

# Follow prompts, then get the key ID
gpg --list-secret-keys

# Configure git
git config --global user.signingkey NEW_KEY_ID
git config --global commit.gpgsign true

# Export public key to add to GitHub
gpg --armor --export NEW_KEY_ID
```

Then add the public key to GitHub: https://github.com/settings/keys

## Getting Help

If you encounter issues:

1. Check this guide's troubleshooting section
2. Run: `gpg --version` and `gpg --list-secret-keys`
3. Check container logs
4. Verify host GPG directory exists and has keys
5. Try manual copy steps from troubleshooting

## Next Steps After Setup

1. ✅ Verify signing works: `echo "test" | gpg --clearsign`
2. ✅ Test git commit: `git commit --allow-empty -m "Test"`
3. ✅ Push to GitHub and verify signature shows
4. ✅ Add to ~/.bashrc: `export GPG_TTY=$(tty)`
5. ✅ Consider creating a container-specific key if needed
