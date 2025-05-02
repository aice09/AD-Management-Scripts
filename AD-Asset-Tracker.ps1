# =============================================================
# === Managed Devices Lookup Script ===========================
# =============================================================
# Description   : This script retrieves all AD-managed devices
#                 based on the sAMAccountName (badge number).
# Maintained by : Carl Angelo Nievarez
# Repository    : https://github.com/aice09/AD-Management-Scripts
# License       : MIT
# Developed on  : April 30, 2025
# Version       : 1.0.0
#
# DISCLAIMER:
# This script is intended for internal use within Active Directory environments.
# It relies on Active Directory data and assumes administrative access.
# The author makes no guarantees regarding the accuracy or completeness
# of the output. Use with caution in production environments.
# For issues, please visit the repository and open an issue.
# =============================================================

# Import Active Directory module
Import-Module ActiveDirectory

do {
    Clear-Host
    Write-Host "=============================================================" -ForegroundColor Green
    Write-Host "=============== Managed Devices Lookup Script ===============" -ForegroundColor Green
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


    # Prompt for the sAMAccountName (badge number)
    $targetSamAccountName = Read-Host "Enter the target sAMAccountName (badge number)"

    # Get user object
    $user = Get-ADUser -Filter "sAMAccountName -eq '$targetSamAccountName'" -Properties DistinguishedName
    if (!$user) {
        Write-Host "User $targetSamAccountName not found in Active Directory." -ForegroundColor Red
    }
    else {
        $userDN = $user.DistinguishedName

        # Get all devices managed by this user
        $computers = Get-ADComputer -Filter "ManagedBy -eq '$userDN'" -Properties *

        # Collect results
        $results = foreach ($computer in $computers) {
            $managedByName = ""
            if ($computer.ManagedBy) {
                $managerObj = Get-ADObject -Identity $computer.ManagedBy
                $managedByName = $managerObj.Name
            }

            $dnParts = $computer.DistinguishedName -split '(?<!\\),'
            $ouParts = $dnParts | Where-Object { $_ -notlike 'CN=*' }
            $ouFullPath = $ouParts -join ","

            [PSCustomObject]@{
                BadgeNumber       = $targetSamAccountName
                DeviceName        = $computer.Name
                ManagedBy         = $managedByName
                OU                = $ouFullPath
                FirstLogin        = $computer.whenCreated
                LastLogin         = $computer.LastLogonDate
                LastPasswordReset = $computer.PasswordLastSet
                Status            = if ($computer.Enabled) { "Enabled" } else { "Disabled" }
            }
        }

        # Display results
        if ($results.Count -eq 0) {
            Write-Host "No devices found managed by $targetSamAccountName." -ForegroundColor Yellow
        } else {
            $results | Format-Table -AutoSize

            # Ask if user wants to export
            $exportChoice = Read-Host "Do you want to export the results to CSV and TXT files? (Y/N)"
            if ($exportChoice -match '^[Yy]') {
                $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
                $fileNameBase = "ManagedDevices_$targetSamAccountName" + "_$timestamp"
                $downloads = Join-Path $env:USERPROFILE "Downloads"

                $csvPath = Join-Path $downloads "$fileNameBase.csv"
                $results | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

                $txtPath = Join-Path $downloads "$fileNameBase.txt"
                $results | Format-Table -AutoSize | Out-String | Set-Content -Path $txtPath -Encoding UTF8

                Write-Host "`nFiles saved to:" -ForegroundColor Green
                Write-Host "CSV: $csvPath"
                Write-Host "TXT: $txtPath"
            }
        }
    }

    # Prompt to search again or exit (with styling)
    Write-Host "`n==============================" -ForegroundColor DarkGray
    Write-Host "Do you want to search another sAMAccountName? (Y/N)" -ForegroundColor Cyan
    Write-Host "==============================" -ForegroundColor DarkGray
    $repeat = Read-Host
} while ($repeat -match '^[Yy]')
