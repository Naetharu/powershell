#Import CSV files to get the necessary data
$phoneList = Import-Csv -Path "C:\Users\Administrator\Desktop\ADCleanUp\source\PhoneList.csv"
$managerList = Import-Csv -Path "C:\Users\Administrator\Desktop\ADCleanUp\source\managerList.csv"

#Set counters so that we can report the total number of changes
$phoneCounter = 0
$managerCounter = 0

#Create CSV logging files
$phoneSuccessLog = @()
$phoneFailLog = @()
$managerSuccessLog = @()
$managerFailLog = @()


$
#Part 1 - For each user in AD check to see if they have a phone number and if not then change it
foreach ($phone in $phoneList) {
    $success = $true
    $failReason = ""
    $name = $phone.name
    $surname = $phone.surname
    $phoneNumber = $phone.'Phone Number'

    $user = Get-ADUser -Filter "((Givenname -eq '$name') -and (Surname -eq '$surname'))" -Properties "telephoneNumber"    
    
    if ($user) {
        try {
            Set-ADUser -Identity $user -Replace @{telephoneNumber = $phoneNumber }
            $phoneCounter ++

            #Log results
            $phoneSuccess = [PSCustomObject]@{
                Name  = "$name $surname"
                Phone = "$phoneNumber"
            }
            $phoneSuccessLog += $phoneSuccess

        }
        catch {
            Write-Host "Failed Attempt to set ADUser telephone number."
            $failReason = "Failed Attempt to set ADUser telephone number."
            $success = $false
        }
    }
    else {
        Write-Host "Unable to locate user $name $surname from the phone list in AD."
        $failReason = "Unable to locate user $name $surname from the phone list in AD."
        $success = $false
    }

    # If failed then log
    if (!$success) {
        $phoneFail = [PSCustomObject]@{
            Name   = "$name $surname"
            Phone  = "$phoneNumber"
            Reason = "$failReason"
        }
        $phoneFailLog += $phoneFail
    }
}


foreach ($user in $managerList) {
    $success = $true
    $failReason = ""
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
    
            #Log results
            $managerSuccess = [PSCustomObject]@{
                Name    = "$name $surname"
                Manager = "$managerName $managerSurname"
            }
            $managerSuccessLog += $managerSuccess
        }
        catch {
            Write-Host "Failed attempt to Set-ADUser manager"
            $failReason = "Failed attempt to Set-ADUser manager"
            $success = $false
        }
    }
    else {
        if (!($manager -and $manager)) {
            Write-Host "Unable to locate both user $name $surname and manager $managerName $managerSurname details in AD"
            $failReason = "Unable to locate both user $name $surname and manager $managerName $managerSurname details in AD"
            $success = $false
        }
        elseif (!$user) {
            Write-Host "Unable to locate user details $name $surname details in AD"
            $failReason = "Unable to locate user details $name $surname details in AD"
            $success = $false
        }
        else {
            Write-Host "Unable to locate manager details $managerName $managerSurname details in AD"
            $failReason = "Unable to locate manager details $managerName $managerSurname details in AD"
            $success = $false
        }
    }
    
    # If failed then log
    if (!$success) {
        $managerFail = [PSCustomObject]@{
            Name   = "$name $surname"
            Phone  = "$phoneNumber"
            Reason = "$failReason"
        }
        $managerFailLog += $managerFail
    }
}
#Part 2 = For each user in AD add in the user's line manager


$phoneSuccessLog | Export-Csv -Path "C:\Users\Administrator\Desktop\ADCleanUp\logs\phoneSuccessLog.csv"
$phoneFailLog | Export-Csv -Path "C:\Users\Administrator\Desktop\ADCleanUp\logs\phoneFailLog.csv"

$managerSuccessLog | Export-Csv -Path "C:\Users\Administrator\Desktop\ADCleanUp\logs\managerSuccessLog.csv"
$managerFailLog | Export-Csv -Path "C:\Users\Administrator\Desktop\ADCleanUp\logs\managerFailLog.csv"

Write-Host "Total Phone Numbers Set: "$phoneCounter
Write-Host "Total Managers added: "$managerCounter

Read-Host "Press Enter to Exit"
