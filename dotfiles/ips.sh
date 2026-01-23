#!/usr/bin/env bash
#!/usr/bin/env bash
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export TERM=tmux-256color

set -Eeuo pipefail

get_ip() { ip -4 addr show dev "$1" 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1; }

# Plain Unicode/emoji only (no Nerd Font PUA):
# 🖧 U+1F5A7  🔌 U+1F50C  🛜 U+1F6DC  🔒 U+1F512
declare -A ICONS=(
  ["eth"]=$'\U0001F5A5'   # 🖥 Ethernet
  ["usb"]=$'\U0001F50C'   # 🔌 USB
  ["wlan"]=$'\U0001F6DC'  # 🛜 Wi-Fi
  ["tun_htb"]=$'\U0001F480'   # 💀 VPN/Tunnel
  ["tun"]=$'\U0001F512'   # 🔒 VPN/Tunnel
)

wan_icon=$'\U0001F310' #  🌐

status=""

# Only interfaces that actually have IPv4, and skip docker/veth/bridges/lo, etc.
interfaces=$(ip -o -4 addr show \
  | awk -F': ' '{print $2}' \
  | awk '{print $1}' \
  | grep -Ev '^(lo|docker.*|br-.*|veth.*|virbr.*|vmnet.*|tailscale.*)$' \
  | sort -u)

for iface in $interfaces; do
  ipaddr=$(get_ip "$iface") || true
  [ -z "${ipaddr:-}" ] && continue
  case "$iface" in
    eth*|en*)  icon="${ICONS[eth]}"  ;;
    wlan*|wl*) icon="${ICONS[wlan]}" ;;
    usb*)      icon="${ICONS[usb]}"  ;;
    tun_htb) icon="${ICONS[tun_htb]}"  ;;
    tun*|vpn*) icon="${ICONS[tun]}"  ;;
    *)         icon="${ICONS[eth]}"  ;;
  esac
  status+="$icon $ipaddr "
done

# External IP (quiet, short timeout)
external="$(curl -fsS --max-time 3 ifconfig.me || true)"
[ -n "$external" ] && status+="$wan_icon $external"

printf '%b\n' "$status"

