# ============================================= Functions for Common Tasks ============================================#

# -------------- Calender Permission Issues --------------- #
function calendarPermissions {
    param ()

    $check = $true

    while ($check) {

        Write-Host "[1] Check mailbox permissions"
        Write-Host "[2] Remove mailbox permissions"
        Write-Host "[3] Add mailbox permissions"
        Write-Host "[x] Return to main menu"

        $answer = Read-Host "Please make a selection: "

        switch ($answer) {
            1 { Write-Host "Option One"; break }
            2 { Write-Host "Option Two"; break }
            3 { Write-Host "Option Three"; break }
            4 { Write-Host "Option Four"; $check = $false }
        }
    }
}

# ============================================== Create Online Session ================================================#

# Disable PS Security Measures
Set-ExecutionPolicy Unrestricted

# Import Modules
Import-Module -Name MSOnline
Import-Module -Name ExchangeOnlineManagement
Import-Module -Name AzureAD

# Connect a PS session
Connect-ExchangeOnline

#=============================================== Options Menu for common tasks ========================================#
Write-Host "Welcome to Exchange Online - Choose your option from the following menu"

while ($true) {
    Write-Host "[1] Mailbox Permissions"
    Write-Host "[x] Exit the system"

    $answer = Read-Host "Please make a selection [?]"

    switch ($answer) {
        1 { calendarPermissions; break }
        x { Disconnect-ExchangeOnline; exit }
    }
}