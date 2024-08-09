#!/bin/bash

# Konstanter
SCRIPT_DIR="$HOME/.local/bin"
SYSTEMD_DIR="/etc/systemd/system"
SCRIPT_NAME="get_hosts-file.sh"
TIMER_NAME="update-hosts.timer"
SERVICE_NAME="update-hosts.service"

# Skapar "bin" om den inte redan finns
mkdir -p "$SCRIPT_DIR"

# Kopierar scriptet som systemd-servicen kör enligt systemd-timer-schema
cp "$SCRIPT_NAME" "$SCRIPT_DIR" && chmod +x "$SCRIPT_DIR/$SCRIPT_NAME"

# Kopierar systemd-filer, aktiverar timern och hämtar hosts-filen
sudo cp update-hosts.{timer,service} "$SYSTEMD_DIR"
sudo systemctl daemon-reload
sudo systemctl enable --now "$TIMER_NAME"
sudo systemctl start "$SERVICE_NAME"

# Loggar en lyckad installation
logger -t install_script "Installationen av $SCRIPT_NAME samt systemd-filer är klara och hosts-filen är på plats"
