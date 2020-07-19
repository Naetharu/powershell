# Import the System.Web type
Add-Type -AssemblyName 'System.Web'

#1 Get users from CSV file
$userList = Import-Csv -Path "C:\Users\Administrator\Desktop\starters\source\newuser.csv"

#2 Find just the Essex users from the list
$contractList = $userList |
    Where-Object {$_.Contract -eq "Essex"}

#3 Array to store created user objects for review
$createdUsers = @()
$failedUsers = @()

#4 Iterate thorough users and add them to AD
foreach($user in $contractList){
    $today = Get-Date
    $name = $user.name
    $surname = $user.surname
    
    #4.1 Check that the user name does not conflict (consider interactive options for this in future)
    if((Get-ADUser -Filter "(Givenname -eq '$name') -and (Surname -eq '$surname')")){
        #User name already taken - do not proceed and instead add user to failed array
        $failedUsers += $user
    }
    else {
        $accountname = "$name" + "." + "$surname"
        $accountname
        $password = "Magic123"
        $office = "Head office"
        $email = $accountname + "@company.com"
        $description = "Temp staff working in accounts"
        New-ADUser -Name $accountname -GivenName $name -Surname $surname -SamAccountName $accountname -DisplayName "$name $surname" -UserPrincipalName $email -Office $office -Description $description -HomeDirectory H:\\directories\$accountname -Path "OU=Office,OU=Domain Users,DC=ad,DC=naeth,DC=com" -AccountPassword(ConvertTo-SecureString -AsPlainText $password -Force) -Enabled $true
    }
}

