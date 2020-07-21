#1 Import the System.Web type from MS.net - we are going to use this to generate our passwords
Add-Type -AssemblyName 'System.Web'

#2 Loop with break condition.
while($true){
    #2 Ask the engineer for the user account name
    $name = Read-Host -Prompt "Please Enter the users first name"
    $surname = Read-Host -Prompt "Please Enter the users surname name"

    #2.1 Trim any excess white space
    $name = $name.Trim()
    $surname = $surname.Trim()

    #2.2 Confirm input
    Write-Host "You have entered: "$name $surname
    $answer = Read-Host -Prompt "If this is correct please press [Y]. Else press any other key to start again."

    if($answer -eq "y"){break;} 

    #Debuggling line
    #Write-Host "Once more 'round the Sun"
}

#Debuggling line
#Write-Host "Break on through to the other side!"

#3 Locate the user in AD
$userAccount = Get-ADUser -Filter "(Givenname -eq '$name') -and (Surname -eq '$surname')"

#4 Reset the users password
$length = 10
$nonAlphaChars = 2
$password = [System.Web.Security.Membership]::GeneratePassword($length, $nonAlphaChars)


Set-ADAccountPassword -Identity $userAccount -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$password" -Force) -ChangePasswordAtLogon $true | Enable-ADAccount

#5 Print results
Write-Host "`The password has been changed successfully: `n" -ForegroundColor Red
Write-Host "The new password is: "$password
$password | Export-Csv "C:\Users\Administrator\Desktop\PWreset\results\success.csv"