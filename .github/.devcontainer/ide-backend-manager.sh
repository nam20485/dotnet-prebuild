#!/bin/bash
# Helper script to manage IDE backends in the devcontainer

set -e

SCRIPT_NAME=$(basename "$0")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  IDE Backend Manager${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

check_ssh() {
    if sudo service ssh status > /dev/null 2>&1; then
        print_success "SSH server is running on port 2222"
        return 0
    else
        print_error "SSH server is not running"
        return 1
    fi
}

start_ssh() {
    print_info "Starting SSH server..."
    sudo service ssh start
    if check_ssh; then
        print_success "SSH server started successfully"
        print_info "Connect using: ssh -p 2222 vscode@localhost"
    else
        print_error "Failed to start SSH server"
        exit 1
    fi
}

stop_ssh() {
    print_info "Stopping SSH server..."
    sudo service ssh stop
    print_success "SSH server stopped"
}

check_code_server() {
    if pgrep -f "code-server" > /dev/null; then
        print_success "code-server is running on port 8080"
        return 0
    else
        print_error "code-server is not running"
        return 1
    fi
}

start_code_server() {
    if check_code_server; then
        print_info "code-server is already running"
        return 0
    fi
    
    print_info "Starting code-server..."
    print_info "Access it at: http://localhost:8080"
    code-server --bind-addr 0.0.0.0:8080 &
    sleep 2
    
    if check_code_server; then
        print_success "code-server started successfully"
    else
        print_error "Failed to start code-server"
        exit 1
    fi
}

stop_code_server() {
    print_info "Stopping code-server..."
    pkill -f "code-server" || true
    print_success "code-server stopped"
}

check_jetbrains() {
    if [ -d "/opt/ide-backends/rider" ]; then
        print_success "JetBrains Rider backend is installed at /opt/ide-backends/rider"
        return 0
    else
        print_error "JetBrains Rider backend is not installed"
        return 1
    fi
}

check_vscode_server() {
    if command -v code > /dev/null 2>&1; then
        print_success "VS Code Server CLI is installed"
        return 0
    else
        print_error "VS Code Server CLI is not installed"
        return 1
    fi
}

check_vscode_tunnel() {
    if pgrep -f "code tunnel" > /dev/null; then
        print_success "VS Code tunnel is running"
        return 0
    else
        print_error "VS Code tunnel is not running"
        return 1
    fi
}

start_vscode_tunnel() {
    if check_vscode_tunnel; then
        print_info "VS Code tunnel is already running"
        return 0
    fi
    
    print_info "Starting VS Code tunnel..."
    print_info "You may need to authenticate via browser on first run"
    print_info "Use: code tunnel --accept-server-license-terms"
    nohup code tunnel --accept-server-license-terms > /tmp/vscode-tunnel.log 2>&1 &
    sleep 3
    
    if check_vscode_tunnel; then
        print_success "VS Code tunnel started successfully"
        print_info "Check connection details in /tmp/vscode-tunnel.log"
    else
        print_error "Failed to start VS Code tunnel"
        print_info "Try running manually: code tunnel --accept-server-license-terms"
        exit 1
    fi
}

stop_vscode_tunnel() {
    print_info "Stopping VS Code tunnel..."
    pkill -f "code tunnel" || true
    print_success "VS Code tunnel stopped"
}

status_all() {
    print_header
    echo "Checking IDE backend status..."
    echo ""
    
    echo "SSH Server:"
    check_ssh || true
    echo ""
    
    echo "Code-Server (VS Code in Browser):"
    check_code_server || true
    echo ""
    
    echo "VS Code Server (Remote-SSH):"
    check_vscode_server || true
    echo ""
    
    echo "VS Code Tunnel:"
    check_vscode_tunnel || true
    echo ""
    
    echo "JetBrains Rider Backend:"
    check_jetbrains || true
    echo ""
    
    echo -e "${BLUE}Port Forwarding:${NC}"
    echo "  - SSH: localhost:2222"
    echo "  - code-server: http://localhost:8080"
    echo "  - VS Code tunnel: Check /tmp/vscode-tunnel.log for connection URL"
    echo ""
}

start_all() {
    print_header
    print_info "Starting all IDE backends..."
    echo ""
    
    start_ssh
    echo ""
    
    start_code_server
    echo ""
    
    start_vscode_tunnel
    echo ""
    
    print_success "All IDE backends started!"
    echo ""
    print_info "Access methods:"
    echo "  - SSH: ssh -p 2222 vscode@localhost"
    echo "  - code-server (browser): http://localhost:8080"
    echo "  - VS Code Remote-SSH: Configure Remote-SSH to vscode@localhost:2222"
    echo "  - VS Code Tunnel: Check /tmp/vscode-tunnel.log for connection URL"
    echo "  - JetBrains Gateway: Configure SSH to vscode@localhost:2222"
}

stop_all() {
    print_header
    print_info "Stopping all IDE backends..."
    echo ""
    
    stop_ssh
    echo ""
    
    stop_code_server
    echo ""
    
    stop_vscode_tunnel
    echo ""
    
    print_success "All IDE backends stopped!"
}

show_help() {
    print_header
    cat << EOF
Usage: $SCRIPT_NAME [COMMAND]

Commands:
  status          Show status of all IDE backends
  start           Start all IDE backends
  stop            Stop all IDE backends
  start-ssh       Start SSH server only
  stop-ssh        Stop SSH server only
  start-code      Start code-server only
  stop-code       Stop code-server only
  start-tunnel    Start VS Code tunnel only
  stop-tunnel     Stop VS Code tunnel only
  check-jetbrains Check JetBrains Rider backend installation
  check-vscode    Check VS Code Server CLI installation
  check-tunnel    Check VS Code tunnel status
  help            Show this help message

Examples:
  $SCRIPT_NAME status              # Check status of all backends
  $SCRIPT_NAME start               # Start all backends
  $SCRIPT_NAME start-code          # Start only code-server

EOF
}

# Main script logic
case "${1:-status}" in
    status)
        status_all
        ;;
    start)
        start_all
        ;;
    stop)
        stop_all
        ;;
    start-ssh)
        start_ssh
        ;;
    stop-ssh)
        stop_ssh
        ;;
    start-code)
        start_code_server
        ;;
    stop-code)
        stop_code_server
        ;;
    start-tunnel)
        start_vscode_tunnel
        ;;
    stop-tunnel)
        stop_vscode_tunnel
        ;;
    check-jetbrains)
        check_jetbrains
        ;;
    check-vscode)
        check_vscode_server
        ;;
    check-tunnel)
        check_vscode_tunnel
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
