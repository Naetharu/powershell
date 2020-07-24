# ============================================= Functions for Common Tasks ============================================#

# -------------- Calender Permission Issues --------------- #
function checkCalendar {
    param()
    $email = Read-Host "Enter the email address: "
    Get-EXOMailboxFolderPermission -Identity $($email + ":\calendar")
}

function removeCalendarPermission {
    param()
    $hostUser = Read-Host "Enter the email address for the primary account: "
    $guestUser = Read-Host "Enter the email address for the the delegate you wish to remove: "

    Remove-MailboxFolderPermission -Identity $($hostUser + ":\calendar") -User $guestUser
}

function addCalendarPermission {
    param()
    $hostUser = Read-Host "Enter the email address for the primary account: "
    $guestUser = Read-Host "Enter the email address for the the delegate you wish to add as a delegate: "

    Add-MailboxFolderPermission -Identity $($hostUser + ":\Calendar") -User $guestUser -AccessRights Editor -SharingPermissionFlags Delegate
}

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
            1 { checkCalendar ; break }
            2 { removeCalendarPermission ; break }
            3 { addCalendarPermission; break }
            'x' {
                $check = $false 
                Write-Host "Option Four"; 
            }
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