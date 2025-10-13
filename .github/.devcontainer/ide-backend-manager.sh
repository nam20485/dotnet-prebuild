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
    if [ -d "/opt/ide-backends/idea" ]; then
        print_success "JetBrains IDEA backend is installed at /opt/ide-backends/idea"
        return 0
    else
        print_error "JetBrains IDEA backend is not installed"
        return 1
    fi
}

status_all() {
    print_header
    echo "Checking IDE backend status..."
    echo ""
    
    echo "SSH Server:"
    check_ssh || true
    echo ""
    
    echo "Code-Server:"
    check_code_server || true
    echo ""
    
    echo "JetBrains IDEA Backend:"
    check_jetbrains || true
    echo ""
    
    echo -e "${BLUE}Port Forwarding:${NC}"
    echo "  - SSH: localhost:2222"
    echo "  - code-server: http://localhost:8080"
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
    
    print_success "All IDE backends started!"
    echo ""
    print_info "Access methods:"
    echo "  - SSH: ssh -p 2222 vscode@localhost"
    echo "  - code-server: http://localhost:8080"
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
  check-jetbrains Check JetBrains backend installation
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
    check-jetbrains)
        check_jetbrains
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
