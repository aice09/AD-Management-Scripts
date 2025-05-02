# =============================================================
# === AD Device Full Info Lookup Script =======================
# =============================================================
# Description   : This script retrieves and displays all AD properties
#                 of a specified device by name, across a given domain.
# Maintained by : Carl Angelo Nievarez
# Repository    : https://github.com/aice09/AD-Management-Scripts
# License       : MIT
# Developed on  : May 2, 2025
# Version       : 1.0.0
#
# DISCLAIMER:
# This script is intended for internal use within Active Directory environments.
# It requires RSAT tools and assumes administrative access.
# The author does not guarantee accuracy or completeness of output.
# Use at your own risk. For issues, visit the repository.
# =============================================================

# Import Active Directory Module
Import-Module ActiveDirectory

do{
    Clear-Host 
    Write-Host "=============================================================" -ForegroundColor Green
    Write-Host "============= AD Device Full Info Lookup Script =============" -ForegroundColor Green
    Write-Host "=============================================================" -ForegroundColor Green
    Write-Host "Maintained by: Carl Angelo Nievarez" -ForegroundColor Gray
    Write-Host "Developed on: April 30, 2025" -ForegroundColor Gray
    Write-Host "Repository   : https://github.com/aice09/AD-Management-Scripts" -ForegroundColor DarkCyan
    Write-Host ""
    Write-Host "DISCLAIMER:" -ForegroundColor Yellow
    Write-Host "This script is intended for internal use within Active Directory environments." -ForegroundColor DarkYellow
    Write-Host "It relies on Active Directory data and assumes administrative access." -ForegroundColor DarkYellow
    Write-Host "The author makes no guarantees regarding the accuracy or completeness" -ForegroundColor DarkYellow
    Write-Host "of the output. Use with caution in production environments." -ForegroundColor DarkYellow
    Write-Host "For issues, please visit the repository and open an issue." -ForegroundColor DarkYellow
    Write-Host ""

    # Ask for the remote domain controller
    $domainController = Read-Host "Enter the domain controller FQDN or IP of the remote domain (e.g., dc01.otherdomain.com)"

    # Ask if user wants to use alternate credentials
    $useCreds = Read-Host "Use alternate credentials? (Y/N)"
    if ($useCreds -match '^[Yy]') {
        $cred = Get-Credential
    } else {
        $cred = $null
    }

    # Ask for the device name
    $deviceName = Read-Host "Enter the device name to look up"

    try {
        if ($cred) {
            $computer = Get-ADComputer -Server $domainController -Credential $cred `
                        -Filter "Name -eq '$deviceName'" -Properties *
        } else {
            $computer = Get-ADComputer -Server $domainController `
                        -Filter "Name -eq '$deviceName'" -Properties *
        }

        if ($computer) {
            Write-Host "`n========== Device Details for '$deviceName' ==========" -ForegroundColor Cyan
            foreach ($property in $computer.PSObject.Properties) {
                Write-Host ("{0,-30}: {1}" -f $property.Name, $property.Value)
            }

            # Ask if user wants to export results
            $export = Read-Host "`nDo you want to export the results to CSV and TXT? (Y/N)"
            if ($export -match '^[Yy]') {
                $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
                $baseName = "DeviceDetails_${deviceName}_$timestamp"
                $downloads = Join-Path $env:USERPROFILE "Downloads"
                $csvPath = Join-Path $downloads "$baseName.csv"
                $txtPath = Join-Path $downloads "$baseName.txt"

                # Convert properties to flat object for export
                $flatObj = [PSCustomObject]@{}
                $computer.PSObject.Properties | ForEach-Object {
                    $flatObj | Add-Member -NotePropertyName $_.Name -NotePropertyValue $_.Value
                }

                # Export to CSV and TXT
                $flatObj | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
                $flatObj | Format-List | Out-String | Set-Content -Path $txtPath -Encoding UTF8

                Write-Host "`nFiles saved to:" -ForegroundColor Green
                Write-Host "CSV: $csvPath"
                Write-Host "TXT: $txtPath"
            }
        } else {
            Write-Host "Device '$deviceName' not found in $domainController." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
    # Prompt to search again or exit (with styling)
        Write-Host "`n==============================" -ForegroundColor DarkGray
        Write-Host "Do you want to search another device info? (Y/N)" -ForegroundColor Cyan
        Write-Host "==============================" -ForegroundColor DarkGray
        $repeat = Read-Host
} while ($repeat -match '^[Yy]')
