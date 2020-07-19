
# Import the System.Web type
Add-Type -AssemblyName 'System.Web'

#1 Get users from CSV file
$userList = Import-Csv -Path "C:\Users\Administrator\Desktop\leavers\source\testuser.csv"

#2 Find just the Essex users from the list
$contractList = $userList |
    Where-Object {$_.Contract -eq "Essex"}

$updatedUsers = @()

$failedUsers = @()

#3 Loop through each user and process their account
foreach($user in $contractList){
    $today = Get-Date
    $name = $user.name
    $surname = $user.surname

    # Check the date that the person is due to leave
    if((Get-ADUser -Filter "(Givenname -eq '$name') -and (Surname -eq '$surname')")){
        $leaveDate = [datetime]::ParseExact($user.'leave date', "dd/MM/yyyy", $null)
    }
    
    # Check if the person exists in AD and if their leave date is today or earlier before proceeding
    if(!(Get-ADUser -Filter "(Givenname -eq '$name') -and (Surname -eq '$surname')") -or ($leaveDate -gt $today)){
        $failedUsers += $user
    }else{
        $currentUser = Get-ADUser -Filter "(Givenname -eq '$name') -and (Surname -eq '$surname')" 

        $length = 16
        $nonAlphaChars = 8
        $password = [System.Web.Security.Membership]::GeneratePassword($length, $nonAlphaChars)

        # Debugging line to view password in plain text
        Write-Host "The password is $password" -ForegroundColor Cyan

        #3.1 - Change their password to a random value
        Set-ADAccountPassword -Identity $currentUser -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $password -Force)

        #3.2 - Disable their account
        $currentUser | Disable-ADAccount

        #3.3 - Move their account into the new OU
        Move-ADObject -Identity $currentUser -TargetPath "OU=Disabled Accounts,OU=Domain Users,DC=ad,DC=naeth,DC=com"

        #3.4 - Add a note to explain why this has been done
        Set-ADUser $currentUser -Replace @{info="$($currentUser.info) Account Disabled due to HR Reqest on $today"} -ErrorAction Ignore

        #3.5 - Log user as updated for export to .csv
        $updatedUsers += $user
    }
} 

# Print a list of all successful changes
Write-Host "`nAccounts that have been succesfully updated: `n" -ForegroundColor Green
$updatedUsers
$updatedUsers | Export-Csv -Path "C:\Users\Administrator\Desktop\leavers\results\success.csv" 

# Print a list of all accounts that failed
Write-Host "`nAccounts that have not been updated: `n" -ForegroundColor Red
$failedUsers
$failedUsers | Export-Csv -Path "C:\Users\Administrator\Desktop\leavers\results\fail.csv" 

Read-Host -Prompt "Press Enter to Exit"