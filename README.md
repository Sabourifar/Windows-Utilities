# README

## Overview

This repository contains three Windows Batch utilities developed by Sabourifar:

- **DFStartup.bat** – Disables Windows Fast Startup for true cold boots.
- **DNSConfig.bat** – Comprehensive DNS management tool with provider selection, latency testing, and network diagnostics.
- **PWGenerator.bat** – Secure password generator with optional saving of login credentials.

All scripts are self-contained, require no external dependencies beyond standard Windows features, and include administrative privilege elevation where necessary.

---

## DFStartup.bat

### Purpose
Disables Windows Fast Startup (Hybrid Boot) by modifying the relevant registry key, enabling full hardware resets on shutdown.

### Features
- Automatic elevation to administrator privileges
- Clear success feedback
- Reminder to restart for changes to take effect

### Usage
Right-click `DFStartup.bat` and select **Run as administrator** (or simply run it; elevation will be requested if needed). Restart the system afterward.

### Benefits
- Complete hardware/driver reset on boot
- Improved dual-boot compatibility
- Better BIOS/UEFI access
- Resolution of certain update and driver issues

---

## DNSConfig.bat

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

### Usage
Run `DNSConfig.bat` as administrator. Follow the on-screen menu to configure DNS, view information, or perform maintenance tasks.

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

## PWGenerator.bat

### Purpose
Generates strong random passwords and optionally saves them with associated login information.

### Key Features
- Secure mode: includes uppercase, lowercase, numbers, and symbols
- Custom mode: user-selectable character sets (minimum one required)
- Password length: 4–80 characters
- Balanced character distribution with Fisher-Yates shuffle
- Options to save password only or with title/username to `Passwords.txt` in script directory
- Simple, menu-driven interface

### Usage
Run `PWGenerator.bat`. Choose secure or custom generation, specify length (and character types if custom), then decide whether to generate another or save the result.

---

## License
MIT License – see [LICENSE](LICENSE) for details.
