
---

##  tmux basics (from your config)

- **Prefix:** `Ctrl + a`
    
   
- **Split keys:**
    
    - `Prefix` + `|` → split **left/right**
        
    - `Prefix` + `-` → split **top/bottom**
        
- **Copy-mode keys:** vi-style (`mode-keys vi`)
    
- **Theme/status:** Dracula + custom IP script (your `ips.sh`) shown in status bar
    

---

## Windows

### Create windows

- `Prefix` + `c` → **new window**
    
- `Prefix` + `,` → **rename current window**
    
    - (type name, Enter)
        

### Navigate windows

- `Prefix` + `n` → next window
    
- `Prefix` + `p` → previous window
    
- `Prefix` + `w` → window list (pick one)
    
- `Prefix` + `<number>` → jump to window 0–9
    


## Panes

### Split panes (your custom bindings)

- `Prefix` + `|` → split **horizontally** (side-by-side)
    
- `Prefix` + `-` → split **vertically** (stacked)
    

### Resize panes (default tmux)

- `Prefix` + `Alt` + `←/→/↑/↓` → resize (works in many setups)
    
- Or use command prompt:
    
    - `Prefix` + `:` then `resize-pane -L 5` (or `-R/-U/-D`)
        

### Layouts & pane tools

- `Prefix` + `space` → cycle layouts (even-horizontal, even-vertical, main, tiled)
    
- `Prefix` + `q` → show pane numbers (then press number to jump)
    
- `Prefix` + `z` → zoom/unzoom current pane
    
- `Prefix` + `x` → kill current pane (confirm)
    

---
### Reorder / move windows

- `Prefix` + `.` → **move window** (you’ll be prompted for a new index)
    
- `Prefix` + `:` then:
    
    - `swap-window -s 1 -t 3` → swap window 1 with 3
        
    - `move-window -t 0` → move current window to index 0
        

**Tip:** If you want “move window left/right” fast, you can add binds later (I can give you a patch), but the above works with stock tmux.

---

## Moving panes between windows

### Convert a pane into its own window

- `Prefix` + `!` → **break pane** into a **new window**
    

### Move pane to a different window

- `Prefix` + `:` then:
    
    - `move-pane -t 2` → move current pane to window 2
        
    - `move-pane -t :2.1` → move to window 2, pane index 1
        

### Swap panes

- `Prefix` + `{` → swap pane with previous
    
- `Prefix` + `}` → swap pane with next
    
- `Prefix` + `o` → cycle through panes
    

---

## Renaming / organizing sessions

- `Prefix` + `$` → rename session
    
- `Prefix` + `s` → session list (switch)
    

Your Dracula left icon is set to show: `#h | #S` (host | session), which is great when you have multiple sessions.

---

## Copy / scroll (vi style)

- `Prefix` + `[` → enter copy mode (scrollback)
    
- In copy mode (vi):
    
    - `q` → quit
        
    - `/` → search forward
        
    - `?` → search backward
        
    - `Space` → start selection
        
    - `Enter` → copy selection
        

---

## Status bar IP script (what it’s doing)

Your `ips.sh`:

- shows **IPv4 per active interface** (skips docker/veth/bridges/lo/tailscale/etc.)
    
- tags interface types with emoji (eth/wifi/usb/tun)
    
- appends **external IP** using `curl ifconfig.me` with a short timeout
    

So the tmux bar becomes a quick “network situational awareness” strip—especially nice for HTB/VPN labs.

---

## Quick “muscle memory” mini-map

**New work area**

- `C-a c` → new window
    
- `C-a |` / `C-a -` → split
    
- `h j k l` → move focus
    

**Organize**

- `C-a ,` rename window
    
- `C-a .` move window index
    
- `C-a !` break pane into new window
    

**Find things**

- `C-a w` list windows
    
- `C-a q` show pane numbers
    
- `C-a z` zoom
    
