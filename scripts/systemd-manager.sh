#!/bin/bash
# =============================================================================
# Systemd User Service Manager
# =============================================================================
# Interactive tool to manage systemd user services
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

function print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

function print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

function print_error() {
    echo -e "${RED}❌ $1${NC}"
}

function print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

function list_services() {
    print_header "User Services"
    echo "Active services:"
    systemctl --user list-units --type=service --state=active --no-pager
    echo ""
    echo "All services:"
    systemctl --user list-units --type=service --all --no-pager
}

function list_timers() {
    print_header "User Timers"
    systemctl --user list-timers --all --no-pager
}

function service_status() {
    echo "Enter service name (without .service):"
    read -r SERVICE_NAME
    echo ""
    systemctl --user status "${SERVICE_NAME}.service"
}

function start_service() {
    echo "Enter service name to start (without .service):"
    read -r SERVICE_NAME
    systemctl --user start "${SERVICE_NAME}.service"
    print_success "Started ${SERVICE_NAME}.service"
    systemctl --user status "${SERVICE_NAME}.service" --no-pager
}

function stop_service() {
    echo "Enter service name to stop (without .service):"
    read -r SERVICE_NAME
    systemctl --user stop "${SERVICE_NAME}.service"
    print_success "Stopped ${SERVICE_NAME}.service"
}

function restart_service() {
    echo "Enter service name to restart (without .service):"
    read -r SERVICE_NAME
    systemctl --user restart "${SERVICE_NAME}.service"
    print_success "Restarted ${SERVICE_NAME}.service"
    systemctl --user status "${SERVICE_NAME}.service" --no-pager
}

function enable_service() {
    echo "Enter service name to enable on boot (without .service):"
    read -r SERVICE_NAME
    systemctl --user enable "${SERVICE_NAME}.service"
    print_success "Enabled ${SERVICE_NAME}.service"
}

function disable_service() {
    echo "Enter service name to disable on boot (without .service):"
    read -r SERVICE_NAME
    systemctl --user disable "${SERVICE_NAME}.service"
    print_success "Disabled ${SERVICE_NAME}.service"
}

function view_logs() {
    echo "Enter service name to view logs (without .service):"
    read -r SERVICE_NAME
    echo "Last 50 lines:"
    journalctl --user -u "${SERVICE_NAME}.service" -n 50 --no-pager
    echo ""
    echo "Press 'f' to follow logs in real-time, or any other key to return"
    read -n 1 -r
    if [[ $REPLY == "f" || $REPLY == "F" ]]; then
        journalctl --user -u "${SERVICE_NAME}.service" -f
    fi
}

function reload_daemon() {
    systemctl --user daemon-reload
    print_success "Systemd user daemon reloaded"
}

function check_lingering() {
    print_header "Lingering Status"
    if loginctl show-user "$USER" | grep -q "Linger=yes"; then
        print_success "Lingering is ENABLED - user services will run when not logged in"
    else
        print_warning "Lingering is DISABLED - user services only run when logged in"
        echo ""
        echo "Enable lingering with: loginctl enable-linger $USER"
    fi
}

function enable_lingering() {
    loginctl enable-linger "$USER"
    print_success "Lingering enabled - user services will run even when not logged in"
}

function show_failed() {
    print_header "Failed Services"
    systemctl --user list-units --type=service --state=failed --no-pager
}

function main_menu() {
    while true; do
        echo ""
        print_header "Systemd User Service Manager"
        echo "1)  List all services"
        echo "2)  List timers"
        echo "3)  Show service status"
        echo "4)  Start service"
        echo "5)  Stop service"
        echo "6)  Restart service"
        echo "7)  Enable service (start on boot)"
        echo "8)  Disable service"
        echo "9)  View service logs"
        echo "10) Show failed services"
        echo "11) Reload systemd daemon"
        echo "12) Check lingering status"
        echo "13) Enable lingering"
        echo "q)  Quit"
        echo ""
        read -p "Enter choice: " CHOICE

        case $CHOICE in
            1) list_services ;;
            2) list_timers ;;
            3) service_status ;;
            4) start_service ;;
            5) stop_service ;;
            6) restart_service ;;
            7) enable_service ;;
            8) disable_service ;;
            9) view_logs ;;
            10) show_failed ;;
            11) reload_daemon ;;
            12) check_lingering ;;
            13) enable_lingering ;;
            q|Q) echo "Goodbye!"; exit 0 ;;
            *) print_error "Invalid choice" ;;
        esac
    done
}

# If argument provided, run specific command
if [[ $# -gt 0 ]]; then
    case $1 in
        list) list_services ;;
        timers) list_timers ;;
        failed) show_failed ;;
        lingering) check_lingering ;;
        *) echo "Unknown command: $1"; exit 1 ;;
    esac
else
    main_menu
fi
