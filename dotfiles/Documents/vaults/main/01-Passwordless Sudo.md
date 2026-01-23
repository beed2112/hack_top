
---

# 🔐 Passwordless Sudo for Pentesting Tools

**File:** `/etc/sudoers.d/pentest-nopasswd`

---

## 📌 Purpose

This sudoers drop-in file allows a **specific user (`eric`)** to run **selected pentesting and lab tools as root without entering a password**.

This is intended for:

- Pentesting labs (GOAD, MINILAB, HTB, PG)
    
- Local research environments
    
- Disposable or non-production systems
    

⚠️ **This configuration is NOT suitable for production systems.**

---

## 📄 Current Configuration

```sudoers
# Allow passwordless use of specific pentest tools

Defaults:$USER !requiretty

USER ALL=(root) NOPASSWD: \
    /usr/bin/nmap, \
    /usr/sbin/responder, \
    /usr/bin/docker, \
    /usr/bin/docker-compose, \
    /usr/sbin/openvpn
```

---

## 🧠 Line-by-Line Explanation

### 1️⃣ Comment

```sudoers
# Allow passwordless use of specific pentest tools
```

Purely informational. Strongly recommended to keep comments in sudoers files for future audits.

---

### 2️⃣ Disable TTY requirement (per-user)

```sudoers
Defaults:eric !requiretty
```

**What this does:**

- Allows `$USER$` to use `sudo` **without an interactive terminal**
    
- Required for:
    
    - Scripts
        
    - Docker containers
        
    - SSH non-interactive commands
        
    - Automation tools
        

Without this, commands like `sudo docker ps` may fail in scripted contexts.

---

### 3️⃣ Core permission rule

```sudoers
$USER ALL=(root) NOPASSWD: \
```

**Meaning:**

- `$USER$` → the user this applies to
    
- `ALL` → from any host
    
- `(root)` → can run commands as root
    
- `NOPASSWD:` → no password prompt
    

This does **NOT** grant full sudo access — only the commands listed below.

---

### 4️⃣ Allowed commands (explicit paths)

#### 🔍 `nmap`

```sudoers
/usr/bin/nmap
```

- Required for:
    
    - SYN scans (`-sS`)
        
    - OS detection
        
    - Raw packet crafting
        
- Prevents constant password prompts during enumeration
    

---

#### 🎭 `responder`

```sudoers
/usr/sbin/responder
```

- Needs root to:
    
    - Bind to privileged ports
        
    - Poison LLMNR/NBT-NS
        
- Commonly run repeatedly during lab work
    

---

#### 🐳 `docker`

```sudoers
/usr/bin/docker
```

⚠️ **Important security note:**

- Docker access is effectively **root-equivalent**
    
- Containers can mount `/`, create privileged containers, etc.
    

Acceptable for:

- Labs
    
- Kali boxes
    
- Dedicated pentest hosts
    

---

#### 🧩 `docker-compose`

```sudoers
/usr/bin/docker-compose
```

- Legacy v1 binary support
    
- Useful for older tooling that still calls `docker-compose`
    
- If using Docker Compose v2 plugin, this may not be strictly required
    

---

#### 🔐 `openvpn`

```sudoers
/usr/sbin/openvpn
```

- Required to:
    
    - Create tun/tap interfaces
        
    - Modify routing tables
        
- Useful for HTB, VPN-based labs, and segmented test networks
    

---

## 🛠️ How to Safely Update This File

### ✅ Always use `visudo`

Never edit sudoers files with a normal editor.

```bash
sudo visudo -f /etc/sudoers.d/pentest-nopasswd
```

This ensures:

- Syntax validation
    
- No lockouts due to errors
    

---

### ➕ Adding a new tool (example: `tcpdump`)

1️⃣ Find the absolute path:

```bash
which tcpdump
```

Example output:

```text
/usr/sbin/tcpdump
```

2️⃣ Add it to the list (comma required):

```sudoers
    /usr/sbin/tcpdump,
```

⚠️ **Last entry may omit the trailing comma**

---

### ➖ Removing a tool

Simply delete the corresponding line, save, and exit.

No reload is required — sudoers changes apply immediately.

---

## 🔎 Verify Permissions

Test without password prompts:

```bash
sudo nmap -sS 127.0.0.1
sudo responder -h
sudo docker ps
sudo openvpn --version
```

If prompted for a password:

- Path mismatch is the most common cause
    
- Re-check with `which <tool>`
    

---

## 🧼 Auditing & Cleanup

List what `eric` can run:

```bash
sudo -l -U eric
```

Disable temporarily (comment lines):

```sudoers
# eric ALL=(root) NOPASSWD: ...
```

Remove entirely:

```bash
sudo rm /etc/sudoers.d/pentest-nopasswd
```

---

## 🔐 Security Notes & Best Practices

- Prefer **explicit binaries** (✔ already done)
    
- Avoid `NOPASSWD: ALL`
    
- Docker access = root (by design)
    
- Separate configs for:
    
    - `lab` machines
        
    - `daily-driver` systems
        
- Revisit after engagements
    


