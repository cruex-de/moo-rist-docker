#!/bin/bash

# ============================================
# RIST Manager - Simple Version for Linux
# ============================================

# ---------------------------
# Color Definitions (Optional)
# ---------------------------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ---------------------------
# Variables
# ---------------------------
PORT=2030
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
EXE_PATH="$SCRIPT_DIR/out_linux/moo-rist-selfhosting"

# ---------------------------
# Function: Check for Admin Privileges
# ---------------------------
check_admin() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}This script requires administrative privileges.${NC}"
        echo "Please run the script as root or with sudo."
        read -n1 -r -p "Press any key to exit..." key
        exit 1
    fi
}

# ---------------------------
# Function: Display Menu
# ---------------------------
show_menu() {
    clear
    echo -e "${GREEN}============================================${NC}"
    echo -e "${GREEN}         RIST Self-Hosting Manager         ${NC}"
    echo -e "${GREEN}============================================${NC}"
    echo
    echo -e "${YELLOW}1. Open Port $PORT for RIST Self-Hosting${NC}"
    echo -e "${YELLOW}2. Run moo-rist-selfhosting${NC}"
    echo -e "${YELLOW}3. Exit${NC}"
    echo
}

# ---------------------------
# Function: Open Port
# ---------------------------
open_port() {
    clear
    echo -e "${GREEN}Opening port $PORT for RIST Self-Hosting...${NC}"
    echo

    # Check if UFW is installed; install if not
    if ! command -v ufw &> /dev/null; then
        echo "ufw (Uncomplicated Firewall) is not installed. Installing..."
        apt update && apt install -y ufw
        if [ $? -ne 0 ]; then
            echo -e "${RED}Failed to install ufw. Please install it manually.${NC}"
            read -n1 -r -p "Press any key to continue..." key
            return
        fi
    fi

    # Enable UFW if not already enabled
    ufw status | grep -qw active
    if [ $? -ne 0 ]; then
        echo "ufw is not enabled. Enabling ufw..."
        ufw --force enable
        if [ $? -ne 0 ]; then
            echo -e "${RED}Failed to enable ufw. Please check your settings.${NC}"
            read -n1 -r -p "Press any key to continue..." key
            return
        fi
    fi

    # Check if the port is already allowed
    ufw status | grep -qw "$PORT/udp"
    if [ $? -eq 0 ]; then
        echo "Port $PORT is already open."
    else
        ufw allow "$PORT"/udp
        if [ $? -eq 0 ]; then
            echo "Successfully opened port $PORT."
        else
            echo -e "${RED}Failed to open port $PORT. Please check your settings.${NC}"
        fi
    fi

    echo
    read -n1 -r -p "Press any key to return to the menu..." key
}

# ---------------------------
# Function: Run Executable
# ---------------------------
run_executable() {
    clear
    echo -e "${GREEN}Running moo-rist-selfhosting...${NC}"
    echo

    if [ -f "$EXE_PATH" ]; then
        # Ensure the executable has execute permissions
        chmod +x "$EXE_PATH"
		chmod +x "$SCRIPT_DIR/out_linux/librist/tools/ristreceiver"

        # Run the executable in the background
        "$EXE_PATH" &
        echo "Executable launched successfully."
    else
        echo -e "${RED}Error: The file '$EXE_PATH' does not exist.${NC}"
    fi

    echo
    read -n1 -r -p "Press any key to return to the menu..." key
}

# ---------------------------
# Function: Exit Script
# ---------------------------
exit_script() {
    clear
    echo -e "${GREEN}Exiting RIST Manager. Goodbye!${NC}"
    echo
    read -n1 -r -p "Press any key to exit..." key
    exit 0
}

# ---------------------------
# Main Script Execution
# ---------------------------

# Check for administrative privileges
check_admin

# Main loop
while true; do
    show_menu
    read -p "Enter your choice [1-3]: " choice

    case "$choice" in
        1)
            open_port
            ;;
        2)
            run_executable
            ;;
        3)
            exit_script
            ;;
        *)
            echo -e "${RED}Invalid choice. Please try again.${NC}"
            read -n1 -r -p "Press any key to continue..." key
            ;;
    esac
done
