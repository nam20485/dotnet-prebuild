#!/bin/bash
set -e

echo "Setting up GPG agent forwarding..."

# Ensure GPG directory exists with correct permissions
mkdir -p ~/.gnupg
chmod 700 ~/.gnupg

# Check if host GPG directory is mounted
if [ -d ~/.gnupg-host ]; then
    echo "✓ Host GPG directory mounted at ~/.gnupg-host"
    
    # Copy public keyring if it exists
    if [ -f ~/.gnupg-host/pubring.kbx ]; then
        cp -n ~/.gnupg-host/pubring.kbx ~/.gnupg/ 2>/dev/null || true
        chmod 644 ~/.gnupg/pubring.kbx
        echo "✓ Copied public keyring"
    fi
    
    # Copy trustdb if it exists
    if [ -f ~/.gnupg-host/trustdb.gpg ]; then
        cp -n ~/.gnupg-host/trustdb.gpg ~/.gnupg/ 2>/dev/null || true
        chmod 644 ~/.gnupg/trustdb.gpg
        echo "✓ Copied trust database"
    fi
    
    # Link GPG agent sockets
    if [ -S ~/.gnupg-host/S.gpg-agent ]; then
        rm -f ~/.gnupg/S.gpg-agent
        ln -sf ~/.gnupg-host/S.gpg-agent ~/.gnupg/S.gpg-agent
        echo "✓ Linked GPG agent socket"
    else
        echo "⚠ Warning: GPG agent socket not found on host"
        echo "  Make sure GPG agent is running on your host machine"
    fi
    
    # Link GPG agent SSH socket if it exists
    if [ -S ~/.gnupg-host/S.gpg-agent.ssh ]; then
        rm -f ~/.gnupg/S.gpg-agent.ssh
        ln -sf ~/.gnupg-host/S.gpg-agent.ssh ~/.gnupg/S.gpg-agent.ssh
        echo "✓ Linked GPG agent SSH socket"
    fi
    
    # Link GPG agent extra socket if it exists
    if [ -S ~/.gnupg-host/S.gpg-agent.extra ]; then
        rm -f ~/.gnupg/S.gpg-agent.extra
        ln -sf ~/.gnupg-host/S.gpg-agent.extra ~/.gnupg/S.gpg-agent.extra
        echo "✓ Linked GPG agent extra socket"
    fi
else
    echo "✗ Host GPG directory not mounted"
    echo "  The devcontainer needs to be rebuilt for changes to take effect"
    exit 1
fi

# Set GPG_TTY environment variable
export GPG_TTY=$(tty)
echo "export GPG_TTY=\$(tty)" >> ~/.bashrc

# Create GPG agent configuration to use the forwarded socket
cat > ~/.gnupg/gpg-agent.conf << 'EOF'
# Use extra socket for remote connections
extra-socket /home/vscode/.gnupg/S.gpg-agent.extra

# Disable local agent spawning since we're using forwarded socket
# Keep cache settings for convenience
default-cache-ttl 600
max-cache-ttl 7200
EOF

chmod 600 ~/.gnupg/gpg-agent.conf
echo "✓ Created GPG agent configuration"

# Test GPG setup
echo ""
echo "Testing GPG setup..."
if gpg --list-keys > /dev/null 2>&1; then
    echo "✓ GPG can list public keys"
    gpg --list-keys
else
    echo "✗ Failed to list GPG keys"
fi

echo ""
echo "Checking for secret keys..."
if timeout 3 gpg --list-secret-keys > /dev/null 2>&1; then
    echo "✓ GPG can access secret keys"
    gpg --list-secret-keys
else
    echo "⚠ Cannot access secret keys or operation timed out"
    echo "  This may indicate the GPG agent on the host is not running"
fi

echo ""
echo "GPG forwarding setup complete!"
echo ""
echo "Next steps on your HOST machine:"
echo "1. Ensure GPG agent is running: gpgconf --launch gpg-agent"
echo "2. Check agent socket exists: ls -la ~/.gnupg/S.gpg-agent"
echo "3. Rebuild the devcontainer for changes to take effect"
