# WinAsset-QuickScan
Lightweight PowerShell script for agentless hardware inventory. Captures system specs, decodes monitor EDID data (Manufacturer &amp; Serial), and identifies docking stations via network interface patterns.

# 🛠️ WinAsset-QuickScan (PowerShell Hardware Inventory)

A lightweight, agentless PowerShell script designed for IT administrators to quickly gather hardware asset data. Perfect for helpdesk audits, hardware deployments, or rapid troubleshooting where a full management suite isn't available.

## 🚀 Key Features

* **Host Identification:** Retrieves Manufacturer, Model, and BIOS Serial Number directly from CIM/WMI.
* **Monitor Decoding:** Queries `WmiMonitorID` to extract manufacturer codes and serial numbers. Includes an ASCII-to-String converter and maps common vendor codes (SAM, LEN, ACR, IVM).
* **Docking Station Detection:** A clever workaround that identifies connected docks by scanning physical network interface descriptions for "USB" or "Dock" patterns.
* **User Context:** Automatically binds the current `$env:USERDOMAIN\$env:USERNAME` to the report for easy assignment.
* **Clean Output:** Generates an auto-sized table for immediate terminal review.

## ⚠️ Important Note: Monitor Serials
As noted in the code comments, please be aware that for some brands (specifically **ACER**), the internal serial number reported via WMI/EDID may differ from the physical sticker on the back of the monitor. The script provides the system-reported ID.

## 📋 Usage

1. **Download** the script `Get-Inventory.ps1`.
2. **Open PowerShell** (as Administrator if possible, though most commands work as a standard user).
3. **Run the script**:
   ```powershell
   .\Get-Inventory.ps1

## 📥 [Download the Script Here](Get-Inventory.ps1)
