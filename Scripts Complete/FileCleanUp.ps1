
#1 Import list of users to remove.
$leavers = Import-CSV -Path "C:\Users\Administrator\Desktop\DataClean\source\driveUsers.csv"

$failLog = @()
$successLog = @()

#2 Test to see if each user exists before proceeding

foreach ($user in $leavers){

    $name = $user.userName
    $surname = $user.userSurname
    $fullName = $name

    if(!($surname -eq "none"))
    {
        $fullName = $fullname + "." + $surname
    }
    
    if (!(Get-ADUser -Filter "((Givenname -eq '$name') -and (Surname -eq '$surname'))")){   
        $changeFail = [PSCustomObject]@{
            $name = $user
            $reason = "User does not exist in AD"
        }
        $failLog += $changeFail
    }
    else{
        try{
            remove-Item -Path "C:\Users\Administrator\Desktop\FolderTests\$fullName" -Force
        }
        catch{
            $changeFail = [PSCustomObject]@{
                name = $user
                reason = "Failed in attempt to change records"
            }
            $failLog += $changeFail
        }

        $test = Get-Content -Path "C:\Users\Administrator\Desktop\FolderTests\$fullName" -ErrorAction SilentlyContinue

        if($test){
            $changeFail = [PSCustomObject]@{
                name = $user
                reason = "No error thrown but folder still in place"
            }
            $failLog += $changeFail
        }
        else{
            $changeSuccess = [PSCustomObject]@{
                name = $user
                reason = "Removal complete and checks confirmed"
            }
            $successLog += $changeSuccess
        }
    }
    
} #end of foreach

$failLog | Export-CSV -Path "C:\Users\Administrator\Desktop\DataClean\logs\failLog.csv"
$successLog | Export-CSV -Path "C:\Users\Administrator\Desktop\DataClean\logs\successLog.csv"

Read-Host "Press any key to exit"