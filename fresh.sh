#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# Config / helpers
# -----------------------------
MYUSER="${SUDO_USER:-$USER}"
HOME_DIR="$(getent passwd "$MYUSER" | cut -d: -f6)"

log() { echo -e "\n==> $*\n"; }

if [[ -z "${HOME_DIR:-}" || ! -d "$HOME_DIR" ]]; then
  echo "ERROR: Could not determine home directory for user: $MYUSER"
  exit 1
fi

# -----------------------------
# Update and upgrade system
# -----------------------------
log "Updating/Upgrading system packages..."
sudo apt update
sudo apt full-upgrade -y

# -----------------------------
# Install core packages
# -----------------------------
log "Installing core packages..."
sudo apt install -y \
  seclists fastfetch p7zip-full jq \
  docker.io docker-compose-plugin \
  git rsync

# -----------------------------
# Extract rockyou.txt to /usr/share/wordlists
# -----------------------------
log "Extracting rockyou.txt to /usr/share/wordlists..."
sudo mkdir -p /usr/share/wordlists
if [[ -f /usr/share/seclists/Passwords/Leaked-Databases/rockyou.txt.tar.gz ]]; then
  sudo tar -xzf /usr/share/seclists/Passwords/Leaked-Databases/rockyou.txt.tar.gz -C /usr/share/wordlists
else
  echo "WARN: rockyou.txt.tar.gz not found at expected path; skipping."
fi

# -----------------------------
# Enable docker + add user to docker group
# -----------------------------
log "Enabling Docker service and adding $MYUSER to docker group..."
sudo systemctl enable --now docker
sudo usermod -aG docker "$MYUSER"

# -----------------------------
# Install all Kali tools (very large)
# -----------------------------
log "Installing kali-linux-everything (this is huge)..."
sudo apt install -y kali-linux-everything

# -----------------------------
# Remove Code-OSS and install official Microsoft VS Code
# -----------------------------
log "Removing Code-OSS and installing official VS Code..."
sudo apt remove --purge -y code-oss || true
rm -rf "$HOME_DIR/.config/Code - OSS" "$HOME_DIR/.vscode-oss" || true

wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
  | gpg --dearmor \
  | sudo tee /usr/share/keyrings/microsoft.gpg >/dev/null

echo "deb [signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
  | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null

sudo apt update
sudo apt install -y code

# -----------------------------
# Pull dotfiles from GitHub (and ~/.tmux assets)
# -----------------------------
log "Downloading dotfiles into $HOME_DIR ..."
cd "$HOME_DIR"

mkdir -p "$HOME_DIR/.tmux"

DOT_BRANCH="masterOfAll"
DOT_BASE="https://raw.githubusercontent.com/beed2112/hack_top/${DOT_BRANCH}/dotfiles"

wget -q "${DOT_BASE}/.tmux.conf"           -O "$HOME_DIR/.tmux.conf"
wget -q "${DOT_BASE}/.bash_aliases_docker" -O "$HOME_DIR/.bash_aliases_docker"
wget -q "${DOT_BASE}/.bash_aliases"        -O "$HOME_DIR/.bash_aliases"
wget -q "${DOT_BASE}/.bash_functions"      -O "$HOME_DIR/.bash_functions"
wget -q "${DOT_BASE}/ips.sh"               -O "$HOME_DIR/.tmux/ips.sh"

chmod +x "$HOME_DIR/.tmux/ips.sh" || true

sudo chown -R "$MYUSER:$MYUSER" "$HOME_DIR/.tmux" || true
sudo chown "$MYUSER:$MYUSER" \
  "$HOME_DIR/.tmux.conf" \
  "$HOME_DIR/.bash_aliases_docker" \
  "$HOME_DIR/.bash_aliases" \
  "$HOME_DIR/.bash_functions" || true

# -----------------------------
# hack_club install (idempotent)
# -----------------------------
log "Installing hack_club assets..."
HACKCLUB_DIR="/tmp/hack_club"

if [[ -d "$HACKCLUB_DIR/.git" ]]; then
  git -C "$HACKCLUB_DIR" pull --ff-only
else
  rm -rf "$HACKCLUB_DIR"
  git clone --depth 1 https://github.com/beed2112/hack_club.git "$HACKCLUB_DIR"
