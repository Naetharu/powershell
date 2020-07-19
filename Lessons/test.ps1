#1 Get users from CSV file
$userList = Import-Csv -Path "C:\Users\Administrator\Desktop\leavers\testuser.csv"

#2 Find just the Essex users from the list
$essexUserList = $userList |
    Where-Object {$_.Contract -eq "Essex"}

#3 Loop through each user and process their account
foreach($user in $essexUserList){
    $today = Get-Date
    $name = $user.name
    $surname = $user.surname
    $currentUser = Get-ADUser -Filter "(Givenname -eq '$name') -and (Surname -eq '$surname')" 

    #3.1 - Change their password to a random value
    Set-ADAccountPassword -Identity $currentUser -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "Magic_Door22" -Force)

    #3.2 - Disable their account
    $currentUser | Disable-ADAccount

    #3.3 - Move their account into the new OU
    Move-ADObject -Identity $currentUser -TargetPath "OU=Disabled Accounts,OU=Domain Users,DC=ad,DC=naeth,DC=com"

    #3.4 - Add a note to explain why this has been done
    Set-ADUser $currentUser -Replace @{info="$($currentUser.info) Account Disabled due to HR Reqest on $today"} 
}











