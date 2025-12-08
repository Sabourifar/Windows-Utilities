# README
## Overview
This repository contains three utilities developed by Sabourifar:
1. **DNS Configuration Utility**
2. **Password Manager Utility**
3. **Fast Startup Disabler**

These scripts are designed to facilitate network DNS configuration, secure password generation/management, and enabling true cold shutdowns, respectively.

---
## DNS Configuration Utility
### Overview
The **DNS Configuration Utility** is a Batch script developed by Sabourifar to simplify DNS configuration on Windows machines. This utility helps users manage DNS settings with pre-configured public servers, custom configurations with IP validation, DHCP reversion, network reset, DNS cache flushing, or viewing network information.
### Features
- **Automatic Network Interface Detection:** Detects the active network interface and displays current DNS settings with provider recognition.
- **Network Information Display:** Shows public IP, local IP, and default gateway alongside DNS details.
- **Pre-configured DNS with Latency:** Select from providers with real-time latency shown during selection for informed choices.
- **DNS Provider Recognition:** Automatically detects and displays the name of your current DNS provider.
- **DHCP Detection:** Identifies when DNS is set to DHCP and displays appropriate information.
- **Pre-configured Public DNS Servers:** Options including Cloudflare, Google, Quad9, OpenDNS, UltraDNS, and more.
- **Custom DNS Configuration:** Manually set primary and secondary DNS servers with IP format validation.
- **DHCP Reversion:** Revert to automatic DNS settings via DHCP with proper detection and cache flush.
- **Network Reset:** Comprehensive reset including Winsock, TCP/IP, Firewall, DNS cache, and IP configuration with user confirmation and error checking.
- **DNS Cache Flush:** Clear the DNS resolver cache with error checking.
- **Current Network View:** View your current network information including IPs, gateway, and DNS with provider recognition.
- **Automatic DNS Cache Flushing:** DNS cache is flushed after any DNS configuration change.
- **User-Friendly Interface:** Menu-driven with standardized prompts, enhanced error handling, consistent formatting, and clear navigation.
- **Administrative Privileges Check:** Auto-requests elevation if needed.
- **Optimized Performance:** Fast input response and efficient buffer management.
### Prerequisites
- **Windows Operating System:** Uses native `netsh` and `ipconfig` commands.
- **Administrative Privileges:** Required for DNS modifications; elevation prompted if necessary.
- **PowerShell:** Used for some operations (pre-installed on Windows).
### Usage
1. **Run the Script:**
   - Right-click `DNS_Configuration.bat` and select **Run as administrator**.
2. **Follow Prompts:**
   - View active interface, network IPs, gateway, and current DNS settings with provider recognition.
   - Choose a configuration method from the menu.
3. **Options:**
   - Select public DNS with latency info, set custom servers, revert to DHCP, flush cache, reset network, or view current network information.
4. **Exit or Continue:**
   - Return to the menu (1) or exit (0) after an action.
### Options
#### Main Menu
- **1. Preconfigured DNS:** Select from a list of public DNS servers with real-time latency displayed.
- **2. Configure DNS Manually:** Enter custom DNS servers with validation.
- **3. Automatic DNS (DHCP):** Revert to automatic DNS via DHCP with cache flush.
- **4. Clear DNS Cache:** Clear the DNS resolver cache with error checking.
- **5. View Network Information:** View your current network details including IPs, gateway, and DNS with provider recognition.
- **6. Reset Network Settings:** Perform a comprehensive network reset.
- **0. Exit:** Close the script.
#### Preconfigured DNS Servers
- **Cloudflare:** `1.1.1.1`, `1.0.0.1`
- **Google:** `8.8.8.8`, `8.8.4.4`
- **Quad9:** `9.9.9.9`, `149.112.112.112`
- **OpenDNS:** `208.67.222.222`, `208.67.220.220`
- **UltraDNS:** `64.6.64.6`, `64.6.65.6`
- **NTT:** `129.250.35.250`, `129.250.35.251`
- **Shecan:** `178.22.122.100`, `185.51.200.2`
- **Begzar:** `185.55.226.26`, `185.55.225.25`
- **Electro:** `78.157.42.100`, `78.157.42.101`
- **DNSCrypt:** `127.0.0.1` (for use with DNSCrypt)
#### No Interface Menu (Displayed if no active network interface is found)
- **1. Clear DNS Cache:** Clear the DNS resolver cache with error checking.
- **2. Reset Network Settings:** Perform a comprehensive network reset.
- **0. Exit:** Close the script.
#### Manual DNS Configuration
- Prompts for Primary and Secondary (optional) DNS servers.
- Validates IP addresses (e.g., `X.X.X.X`, each octet 0-255, no leading zeros).
- Recognizes if the entered DNS matches known providers.
#### Network Reset
- Performs a comprehensive reset (Winsock, TCP/IP, Firewall, DNS cache, IP release/renew).
- Provides error feedback for each step and recommends a reboot.
- Includes user confirmation for safety.
#### Current Network Information
- Displays your current network details including public IP, local IP, default gateway, and DNS settings with provider recognition.
- Shows whether DNS is set to DHCP or a specific provider.
- Formats the output consistently with the rest of the utility.
#### Exit Menu (After an Action)
- **1. Back to Main Menu:** Go back to the main or no-interface menu.
- **0. Exit:** Close the script.
---
## Fast Startup Disabler
### Overview
The **Fast Startup Disabler** is a PowerShell script that disables Windows Fast Startup (also known as Hybrid Boot) to enable true cold shutdowns instead of hybrid hibernation states.
### Features
- **Auto-Elevation:** Automatically requests administrator privileges if not already running as admin.
- **Registry Modification:** Sets the appropriate registry key to disable Fast Startup.
- **User Feedback:** Displays success message and prompts for restart to apply changes.
- **Persistent Window:** Keeps the window open until a key is pressed for easy reading.
### Prerequisites
- **Windows Operating System:** Compatible with Windows 8 and later editions that support hibernation.
- **PowerShell:** Used for execution (pre-installed on Windows).
### Usage
1. **Run the Script:**
   - Right-click `DisableFastStartup.ps1` and select **Run with PowerShell**.
   - If not already admin, it will relaunch with elevated privileges.
2. **Apply Changes:**
   - The script disables Fast Startup automatically.
3. **Restart:**
   - Restart your PC for the change to take effect.
### Benefits
Enabling true cold shutdowns (instead of hybrid hibernation) provides:
- Full hardware and driver resets on every boot.
- Resolution of issues with stuck updates or driver installations.
- Better compatibility for dual-boot setups and other operating systems.
- Clearing of memory leaks and residual state problems.
- Complete access to BIOS/UEFI settings and firmware updates.
- Slightly improved battery life on laptops when fully powered off.
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
