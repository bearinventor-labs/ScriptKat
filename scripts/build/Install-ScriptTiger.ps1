##### START FILE #####

# Name: Install-ScriptTiger.ps1
# Location: ScriptTiger\scripts\build\Install-ScriptTiger.ps1
# Purpose: Script
# File Type: ps1
# Author: Andrew Shroyer
# Description: Installer Script for the PowerShell Module ScriptTiger

# Access Requirements: Read-Only
# Configuration Requirements: None

### START SCRIPT ###  

function Install-ScriptTiger {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$Force,

        [Parameter(Mandatory = $true)]
        [switch]$PowerShell7
    )

    $date = (Get-Date -Format "yyyy-mm-dd_HHmmss")
    Start-Transcript -Path "..\..\logs\scripts\build\Install-ScriptTiger_$date.log" -IncludeInvocationHeader

    $failure = 0

    Clear-Host 

    Write-Host "[ ] - Initializing Function: 'Install-ScriptTiger'." -ForegroundColor DarkCyan

    # PowerShell 5 Installation Directories
    $powershelldir = @(
        "$env:USERPROFILE\Documents\WindowsPowerShell\Modules", # PRIMARY USER INSTALLATION
        "$env:ONEDRIVE\Documents\WindowsPowerShell\Modules", # ONEDRIVE USER INSTALLATION
        "$env:PROGRAMFILES\WindowsPowerShell\Modules", # SYSTEM INSTALLATION (REQUIRES ADMINISTRATIVE PRIVILEGES)
        "$env:WINDIR\System32\WindowsPowerShell\v1.0\Modules" # SYSTEM INSTALLATION (REQUIRES ADMINISTRATIVE PRIVILEGES)
    )

    # PowerShell 7 Installation Directories
    $powershell7dir = @(
        "$env:USERPROFILE\Documents\PowerShell\Modules", # PRIMARY USER INSTALLATION
        "$env:ONEDRIVE\Documents\PowerShell\Modules", # ONEDRIVE USER INSTALLATION
        "$env:PROGRAMFILES\PowerShell\7\Modules", # SYSTEM INSTALLATION (REQUIRES ADMINISTRATIVE PRIVILEGES)
        "$env:PROGRAMFILES\PowerShell\7-preview\Modules" # SYSTEM INSTALLATION (REQUIRES ADMINISTRATIVE PRIVILEGES)
        
    ) 
    
    # Pull All Files
    $installerFiles = Get-ChildItem -Path "$PSScriptRoot\..\..\..\ScriptTiger" -Recurse
    #Write-Debug $installerFiles

    # PowerShell 7 Installation
    if ($PowerShell7) {

        Write-Host "[i] - PowerShell 7 Found." -ForegroundColor DarkYellow

        # Check Access for ALL Directories for PowerShell 7, and then Start Installation
        foreach ($dir in $powershell7dir) {

            # Check Directories
            if (-not (Test-Path -Path $dir)) {
                try {
                    Write-Host "[i] - Attempting to Create Missing Directory '$dir'." -ForegroundColor DarkYellow

                    New-Item -ItemType Directory -Path $dir -ErrorAction SilentlyContinue
                }
                catch {
                    Write-Host "[!] - Failed to Create Missing Directory '$dir'." -ForegroundColor DarkRed
                }
            }

            # Unique Test Access File
            $testFile = Join-Path -Path $dir -ChildPath ("permtest_{0}.tmp" -f ([guid]::NewGuid().ToString()))
            
            try {
                # Create and Remove Test File for Access Test
                New-Item -Path $testFile -ItemType File -Force -ErrorAction Stop | Out-Null
                Remove-Item -Path $testFile -Force -ErrorAction Stop
                
                Write-Host "[#] - Access Granted for Directory '$dir'." -ForegroundColor DarkGreen

                try {
                    # TRY Robocopy First
                    try {
                        # Check Installation Directory
                        if (-not (Test-Path -Path "$dir\ScriptTiger")) {
                            New-Item -ItemType Directory -Path "$dir\ScriptTiger" -ErrorAction SilentlyContinue
                        }

                        # Robocopy Arguments
                        $roboArgs = @(
                            "$PSScriptRoot\..\..\..\ScriptTiger\", # Source Path
                            "$dir\ScriptTiger", # Destination Path
                            "/E", # Recursive Copy to Include Empty Directories
                            "/DCOPY:DAT", # Copy Directory Timestamps and Attributes
                            "/COPY:DAT", # Copy File Data, Attributes, and Timestamps
                            "/R:1", # Retry Once on Failure
                            "/W:1", # Wait 1 Second between Retries
                            "/XX", # Exclude Extra Files in Destination (for User Configurations and Settings)
                            "/V" # Show Progress
                        )

                        # Executable
                        Robocopy.exe @roboArgs

                        Write-Host "[#] - Installation Successful to Directory '$dir\ScriptTiger'." -ForegroundColor DarkGreen
                    }
                    catch {
                        Write-Host "[!] - Robocopy Installation Failed. Using Builtin PowerShell Copy-Item Cmdlet..." -ForegroundColor DarkRed

                        # FAIL to Copy-Item Installation
                        try {
                            # Check Installation Directory
                            if (-not (Test-Path -Path "$dir\ScriptTiger")) {
                                New-Item -ItemType Directory -Path "$dir\ScriptTiger" -ErrorAction SilentlyContinue
                            }
                            $installerFiles | ForEach-Object {
                                Copy-Item -Path "$_" -Destination "$dir\ScriptTiger" -Recurse -Force -ErrorAction Stop | Out-Null
                            }

                            Write-Host "[#] - Installation Successful to Directory '$dir\ScriptTiger'." -ForegroundColor DarkGreen
                        }
                        catch {
                            Write-Host "[!] - Installation to Directory '$dir\ScriptTiger' Failed!" -ForegroundColor DarkRed

                            if ($dir -eq $powershell7dir[0]) {
                                # User Directory Installation Failure
                                #Write-Host "[X] - General Installation Failure!" -ForegroundColor DarkRed -BackgroundColor White

                                # General Installation Failure
                                $failure = 1
                                $failmsg = $_
                                throw 
                            }
                        }
                    }
                }
                catch {
                    Write-Host "[!] - Installation to Directory '$dir\ScriptTiger' Failed!" -ForegroundColor DarkRed

                    if ($dir -eq $powershell7dir[0]) {
                        # User Directory Installation Failure
                        #Write-Host "[X] - General Installation Failure!" -ForegroundColor DarkRed -BackgroundColor White

                        # General Installation Failure
                        $failure = 1
                        $failmsg = $_
                        throw 
                    }
                }
            }
            catch {
                Write-Host "[i] - Access Denied for the Directory '$dir'." -ForegroundColor DarkYellow

                if ($dir -eq $powershell7dir[0]) {
                    # User Directory Access Failure
                    #Write-Host "[X] - General Access Failure!" -ForegroundColor DarkRed -BackgroundColor White

                    # General Access Failure
                    $failure = 2
                    $failmsg = $_
                    throw 
                }
            }
        }
    }

    # Check Access for ALL Directories for PowerShell 5, and then Start Installation
    foreach ($dir in $powershelldir) {

        # Check Directories
        if (-not (Test-Path -Path $dir)) {
                try {
                    Write-Host "[i] - Attempting to Create Missing Directory '$dir'." -ForegroundColor DarkYellow

                    New-Item -ItemType Directory -Path $dir -ErrorAction SilentlyContinue
                }
                catch {
                    Write-Host "[X] - Failed to Create Missing Directory '$dir'." -ForegroundColor DarkRed
                }
        }

        # Unique Test Access File
        $testFile = Join-Path -Path $dir -ChildPath ("permtest_{0}.tmp" -f ([guid]::NewGuid().ToString()))
            
        try {
                # Create and Remove Test File for Access Test
                New-Item -Path $testFile -ItemType File -Force -ErrorAction Stop | Out-Null
                Remove-Item -Path $testFile -Force -ErrorAction Stop
                
                Write-Host "[#] - Access Granted for Directory '$dir'." -ForegroundColor DarkGreen

                try {
                    # TRY Robocopy First
                    try {
                        # Check Installation Directory
                        if (-not (Test-Path -Path "$dir\ScriptTiger")) {
                            New-Item -ItemType Directory -Path "$dir\ScriptTiger" -ErrorAction SilentlyContinue
                        }

                        # Robocopy Arguments
                        $roboArgs = @(
                            "$PSScriptRoot\..\..\..\ScriptTiger\", # Source Path
                            "$dir\ScriptTiger", # Destination Path 
                            "/E", # Recursive Copy to Include Empty Directories
                            "/DCOPY:DAT", # Copy Directory Timestamps and Attributes
                            "/COPY:DAT",  # Copy File Data, Attributes, and Timestamps
                            "/R:1", # Retry Once on Failure
                            "/W:1", # Wait 1 Second between Retries
                            "/XX", # Exclude Extra Files in Destination (for User Configurations and Settings)
                            "/V" # Show Progress
                        )

                        # Executable
                        Robocopy.exe @roboArgs

                        Write-Host "[#] - Installation Successful to Directory '$dir\ScriptTiger'." -ForegroundColor DarkGreen
                    }
                    catch {
                        Write-Host "[i] - Robocopy Installation Failed. Using Builtin PowerShell Copy-Item Cmdlet..." -ForegroundColor DarkYellow

                        # FAIL to Copy-Item Installation
                        try {
                            # Check Installation Directory
                            if (-not (Test-Path -Path "$dir\ScriptTiger")) {
                                New-Item -ItemType Directory -Path "$dir\ScriptTiger" -ErrorAction SilentlyContinue
                            }
                            $installerFiles | ForEach-Object {
                                Copy-Item -Path "$_" -Destination "$dir\ScriptTiger" -Recurse -Force -ErrorAction Stop | Out-Null
                            }

                            Write-Host "[#] - Installation Successful to Directory '$dir\ScriptTiger'." -ForegroundColor DarkGreen
                        }
                        catch {
                            Write-Host "[X] - Installation to Directory '$dir\ScriptTiger' Failed!" -ForegroundColor DarkRed

                            if ($dir -eq $powershelldir[0]) {
                                # User Directory Installation Failure
                                Write-Host "[X] - General Installation Failure!" -ForegroundColor DarkRed -BackgroundColor White

                                # General Installation Failure
                                $failure = 1
                                $failmsg = $_
                                throw 
                            }
                        }
                    }
                }
                catch {
                    Write-Host "[X] - Installation to Directory '$dir\ScriptTiger' Failed!" -ForegroundColor DarkRed

                    if ($dir -eq $powershelldir[0]) {
                        # User Directory Installation Failure
                        Write-Host "[X] - General Installation Failure!" -ForegroundColor DarkRed -BackgroundColor White

                        # General Installation Failure
                        $failure = 1
                        $failmsg = $_
                        throw 
                    }
                }
        }
        catch {
            Write-Host "[i] - Access Denied for the Directory '$dir'." -ForegroundColor DarkYellow

            if ($dir -eq $powershelldir[0]) {
                # User Directory Access Failure
                Write-Host "[X] - General Access Failure!" -ForegroundColor DarkRed -BackgroundColor White

                # General Access Failure
                $failure = 2
                $failmsg = $_
                throw 
            }
        }
    }
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

