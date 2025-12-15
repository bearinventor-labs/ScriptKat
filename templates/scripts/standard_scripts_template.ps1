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

# <-- PLEASE CHANGE THE VERB-NOUN FUNCTION NAME!!! -->

function Verb-Noun {

    # <-- This block below is for any parameters you may want. Please keep the below as a default. -->
    # <-- Add a comma after $ObjectVar. -->
    # <-- Then copy the entire parameter onto a new line below the comma (within the parentheses). -->
    # <-- Or... make your own parameter.  -->

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, HelpMessage = "Enter Help Information.")]
        [object]$ObjectVar
    )

    # <-- One last function name change... -->
    # <-- Everything else is for your script. -->
    # <-- Just do not delete the last bracket and comments! -->

    Clear-Host
    
    Write-Host "[ ] - Initialized Function: Verb-Noun" -ForegroundColor DarkCyan
    
    # <-- ADD YOUR CODE HERE -->
    
}

### END SCRIPT ###

##### END FILE #####
