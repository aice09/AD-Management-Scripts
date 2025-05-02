# AD-Management-Scripts

A collection of PowerShell scripts designed for managing and interacting with Active Directory environments. This repository includes tools for managing devices, querying AD objects, generating reports, and more. These scripts are aimed at administrators who need to automate and streamline their Active Directory management tasks.

## Features

- **Device Management**: Retrieve and manage information about devices (computers) in Active Directory.
- **RSAT Check**: Verifies if the Remote Server Administration Tools (RSAT) are installed before running any Active Directory queries.
- **Active Directory Reports**: Generate reports for Active Directory devices, including their status, manager, organizational unit, and more.
- **User Queries**: Search for AD user information by **sAMAccountName** or other attributes.
- **Compatibility**: Designed to be used in environments running Active Directory with PowerShell.

## Prerequisites

To use these scripts, you must have **RSAT (Remote Server Administration Tools)** installed on your machine.

### Installing RSAT

For Windows 10 or later, you can install RSAT using the following steps:

1. Open **Settings**.
2. Go to **Apps** > **Optional Features**.
3. Scroll down and click **Add a Feature**.
4. Search for **RSAT** and install **RSAT: Active Directory**.

Alternatively, you can install RSAT via PowerShell:

```powershell
# For Windows Server 2019/Windows 10 1809+
Install-WindowsFeature RSAT-AD-PowerShell
```

### Usage
### 1. Cloning the Repository
1. Clone or download the repository to your local machine.
2. Open PowerShell as an administrator.
3. Navigate to the script you want to run.
4. Execute the script:

```
.\AD-Device-Manager.ps1
```
### 2. Running the Script Directly from GitHub

1. Open PowerShell via Administrator and paste the following command.
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/aice09/AD-Management-Scripts/refs/heads/main/AD-Asset-Tracker.ps1" -OutFile "$($Env:TEMP)\AD-Asset-Tracker.ps1"; & "$($Env:TEMP)\AD-Asset-Tracker.ps1";
```
### Note:
- If running script is disabled on the device, run the following command:
```powershell
Set-ExecutionPolicy RemoteSigned
```
or for more security, use this to allow only to run script during the current session.
```powershell
Set-ExecutionPolicy RemoteSigned -Scope Process
```


### Disclaimer
This script is intended for internal use within Active Directory environments. It relies on Active Directory data and assumes administrative access.

The author makes no guarantees regarding the accuracy or completeness of the output. Use with caution in production environments. For issues, please visit the repository and open an issue.

### License
This project is licensed under the MIT License - see the LICENSE file for details.
