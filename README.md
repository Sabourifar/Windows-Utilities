# README

## Overview

This repository contains three Windows Batch utilities developed by Sabourifar:

- **DFStartup** – Disables Windows Fast Startup for true cold boots.
- **DNSConfig** – Comprehensive DNS management tool with provider selection and latency testing.
- **PWGenerator** – Secure password generator with optional saving of login credentials.

All scripts are self-contained and use only built-in Windows features.

---

## DFStartup

### Purpose
Disables Windows Fast Startup (Hybrid Boot) by modifying the relevant registry key, enabling full hardware resets on shutdown.

### Features
- Automatic elevation to administrator privileges
- Clear success feedback
- Reminder to restart for changes to take effect

### Benefits
- Complete hardware/driver reset on boot
- Improved dual-boot compatibility
- Better BIOS/UEFI access
- Resolution of certain update and driver issues

---

## DNSConfig

### Purpose
Simplifies DNS configuration, diagnostics, and network troubleshooting on Windows systems.

### Key Features
- Detects active network interface and current DNS settings
- Displays public IP, local IP, gateway, and DNS provider (with automatic recognition)
- Pre-configured providers (Cloudflare, Google, Quad9, OpenDNS, UltraDNS, NTT, Shecan, Electro, DNSCrypt) with latency testing
- Background ping caching and manual re-ping option
- Custom DNS entry with IP validation
- Revert to DHCP
- DNS cache flush
- Comprehensive network reset (Winsock, TCP/IP, firewall, IP release/renew)
- Menu-driven interface with clear navigation and error handling
- Automatic administrator elevation

### Supported Providers
- Cloudflare (1.1.1.1 / 1.0.0.1)
- Google (8.8.8.8 / 8.8.4.4)
- Quad9 (9.9.9.9 / 149.112.112.112)
- OpenDNS (208.67.222.222 / 208.67.220.220)
- UltraDNS (64.6.64.6 / 64.6.65.6)
- NTT (129.250.35.250 / 129.250.35.251)
- Shecan (178.22.122.100 / 185.51.200.2)
- Electro (78.157.42.100 / 78.157.42.101)
- DNSCrypt (127.0.0.1)

---

## PWGenerator

### Purpose
Generates strong random passwords and optionally saves them with associated login information.

### Key Features
- Secure mode: includes uppercase, lowercase, numbers, and symbols
- Custom mode: user-selectable character sets (minimum one required)
- Password length: 4–80 characters
- Balanced character distribution with Fisher-Yates shuffle
- Options to save password only or with title/username to `Passwords.txt` in script directory
- Simple, menu-driven interface

---

## License
MIT License – see [LICENSE](LICENSE) for details.
