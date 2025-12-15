##### START FILE #####

# Name: FileName
# Location: ScriptTiger\dir\filename.txt
# Purpose: Script, Document, Template, Image, Configuration, Setting
# File Type: ps1, psm1, psd1
# Author: Andrew Shroyer
# Description: Provide a copy template for many ScriptTiger Documents

# Access Requirements: Windows Active Directory Domain Admins Security Group, Read-Only
# Configuration Requirements: Test-PSVersion.ps1, Test-WritePermission.ps1

### START SCRIPT ###  

function Remove-ScriptTiger {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, HelpMessage = "Enter Help Information.")]
        [object]$ObjectVar
    )

    $date = (Get-Date -Format "yyyy-mm-dd_HHmmss")
    Start-Transcript -Path "..\..\logs\scripts\build\Remove-ScriptTiger_$date.log" -IncludeInvocationHeader

    Clear-Host
    
    Write-Host "[ ] - Initialized Function: 'Remove-ScriptTiger'." -ForegroundColor DarkCyan

    # PowerShell 5 Installation Directories
    $powershelldir = @(
        "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\ScriptTiger", # PRIMARY USER INSTALLATION
        "$env:ONEDRIVE\Documents\WindowsPowerShell\Modules\ScriptTiger", # ONEDRIVE USER INSTALLATION
        "$env:PROGRAMFILES\WindowsPowerShell\Modules\ScriptTiger", # SYSTEM INSTALLATION (REQUIRES ADMINISTRATIVE PRIVILEGES)
        "$env:WINDIR\System32\WindowsPowerShell\v1.0\Modules\ScriptTiger" # SYSTEM INSTALLATION (REQUIRES ADMINISTRATIVE PRIVILEGES)
    )

    # PowerShell 7 Installation Directories
    $powershell7dir = @(
        "$env:USERPROFILE\Documents\PowerShell\Modules\ScriptTiger", # PRIMARY USER INSTALLATION
        "$env:ONEDRIVE\Documents\PowerShell\Modules\ScriptTiger", # ONEDRIVE USER INSTALLATION
        "$env:PROGRAMFILES\PowerShell\7\Modules\ScriptTiger", # SYSTEM INSTALLATION (REQUIRES ADMINISTRATIVE PRIVILEGES)
        "$env:PROGRAMFILES\PowerShell\7-preview\Modules\ScriptTiger" # SYSTEM INSTALLATION (REQUIRES ADMINISTRATIVE PRIVILEGES)
        
    ) 

    # Main Menu Function
    main_menu
    
    $prompt = Read-Host 
    
    while ($true) {
        switch ($prompt) {
            "1" {
                # Just Me (1) Menu
                justme_menu

                # DEFAULT = no
                $prompt = Read-Host -Prompt "(Y/n)"

                while ($true) {
                    switch ($prompt) {
                        "Y" {
                            # Gather List of Installed Files
                            $installedFiles = @()
                            $installedFiles += Get-ChildItem -Path $powershelldir[0] -Recurse
                            $installedFiles += Get-ChildItem -Path $powershelldir[1] -Recurse
                            $installedFiles += Get-ChildItem -Path $powershell7dir[0] -Recurse
                            $installedFiles += Get-ChildItem -Path $powershell7dir[1] -Recurse

                            try {
                                Write-Host "[ ] - Removing ScriptTiger from User..." -ForegroundColor DarkCyan

                                # Goodbye
                                goodbye

                                # Uninstall Script Block
                                $removeBlock = {
                                    Remove-Module -Name "ScriptTiger" -Force -ErrorAction SilentlyContinue
                                    Uninstall-Module -Name "ScriptTiger" -Force -ErrorAction SilentlyContinue

                                    Remove-Item -Path $powershelldir[0] -Recurse -Force -ErrorAction SilentlyContinue # PowerShell 5 USERPROFILE
                                    Remove-Item -Path $powershelldir[1] -Recurse -Force -ErrorAction SilentlyContinue # PowerShell 5 ONEDRIVE
                                    Remove-Item -Path $powershell7dir[0] -Recurse -Force -ErrorAction SilentlyContinue # PowerShell 7 USERPROFILE
                                    Remove-Item -Path $powershell7dir[1] -Recurse -Force -ErrorAction SilentlyContinue # PowerShell 7 ONEDRIVE

                                    Write-Host "[#] - ScriptTiger Removed from User." -ForegroundColor DarkGreen
                                }
                                
                                # This cleans up the above block
                                $encodedCmd = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($removeBlock.ToString()))

                                # Executes the Uninstall in a New Process for complete Removal
                                Start-Process PowerShell.exe -ArgumentList "-EncodedCommand $encodedCmd" -ErrorAction Stop

                                # Exit
                                exit 0
                            }
                            catch {
                                Write-Host "[!] - Removal Failed!" -ForegroundColor Red

                                Read-Host -Prompt ":<-- Press ENTER to Continue -->"

                                continue
                            }
                        }
                        # Invalid Response
                        Default {
                            Write-Host "[!] - Invalid Response!" -ForegroundColor Red

                            Read-Host -Prompt ":<-- Press ENTER to Continue -->"

                            # Just Me (1) Menu
                            justme_menu

                            $prompt = Read-Host

                            continue
                        }
                    }
                }

            }
            # Quit
            "Q" {
                # Quit Menu
                quit_menu

                # DEFAULT = no
                $prompt = Read-Host -Prompt "(Y/n)"

                switch ($prompt) {
                    "Y" {
                        # Successful Exit
                        # NO TRANSCRIPT
                        exit 0
                    }
                    Default {
                        continue
                    }
                }
            }
            # Invalid Response
            Default {
                Write-Host "[!] - Invalid Response!" -ForegroundColor Red

                Read-Host -Prompt ":<-- Press ENTER to Continue -->"

                #Main Menu Function
                main_menu
                
                $prompt = Read-Host

                continue
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    ###Write-Host "------------------------------------------------" -ForegroundColor Cyan
    ###Write-Host "Are you sure you would like to remove ScriptTiger from your system?" -ForegroundColor Yellow
    ###Write-Host "WARNING: This WILL remove ScriptTiger from ALL locations including OneDrive, UserProfile, and System32." -ForegroundColor Red
}

function Check-PowerShell7 {
    $pwsh = Get-Command -Name pwsh
    if ($pwsh) {
        return $true
    }
    else {
        return $false
    }
}

function main_menu {
    Clear-Host 

    Write-Host ""
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "How would you like to remove ScriptTiger?" -ForegroundColor Cyan
    Write-Host "-----------------------" -ForegroundColor Cyan
    Write-Host "1. Just me (UserProfile and Personal OneDrive Installation Locations)" -ForegroundColor Cyan
    Write-Host "2. Just the system (System32 ONLY) - REQUIRES ADMINISTRATOR PRIVILEGES" -ForegroundColor Yellow
    Write-Host "A. System and me (UserProfile, Personal OneDrive, and System32) - REQUIRES ADMINISTRATOR PRIVILEGES" -ForegroundColor Red
    Write-Host "B. Back" -ForegroundColor Cyan
    Write-Host "Q. Quit" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
}

function quit_menu {
    Clear-Host 

    Write-Host ""
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "Are you sure you want to quit?" -ForegroundColor Yellow
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
}

function goodbye {
    Write-Host "      ____                 _ _                _ "
    Write-Host "     / ___| ___   ___   __| | |__  _   _  ___| |"
    Write-Host "    | |  _ / _ \ / _ \ / _` | '_ \| | | |/ _ \ |"
    Write-Host "    | |_| | (_) | (_) | (_| | |_) | |_| |  __/_|"
    Write-Host "     \____|\___/ \___/ \__,_|_.__/ \__, |\___(_)"
    Write-Host "                                   |___/        "
}

function justme_menu {
    Clear-Host

    Write-Host ""
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "Are you sure you would like to remove ScriptTiger from the following locations?" -ForegroundColor Yellow
    Write-Host "-----------------------" -ForegroundColor Cyan
    Write-Host "1. '$env:USERPROFILE\Documents\WindowsPowerShell\Modules\ScriptTiger'" -ForegroundColor Cyan
    Write-Host "2. '$env:ONEDRIVE\Documents\WindowsPowerShell\Modules\ScriptTiger'" -ForegroundColor Cyan
    Write-Host "3. '$env:USERPROFILE\Documents\PowerShell\Modules\ScriptTiger'" -ForegroundColor Cyan
    Write-Host "4. '$env:ONEDRIVE\Documents\PowerShell\Modules\ScriptTiger'" -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
}

### END SCRIPT ###

##### END FILE #####