fi

if [[ -f "$HACKCLUB_DIR/functions" ]]; then
  cp "$HACKCLUB_DIR/functions" "$HOME_DIR/.functions"
  sudo chown "$MYUSER:$MYUSER" "$HOME_DIR/.functions" || true
else
  echo "WARN: $HACKCLUB_DIR/functions not found; skipping copy to ~/.functions"
fi

if [[ -d "$HACKCLUB_DIR/auto-load" ]]; then
  sudo chmod +x "$HACKCLUB_DIR/auto-load/"*.sh 2>/dev/null || true
  sudo chmod +x "$HACKCLUB_DIR/auto-load/install.sh" 2>/dev/null || true
  bash "$HACKCLUB_DIR/auto-load/install.sh"
else
  echo "WARN: $HACKCLUB_DIR/auto-load not found; skipping auto-load install"
fi

# -----------------------------
# Append to user's .bashrc (idempotent)
# -----------------------------
log "Updating $HOME_DIR/.bashrc to source aliases/functions and run fastfetch..."

BASHRC_FILE="$HOME_DIR/.bashrc"
if [[ ! -f "$BASHRC_FILE" ]]; then
  touch "$BASHRC_FILE"
  sudo chown "$MYUSER:$MYUSER" "$BASHRC_FILE" || true
fi

BASHRC_MARKER="# --- pentest dotfiles (added by setup script) ---"
if ! grep -qF "$BASHRC_MARKER" "$BASHRC_FILE"; then
  cat >> "$BASHRC_FILE" <<'EOF'

# --- pentest dotfiles (added by setup script) ---
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f ~/.bash_aliases_docker ]; then
    . ~/.bash_aliases_docker
fi

if [ -f ~/.bash_functions ]; then
    . ~/.bash_functions
fi

# Only run fastfetch for interactive shells
case $- in
  *i*) command -v fastfetch >/dev/null 2>&1 && fastfetch ;;
esac
# --- end pentest dotfiles ---
EOF
fi
sudo chown "$MYUSER:$MYUSER" "$BASHRC_FILE" || true

# -----------------------------
# Create vault (idempotent fetch + sync)
# -----------------------------
log "Creating vault ..."
mkdir -p "$HOME_DIR/Documents/vaults"

rm -rf /tmp/obs
git clone --depth 1 https://github.com/beed2112/obs.git /tmp/obs

DEST="$HOME_DIR/Documents/vaults/main"
mkdir -p "$DEST"
rsync -a --delete /tmp/obs/main/ "$DEST/"

sudo chown -R "$MYUSER:$MYUSER" "$HOME_DIR/Documents/vaults" || true

# -----------------------------
# Install Nerd Fonts (clone + install)
# -----------------------------
log "Installing Nerd Fonts..."
mkdir -p "$HOME_DIR/gitspace"
cd "$HOME_DIR/gitspace"

if [[ ! -d nerd-fonts ]]; then
  git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git
fi

cd nerd-fonts
./install.sh
sudo chown -R "$MYUSER:$MYUSER" "$HOME_DIR/gitspace" || true

# -----------------------------
# Configure passwordless sudo for pentest tools
# -----------------------------
log "Creating /etc/sudoers.d/pentest-nopasswd..."
SUDOERS_FILE="/etc/sudoers.d/pentest-nopasswd"

sudo tee "$SUDOERS_FILE" >/dev/null <<EOF
Defaults:${MYUSER} !requiretty

${MYUSER} ALL=(root) NOPASSWD: \
    /usr/bin/nmap, \
    /usr/sbin/responder, \
    /usr/bin/docker, \
    /usr/bin/docker-compose, \
    /usr/sbin/openvpn
EOF

sudo chmod 0440 "$SUDOERS_FILE"
sudo visudo -cf "$SUDOERS_FILE"

log "Sudoers configuration validated successfully."

# -----------------------------
# Cleanup
# -----------------------------
log "Final cleanup..."
sudo apt autoremove -y
sudo apt clean

# -----------------------------
# Reboot reminder
# -----------------------------
echo
echo "✅ Setup complete! Please reboot your system for all changes to take effect."
echo "   NOTE: Group changes (docker) require you to log out/in or reboot."
echo
