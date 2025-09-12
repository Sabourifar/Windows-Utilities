# README

## Overview

This repository contains two utilities developed by Sabourifar:

1. **DNS Configuration Utility**
2. **Password Manager Utility**

These scripts are designed to facilitate network DNS configuration and secure password generation/management, respectively.

---

## DNS Configuration Utility

### Overview

The **DNS Configuration Utility** is a Batch script developed by Sabourifar to simplify DNS configuration on Windows machines. This utility helps users manage DNS settings with pre-configured public servers, custom configurations with IP validation, DHCP reversion, network reset, or DNS cache flushing.

### Features

- **Automatic Network Interface Detection:** Detects the active network interface and displays current DNS settings with provider recognition.
- **DNS Provider Recognition:** Automatically detects and displays the name of your current DNS provider.
- **DHCP Detection:** Identifies when DNS is set to DHCP and displays appropriate information.
- **Pre-configured Public DNS Servers:** Expanded options including Cloudflare, Google, Quad9, OpenDNS, UltraDNS, and more.
- **Custom DNS Configuration:** Manually set primary and secondary DNS servers with IP format validation.
- **DHCP Reversion:** Revert to automatic DNS settings via DHCP with proper detection and cache flush.
- **Network Reset:** Comprehensive reset including Winsock, TCP/IP, Firewall, DNS cache, and IP configuration with user confirmation and error checking.
- **DNS Cache Flush:** Clear the DNS resolver cache with error checking and a 1-second delay for visibility.
- **Current DNS View:** View your current DNS configuration with provider recognition.
- **Automatic DNS Cache Flushing:** DNS cache is flushed after any DNS configuration change with a 1-second delay.
- **User-Friendly Interface:** Menu-driven with standardized prompts, enhanced error handling, consistent formatting, and clear navigation.
- **Administrative Privileges Check:** Auto-requests elevation if needed.

### Prerequisites

- **Windows Operating System:** Uses native `netsh` and `ipconfig` commands.
- **Administrative Privileges:** Required for DNS modifications; elevation prompted if necessary.
- **PowerShell:** Used for interface detection (pre-installed on Windows).

### Usage

1. **Run the Script:**
   - Right-click `DNS_Configuration.bat` and select **Run as administrator**.
2. **Follow Prompts:**
   - View active interface and current DNS settings with provider recognition.
   - Choose a configuration method from the menu.
3. **Options:**
   - Select public DNS, set custom servers, revert to DHCP, flush cache, reset network, or view current configuration.
4. **Exit or Continue:**
   - Return to the menu (1) or exit (0) after an action.

### Options

#### Main Menu
- **1. Public DNS Servers (Pre Configured):** Select from an expanded list of public DNS servers.
- **2. Advanced (Configure Manually):** Enter custom DNS servers with validation.
- **3. Set DNS To DHCP:** Revert to automatic DNS via DHCP with cache flush.
- **4. Flush DNS Cache:** Clear the DNS resolver cache with error checking and delay.
- **5. Reset Network Settings:** Perform a comprehensive network reset with delays for each step.
- **6. Current DNS Configuration:** View your current DNS settings with provider recognition.
- **0. Exit:** Close the script.

#### Public DNS Servers
- **1. Cloudflare:** `1.1.1.1`, `1.0.0.1`
- **2. Google:** `8.8.8.8`, `8.8.4.4`
- **3. Quad9:** `9.9.9.9`, `149.112.112.112`
- **4. OpenDNS:** `208.67.222.222`, `208.67.220.220`
- **5. UltraDNS:** `64.6.64.6`, `64.6.65.6`
- **6. UltraDNS2:** `156.154.70.2`, `156.154.71.2`
- **7. NTT:** `129.250.35.250`, `129.250.35.251`
- **8. Shecan:** `178.22.122.100`, `185.51.200.2`
- **9. Begzar:** `185.55.226.26`, `185.55.225.25`
- **10. Radar:** `10.202.10.10`, `10.202.10.11`
- **11. Electro:** `78.157.42.100`, `78.157.42.101`
- **12. DNSCrypt:** `127.0.0.1` (for use with DNSCrypt)
- **0. Return to menu:** Go back to the main menu without applying changes.

#### No Interface Menu (Displayed if no active network interface is found)
- **1. Flush DNS Cache:** Clear the DNS resolver cache with error checking and delay.
- **2. Reset Network Settings:** Perform a comprehensive network reset with delays.
- **0. Exit:** Close the script.

#### Advanced Configuration
- Prompts for Primary and Secondary (optional) DNS servers.
- Validates IP addresses (e.g., `X.X.X.X`, each octet 0-255, no leading zeros).
- Recognizes if the entered DNS matches known providers.

#### Network Reset
- Performs a comprehensive reset (Winsock, TCP/IP, Firewall, DNS cache, IP release/renew).
- Includes a 1-second delay after the initial message of each step for visibility.
- Provides error feedback for each step and recommends a reboot.

#### Current DNS Configuration
- Displays your current DNS settings with provider recognition.
- Shows whether DNS is set to DHCP or a specific provider.
- Formats the output consistently with the rest of the utility.

#### Exit Menu (After an Action)
- **1. Return to menu:** Go back to the main or no-interface menu.
- **0. Exit:** Close the script.

---

## Password Manager Utility

### Overview

The **Password Manager Utility** is a PowerShell script that generates secure passwords and manages login information. It offers secure or custom password generation with options to save passwords or full login details.

### Features

- **Secure Passwords:** Includes all character types (uppercase, lowercase, numbers, symbols).
- **Custom Passwords:** User selects character types (at least one required).
- **Login Info Management:** Save passwords with website/title and username.
- **Persistent Interface:** Runs until explicitly exited with "0".
- **File Saving:** Outputs to `Passwords.txt` in the script directory.

### Prerequisites

- **Windows with PowerShell:** Requires PowerShell 5.1 or later.

### Execution Policy

Run this command in PowerShell as Administrator to enable script execution:
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
```

### Usage

1. **Run the Script:**
   - Right-click `Password_Manager.ps1` and select **Run with PowerShell**.
2. **Main Menu:**
   - Choose secure/custom password generation or exit (0).
3. **Set Length:** Enter 4-80 characters.
4. **Action Menu:**
   - Generate another, save password/login info, return to menu, or exit (0).

### Options

#### Main Menu
- **1. Secure Password (Recommended):** Generates a password with all character types.
- **2. Custom Password:** Allows selection of character types (uppercase, lowercase, numbers, symbols).
- **0. Exit:** Close the script.

#### Action Menu (After Generating a Password)
- **1. Generate Another:** Create a new password with the same settings.
- **2. Save Password:** Save the password to `Passwords.txt`.
- **3. Save Login Info:** Save website/title, username, and password to `Passwords.txt`.
- **4. Main Menu:** Return to the main menu.
- **0. Exit:** Close the script.

---

## Contributing

Feel free to modify and enhance the scripts. Contributions are welcome!

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Contact

For inquiries or feedback, reach out to Sabourifar.
