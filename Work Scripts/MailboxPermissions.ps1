# ============================================= Functions for Common Tasks ============================================#









function LeaveSession {
    param ()
    
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

    $answer = Read-Host "Please make a selection [?]"

    if ($answer -eq 'x') {
        Disconnect-ExchangeOnline
        exit
    }
}