<#
    This script imports phone numbers and manager-names from CSV files and adds them to AD

    Author: James Bridge
    Creation Date: 08/08/2020
    Version: 1.0

    Important Note - All pathing is hard coded to my lab - you will need to set paths to your
    local enviroment before you can use this on your own DC.
#>



#Import CSV files to get the necessary data
$phoneList = Import-Csv -Path "C:\Users\Administrator\Desktop\ADCleanUp\source\PhoneList.csv"
$managerList = Import-Csv -Path "C:\Users\Administrator\Desktop\ADCleanUp\source\ManagerList.csv"

#Set counters so that we can report the total number of changes
$phoneCounter = 0
$managerCounter = 0

#Create CSV logging files
$phoneSuccessLog = @()
$phoneFailLog = @()
$managerSuccessLog = @()
$managerFailLog = @()

#Part 1 - For each user in AD check to see if they have a phone number and if not then change it
foreach ($phone in $phoneList) {

    # Set variables for clarity and ease of access
    $success = $true
    $failReason = ""
    $name = $phone.name
    $surname = $phone.surname
    $phoneNumber = $phone.'Phone Number'

    # Get user object based on first and last name
    $user = Get-ADUser -Filter "((Givenname -eq '$name') -and (Surname -eq '$surname'))" -Properties "telephoneNumber"    
    
    # Check user exists (if line 39 fails then $user will have a null value and so the if statement will return false)
    if ($user) {

        # Attempt to make the changes to phone number and handle any errors via the catch block
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

# Part 2 - same as part 1 but this time we address the line manager setting in AD
foreach ($user in $managerList) {

    # Start by setting the variables
    $success = $true
    $failReason = ""
    $name = $user.name
    $surname = $user.surname
    $managerName = $user.'manager name'
    $managerSurname = $user.'manager surname'
      
    # As above but this time we get both the user and the line manager object.
    $user = Get-ADUser -Filter "((Givenname -eq '$name') -and (Surname -eq '$surname'))" -Properties "Manager" 
    $manager = Get-ADUser -Filter "((Givenname -eq '$managerName') -and (Surname -eq '$managerSurname'))"
    
    # And here we test that both are non-null values before proceeding.
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

# Finally we push out our logs for both phone and line manager work so that we can audit our progress.
$phoneSuccessLog | Export-Csv -Path "C:\Users\Administrator\Desktop\ADCleanUp\logs\phoneSuccessLog.csv"
$phoneFailLog | Export-Csv -Path "C:\Users\Administrator\Desktop\ADCleanUp\logs\phoneFailLog.csv"

$managerSuccessLog | Export-Csv -Path "C:\Users\Administrator\Desktop\ADCleanUp\logs\managerSuccessLog.csv"
$managerFailLog | Export-Csv -Path "C:\Users\Administrator\Desktop\ADCleanUp\logs\managerFailLog.csv"

# And as a last touch we print a summery of how many accounts have been updated to the screen so we have quick glance view of our success.
Write-Host "Total Phone Numbers Set: "$phoneCounter
Write-Host "Total Managers added: "$managerCounter

Read-Host "Press Enter to Exit"
