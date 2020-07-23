#1 Import the System.Web type from MS.net - we are going to use this to generate our

if (Test-Connection naetharu.local) {

    $adminName = Read-Host "Please enter your admin name"
    $adminName = "naetharu.local\$adminName"

    $session = New-PSSession -ComputerName DC01 -Credential $adminName -ErrorAction SilentlyContinue

    # Check that session has been established. If not close gracefully.
    if (-not($session)) {
        Write-Host "Session not established. Check your credentials and try again." -ForegroundColor Red
        Read-Host "Press Enter to Exit"
        return;
    }    

    Invoke-Command -Session $session -ScriptBlock {

        Add-Type -AssemblyName 'System.Web'

        #2 Loop with break condition.
        while ($true) {
            #2 Ask the engineer for the user account name
            $name = Read-Host -Prompt "Please Enter the users first name" 
            $surname = Read-Host -Prompt "Please Enter the users surname name"

            #2.1 Trim any excess white space
            $name = $name.Trim()
            $surname = $surname.Trim()

            #2.2 Confirm input
            Write-Host "You have entered: "$name $surname
            $answer = Read-Host -Prompt "If this is correct please press [Y]. Else press any other key to start again."

            if ($answer -eq "y") { break; } 
        }
        
        #3 Locate the user in AD
        $userAccount = Get-ADUser -Filter "(Givenname -eq '$name') -and (Surname -eq '$surname')"

        if (-not($userAccount)) {    
            Write-Host "Unable to locate account for user $name $surname" -ForegroundColor Red
            return;
        }    

        #4 Reset the users password
        #4.1 Generate a new password
        $length = 8
        $nonAlphaChars = 1
        $password = [System.Web.Security.Membership]::GeneratePassword($length, $nonAlphaChars)

        #4.2 Store the password in a custom PS object
        $pwlog = [PSCustomObject]@{
            Name     = $userAccount
            Password = $password
        }

        #4.3 Reset the password and unlock the account
        try {
            Set-ADAccountPassword -Identity $userAccount -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$password" -Force)
            Unlock-ADAccount -Identity $userAccount 
            Set-ADUser -Identity $userAccount -ChangePasswordAtLogon:$true
        }
        catch {
            Write-Host "Failed while updating password." -ForegroundColor Red
            $test = "testing"
            $test | Export-Csv -Path "C:\Users\Administrator\Desktop\PWReset Error Logs\error.csv"
            return;
        }
        
        #5 Print results
        Write-Host "`The password has been changed successfully: `n" -ForegroundColor Red
        Write-Host "The new password is: "$password
        $pwlog | Export-Csv -path "C:\Users\Administrator\Desktop\PWRest\logs\success.csv"
    }
    Read-Host "Press enter to exit"
}
else {
    Write-Host "Connection to your domain failed - please ensure you are on domain or connected to the VPN"
}