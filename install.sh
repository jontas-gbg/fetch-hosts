#!/bin/bash

# Const
SCRIPT_DIR="$HOME/.local/bin"
SYSTEMD_DIR="$HOME/.config/systemd/user"
SCRIPT_NAME="gethosts"
TIMER_NAME="update-hosts.timer"
SERVICE_NAME="update-hosts.service"

# Create local bin if not exists
mkdir -p "$SCRIPT_DIR"

# Copy script, timer and service to it's directories
cp "$SCRIPT_NAME" "$SCRIPT_DIR" && chmod +x "$SCRIPT_DIR/$SCRIPT_NAME" &&
cp update-hosts.{timer,service} "$SYSTEMD_DIR"

# reload, enable and get hosts file 
systemctl --user daemon-reload &&
systemctl --user enable --now "$TIMER_NAME" &&
systemctl --user start "$SERVICE_NAME"

