#Import CSV files to get the necessary data
$phoneList = Import-Csv -Path "C:\Users\Administrator\Desktop\ADCleanUp\PhoneList.csv"
$managerList = Import-Csv -Path "C:\Users\Administrator\Desktop\ADCleanUp\managerList.csv"

#Set counters so that we can report the total number of changes
$phoneCounter = 0
$managerCounter = 0

#Create CSV logging files


#Part 1 - For each user in AD check to see if they have a phone number and if not then change it
foreach ($phone in $phoneList) {
    $name = $phone.name
    $surname = $phone.surname
    $phoneNumber = $phone.'Phone Number'

    $user = Get-ADUser -Filter "((Givenname -eq '$name') -and (Surname -eq '$surname'))" -Properties "telephoneNumber"    
    
    if ($user) {
        try {
            Set-ADUser -Identity $user -Replace @{telephoneNumber = $phoneNumber }
            $phoneCounter ++
        }
        catch {
            Write-Host "Failed Attempt to set ADUser telephone number."
        }
    }
    else {
        Write-Host "Unable to locate user $name $surname from the phone list in AD."
    }
}

#Part 2 = For each user in AD add in the user's line manager
foreach ($user in $managerList) {
    $name = $user.name
    $surname = $user.surname
    $managerName = $user.'manager name'
    $managerSurname = $user.'manager surname'
  
    $user = Get-ADUser -Filter "((Givenname -eq '$name') -and (Surname -eq '$surname'))" -Properties "Manager" 
    $manager = Get-ADUser -Filter "((Givenname -eq '$managerName') -and (Surname -eq '$managerSurname'))"

    if ($user -and $manager) {
        try {
            Set-ADUser -Identity $user -Replace @{manager = $manager.distinguishedName }
            $managerCounter ++
        }
        catch {
            Write-Host "Failed attempt to Set-ADUser manager"
        }
    }
    else {
        if (!($manager -and $manager)) {
            Write-Host "Unable to locate both user $name $surname and manager $managerName $managerSurname details in AD"
        }
        elseif (!$user) {
            Write-Host "Unable to locate user details $name $surname details in AD"
        }
        else {
            Write-Host "Unable to locate manager details $managerName $managerSurname details in AD"
        }
    }
}

Write-Host "Total Phone Numbers Set: "$phoneCounter

Write-Host "Total Managers added: "$managerCounter

Read-Host "Press Enter to Exit"