# Main Starter
try {
    Install-ScriptTiger -PowerShell7:(Check-PowerShell7) -ErrorAction Stop

    # Successful Exit
    Write-Host "[#] - Installation Finished Successfully." -ForegroundColor DarkGreen

    # Press Enter
    Read-Host -Prompt ":<-- Press Enter to Exit -->"
}
catch {
    # General Installation Error
    if ($failure -eq 1) {
            Write-Host "[X] - General Installation Failure!" -ForegroundColor DarkRed -BackgroundColor White
            Write-Error $failmsg

            # Press Enter
            Read-Host -Prompt ":<-- Press Enter to Exit -->"
    }
    # General Access Error
    elseif ($failure -eq 2) {
            Write-Host "[X] - General Access Failure!"  -ForegroundColor DarkRed -BackgroundColor White
            Write-Error $failmsg

            # Press Enter
            Read-Host -Prompt ":<-- Press Enter to Exit -->"
    }
    # General Function Error
    elseif ($failure -eq 3) {
        Write-Host "[X] - General Function Failure!"  -ForegroundColor DarkRed -BackgroundColor White
        Write-Error $failmsg

        # Press Enter
        Read-Host -Prompt ":<-- Press Enter to Exit -->"
    }
    # No Errors - Clean Exit and Installation
    else {
            Write-Host "[#] - Installation Finished Successfully." -ForegroundColor DarkGreen

            # Press Enter
            Read-Host -Prompt ":<-- Press Enter to Exit -->"
    }
}
finally {
    Stop-Transcript
    exit $failure
}

### END SCRIPT ###

##### END FILE #####
