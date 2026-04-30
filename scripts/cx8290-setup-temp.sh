#!/usr/bin/env bash
set -euo pipefail

PACKAGE_NAME="tc31-xar-um"

# moved sudo password to the top to prevent confusion.  
sudo -v

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

echo "Creating temporary Beckhoff APT authentication file..."

AUTH_FILE="$(sudo mktemp /tmp/bhf.XXXXXX.conf)"

cleanup() {
  if [ -n "${AUTH_FILE:-}" ]; then
    sudo rm -f "$AUTH_FILE"
  fi
}

trap cleanup EXIT

sudo chmod 600 "$AUTH_FILE"
sudo chown root:root "$AUTH_FILE"

{
  printf "machine deb.beckhoff.com\n"
  printf "login %s\n" "$BECKHOFF_LOGIN"
  printf "password %s\n\n" "$BECKHOFF_PASSWORD"

  printf "machine deb-mirror.beckhoff.com\n"
  printf "login %s\n" "$BECKHOFF_LOGIN"
  printf "password %s\n" "$BECKHOFF_PASSWORD"
} | sudo tee "$AUTH_FILE" > /dev/null

unset BECKHOFF_PASSWORD

APT_AUTH_OPTION=(-o "Dir::Etc::netrc=$AUTH_FILE")

echo "Updating package lists..."
sudo apt-get "${APT_AUTH_OPTION[@]}" update

echo "Installing TwinCAT 3 XAR package: $PACKAGE_NAME"
sudo apt-get "${APT_AUTH_OPTION[@]}" install -y "$PACKAGE_NAME"

echo
echo "CX8290 setup complete."
