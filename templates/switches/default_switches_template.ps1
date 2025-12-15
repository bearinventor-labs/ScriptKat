# Invalid Response
Default {
    Write-Host "[!] - Invalid Response!" -ForegroundColor Red
    Read-Host -Prompt ":<-- Press ENTER to Continue -->"
    
    # <-- Insert the Current Menu Function -->
    main_menu
            
    # <-- This prompt leads into the while ($true) {} Loop. -->
    # <-- REMOVE IF NOT USING A LOOP -->
    $prompt = Read-Host
    
    continue
}
