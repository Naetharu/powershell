# Import the System.Web type from MS.net - we are going to use this to generate our passwords
Add-Type -AssemblyName 'System.Web'

#1 Get users from CSV file
$userList = Import-Csv -Path "C:\Users\Administrator\Desktop\Leavers\source\testuser.csv"

#2 Find just the Essex users from the list
$contractList = $userList |
    Where-Object {$_.Contract -eq "Essex"}

$updatedUsers = @()
$failedUsers = @()

#3 Loop through each user and process their account
foreach($user in $contractList){
    $name = $user.name
    $surname = $user.surname
    $today = Get-Date
    $leaveDate = [datetime]::ParseExact($user.'leave date', "dd/MM/yyyy", $null)


    # Check the date that the person is due to leave - Need to look to change this - no need to query AD on this point
    #if((Get-ADUser -Filter "(Givenname -eq '$name') -and (Surname -eq '$surname')")){
       # Write-Host $user.'Leave Date'
   
    #}
    
    # Check if the person exists in AD and if their leave date is today or earlier before proceeding
    if(!(Get-ADUser -Filter "(Givenname -eq '$name') -and (Surname -eq '$surname')")){
        $faillog = [PSCustomObject]@{
            Name = "$name $surname"
            Message = "Failed to find AD entry for this user name"
        }

        $failedUsers += $faillog

    }elseIf($today -lt $leaveDate ){

        $faillog = [PSCustomObject]@{
            Name = "$name $surname"
            Message = "User leave date is the future"
        }

        $failedUsers += $faillog

    }else{
        $currentUser = Get-ADUser -Filter "(Givenname -eq '$name') -and (Surname -eq '$surname')" 

        $length = 16
        $nonAlphaChars = 8
        $password = [System.Web.Security.Membership]::GeneratePassword($length, $nonAlphaChars)

        #3.1 - Change their password to a random value
        try{
            Set-ADAccountPassword -Identity $currentUser -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $password -Force)
        }catch{
            $faillog = [PSCustomObject]@{
                Name = $currentUser
                Message = "Failed attempt to update user password."
            }
        }

        #3.2 - Disable their account
        try{
            $currentUser | Disable-ADAccount
        }catch{
            $faillog = [PSCustomObject]@{
                Name = $currentUser
                Message = "Failed to disable user account."
            }
        }

        #3.3 - Add a note to the account to explain why it has been disabled.
        try{
            Set-ADUser $currentUser -Replace @{info="$($currentUser.info) Account Disabled due to HR Reqest on $today"}
        }catch{
            $faillog = [PSCustomObject]@{
                Name = $currentUser
                Message = "Failed to update user info notes."
            }
        }

        #3.4 - Move their account into the new OU
        try{
            Move-ADObject -Identity $currentUser -TargetPath "OU=Disabled Users,OU=Domain Users,DC=Naetharu,DC=local"
        }catch{
            $faillog = [PSCustomObject]@{
                Name = $currentUser
                Message = "Failed move account to disabled users OU."
            }
        }

        #3.5 - Log user as updated for export to .csv
        $updatedUsers += $user
    }
} 

# Print a list of all successful changes
Write-Host "`nAccounts that have been succesfully updated: `n" -ForegroundColor Green
$updatedUsers | Sort-Object -Descending | Format-Table -AutoSize
$updatedUsers | Sort-Object -Descending | Export-Csv -Path "C:\Users\Administrator\Desktop\Leavers\logs\success.csv" 

# Print a list of all accounts that failed
Write-Host "`nAccounts that have not been updated: `n" -ForegroundColor Red
$failedUsers | Sort-Object -Descending | Format-Table -AutoSize
$failedUsers | Sort-Object -Descending | Export-Csv -Path "C:\Users\Administrator\Desktop\Leavers\logs\fail.csv" 

Read-Host -Prompt "Press Enter to Exit"