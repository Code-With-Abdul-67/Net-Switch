#!/bin/bash

# Colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
CYAN='\e[36m'
RESET='\e[0m'

# Ask for sudo once
if [ "$EUID" -ne 0 ]; then
  echo -e "${YELLOW}[!] This script requires sudo privileges.${RESET}"
  sudo -v || { echo -e "${RED}Sudo authentication failed. Exiting.${RESET}"; exit 1; }
fi

# Display ASCII Logo (Yellow)
echo -e "${YELLOW}

  __   __      _____    _______      ______    _      _     __     _______     _____    __   __   
 /_/\ /\_\   /\_____\ /\_______)\   / ____/\  /_/\  /\_\   /\_\  /\_______)\  /\ __/\  /\_\ /_/\  
 ) ) \ ( (  ( (_____/ \(___  __\/   ) ) __\/  ) ) )( ( (   \/_/  \(___  __\/  ) )__\/ ( ( (_) ) ) 
/_/   \ \_\  \ \__\     / / /        \ \ \   /_/ //\\ \_\   /\_\   / / /     / / /     \ \___/ /  
\ \ \   / /  / /__/_   ( ( (         _\ \ \  \ \ /  \ / /  / / /  ( ( (      \ \ \_    / / _ \ \  
 )_) \ (_(  ( (_____\   \ \ \       )____) )  )_) /\ (_(  ( (_(    \ \ \      ) )__/\ ( (_( )_) ) 
 \_\/ \/_/   \/_____/   /_/_/       \____\/   \_\/  \/_/   \/_/    /_/_/      \/___\/  \/_/ \_\/  
                                                                                                  
                                                                        
${RESET}"

# Function to list interfaces and ask user to select one
select_adapter() {
    echo -e "${CYAN}Available wireless interfaces:${RESET}"
    mapfile -t interfaces < <(iw dev | awk '$1=="Interface"{print $2}')

    if [ ${#interfaces[@]} -eq 0 ]; then
        echo -e "${RED}No wireless interfaces found!${RESET}"
        exit 1
    fi

    for i in "${!interfaces[@]}"; do
        echo "$((i+1)). ${interfaces[$i]}"
    done
    echo "$(( ${#interfaces[@]} + 1 )). Exit"

    while true; do
        read -p "Select your interface [1-$(( ${#interfaces[@]} + 1 ))]: " choice
        if [[ "$choice" =~ ^[1-9][0-9]*$ ]]; then
            if [ "$choice" -ge 1 ] && [ "$choice" -le ${#interfaces[@]} ]; then
                ADAPTER="${interfaces[$((choice-1))]}"
                echo -e "${GREEN}You selected interface: $ADAPTER${RESET}"
                check_monitor_support
                break
            elif [ "$choice" -eq $(( ${#interfaces[@]} + 1 )) ]; then
                echo -e "${YELLOW}Exiting the script... Goodbye!${RESET}"
                exit 0
            fi
        fi
        echo -e "${RED}Invalid selection, try again.${RESET}"
    done
}

# Function to check if adapter supports monitor mode
check_monitor_support() {
    echo -e "${CYAN}[+] Checking if $ADAPTER supports monitor mode...${RESET}"
    if iw list | awk '/Supported interface modes:/,/^$/' | grep -q " * monitor"; then
        echo -e "${GREEN}[✓] $ADAPTER supports monitor mode.${RESET}"
    else
        echo -e "${RED}[✗] $ADAPTER does not support monitor mode. Exiting.${RESET}"
        exit 1
    fi
}

# Function to get current mode (helper)
get_mode() {
    iw dev $ADAPTER info | awk '/type/ {print $2}'
}

# Function to get IP address (only if managed)
get_ip() {
    ip addr show $ADAPTER | awk '/inet / {print $2}' | cut -d/ -f1
}

# Function to show adapter status (mode, MAC, IP)
show_status() {
    mode=$(get_mode)
    mac=$(ip link show $ADAPTER | awk '/link\/ether/ {print $2}')
    state=$(ip link show $ADAPTER | awk '/state/ {print $9}')
    ip="N/A"
    if [ "$mode" == "managed" ]; then
        ip=$(get_ip)
        if [ -z "$ip" ]; then ip="No IP assigned"; fi
    fi

    echo -e "${CYAN}--------------------------------------${RESET}"
    echo -e "${YELLOW}Status for interface: $ADAPTER${RESET}"
    echo -e "${CYAN}--------------------------------------${RESET}"
    printf "%-15s %-20s\n" "MAC Address:" "$mac"
    printf "%-15s %-20s\n" "Mode:" "$mode"
    printf "%-15s %-20s\n" "Interface State:" "$state"
    printf "%-15s %-20s\n" "IP Address:" "$ip"
    echo -e "${CYAN}--------------------------------------${RESET}"
}

# Function to enable monitor mode
enable_monitor() {
  current_mode=$(get_mode)
  if [ "$current_mode" == "monitor" ]; then
      echo -e "${YELLOW}[!] $ADAPTER is already in monitor mode.${RESET}"
      return
  fi
  echo -e "${CYAN}You have selected to enable monitor mode.${RESET}"
  echo -e "${CYAN}[+] Disabling NetworkManager management for $ADAPTER...${RESET}"
  sudo nmcli dev set $ADAPTER managed no
  echo -e "${CYAN}[+] Enabling monitor mode on $ADAPTER...${RESET}"
  sudo ip link set $ADAPTER down
  sudo iw dev $ADAPTER set type monitor
  sudo ip link set $ADAPTER up
  echo -e "${GREEN}[✓] Monitor mode enabled on $ADAPTER${RESET}"
}

# Function to disable monitor mode
disable_monitor() {
  current_mode=$(get_mode)
  if [ "$current_mode" == "managed" ]; then
      echo -e "${YELLOW}[!] $ADAPTER is already in managed (normal) mode.${RESET}"
      return
  fi
  echo -e "${CYAN}You have selected to disable monitor mode.${RESET}"
  echo -e "${CYAN}[+] Disabling monitor mode on $ADAPTER...${RESET}"
  sudo ip link set $ADAPTER down
  sudo iw dev $ADAPTER set type managed
  sudo ip link set $ADAPTER up
  echo -e "${CYAN}[+] Re-enabling NetworkManager management for $ADAPTER...${RESET}"
  sudo nmcli dev set $ADAPTER managed yes
  echo -e "${GREEN}[✓] Monitor mode disabled on $ADAPTER${RESET}"
}

# Select interface first
select_adapter

# Main menu loop
while true; do
    echo -e "${CYAN}--------------------------------------${RESET}"
    echo -e "${YELLOW}Network Adapter Mode Switcher${RESET}"
    echo -e "${CYAN}--------------------------------------${RESET}"
    echo "1. Start Monitor Mode"
    echo "2. Stop Monitor Mode"
    echo "3. Show Adapter Status"
    echo "4. Change Adapter"
    echo "5. Exit"
    echo -e "${CYAN}--------------------------------------${RESET}"

    read -p "Enter your choice [1-5]: " user_choice

    case $user_choice in
        1)
            enable_monitor
            ;;
        2)
            disable_monitor
            ;;
        3)
            show_status
            ;;
        4)
            select_adapter
            ;;
        5)
            echo -e "${YELLOW}Exiting the script... Goodbye!${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice, please select 1-5.${RESET}"
            ;;
    esac
done
