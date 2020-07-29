# Import the System.Web type from MS.net - we are going to use this to generate our passwords
Add-Type -AssemblyName 'System.Web'

#1 Get users from CSV file
$userList = Import-Csv -Path "C:\Users\Administrator\Desktop\Starters\source\newuser.csv"

#2 Find just the Essex users from the list
$contractList = $userList |
    Where-Object {$_.Contract -eq "Essex"}

#3 Arrays to store created, failed and password objects for review
$createdUsers = @()
$failedUsers = @()
$defaultPasswords = @()

#4 Iterate thorough users and add them to AD
foreach($user in $contractList){
    $name = $user.name
    $surname = $user.surname
    $office = $user.office
    
    #4.1 Check that the user name does not conflict (consider interactive options for this in future)
    if((Get-ADUser -Filter "(Givenname -eq '$name') -and (Surname -eq '$surname')")){
        #User name already taken - do not proceed and instead add user to failed array
        $fail = [PSCustomObject]@{
            Name = "$name $surname"
            Reason = "Account name already exsists"
        }
        $failedUsers += $fail
    }
    else {
        # Create the account name
        $accountname = "$name" + "." + "$surname"

        # Generate a secure password
        $length = 8
        $nonAlphaChars = 1
        $password = [System.Web.Security.Membership]::GeneratePassword($length, $nonAlphaChars)

        # Create a custom PS object and store the password against the user name
        $userpasswordlog = [PSCustomObject]@{
            Name = $accountname
            Password = $password
        }

        # Add the custom object to the password array for procesing
        $defaultPasswords += $userpasswordlog

        # Find the correct OU for the new user
        $orgUnit = ""

        # Allocate OU based on office location
        Switch($office){
            "Field"{$orgUnit = "OU=Field Users,OU=Domain Users,DC=Naetharu,DC=local"; break }
            "Office"{$orgUnit = "OU=Office Users,OU=Domain Users,DC=Naetharu,DC=local"; break }
        }

        # Create the new user object based on the variables given - some more refinement needed here as we progress.
        $email = $accountname + "@company.com"
        $description = $user.description

        New-ADUser -Name $accountname -GivenName $name -Surname $surname -SamAccountName $accountname `
            -DisplayName "$name $surname" -UserPrincipalName $email -Office $office -Description $description `
                -HomeDirectory H:\\directories\$accountname -Path $orgUnit `
                    -AccountPassword(ConvertTo-SecureString -AsPlainText $password -Force) -Enabled $true

        # Check the AD account has been created.
        if(Get-ADUser -Identity $accountname){
            $createdUsers += $user
        }else {
            $fail = [PSCustomObject]@{
                Name = "$name $surname"
                Reason = "Account creation did not complete. Unknown error inside main if/else"
            }
            $failedUsers += $fail
        }
    }
}

# Print a list of all successful changes
Write-Host "`nAccounts that have been succesfully created: `n" -ForegroundColor Green
$createdUsers | Sort-Object -Descending | Format-Table -AutoSize
$createdUsers | Sort-Object -Descending | Export-Csv -Path "C:\Users\Administrator\Desktop\Starters\logs\success.csv" 

# Print a list of all accounts that failed
Write-Host "`nAccounts that have not been created: `n" -ForegroundColor Red
$failedUsers | Sort-Object -Descending | Format-Table -AutoSize
$failedUsers | Sort-Object -Descending | Export-Csv -Path "C:\Users\Administrator\Desktop\Starters\logs\fail.csv" 

# Print a list of default passwords and their associated account - final version email these via smtp to the user's line-manager?
Write-Host "`nDefault Password logs created: `n" -ForegroundColor Blue
$defaultPasswords | Sort-Object -Descending | Format-Table -AutoSize
$defaultPasswords | Sort-Object -Descending | Export-Csv -Path "C:\Users\Administrator\Desktop\Starters\logs\passwords.csv" 

Read-Host -Prompt "Press Enter to Exit"