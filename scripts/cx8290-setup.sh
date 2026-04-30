#!/usr/bin/env bash
set -euo pipefail

AUTH_FILE="/etc/apt/auth.conf.d/bhf.conf"
PACKAGE_NAME="tc31-xar-um"

echo "CX8290 TwinCAT XAR setup"
echo

read -rp "MyBeckhoff email: " BECKHOFF_LOGIN
read -rsp "MyBeckhoff password: " BECKHOFF_PASSWORD
echo
echo

if [ -z "$BECKHOFF_LOGIN" ]; then
  echo "Error: MyBeckhoff email cannot be empty."
  exit 1
fi

if [ -z "$BECKHOFF_PASSWORD" ]; then
  echo "Error: MyBeckhoff password cannot be empty."
  exit 1
fi

echo "Creating Beckhoff APT authentication file..."

sudo install -d -m 755 "$(dirname "$AUTH_FILE")"
sudo install -m 600 /dev/null "$AUTH_FILE"

{
  printf "machine deb.beckhoff.com\n"
  printf "login %s\n" "$BECKHOFF_LOGIN"
  printf "password %s\n\n" "$BECKHOFF_PASSWORD"

  printf "machine deb-mirror.beckhoff.com\n"
  printf "login %s\n" "$BECKHOFF_LOGIN"
  printf "password %s\n" "$BECKHOFF_PASSWORD"
} | sudo tee "$AUTH_FILE" > /dev/null

sudo chmod 600 "$AUTH_FILE"

echo "Updating package lists..."
sudo apt update

echo "Installing TwinCAT 3 XAR package: $PACKAGE_NAME"
sudo apt install -y "$PACKAGE_NAME"

echo
echo "CX8290 setup complete."