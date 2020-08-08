$leavers = Get-Content 'C:\Users\naeth\Desktop\Data\testRaw.txt'

$result = @()
$name = ""
$surname = ""

foreach($user in $leavers){
    $dotSep = $user.indexOf(".")
    $secPart = $dotSep + 1
    $size = ($user.length - $dotSep) - 1

    if($dotSep -eq -1){
        $name = $user
        $surname = "none"
    }
    else {
        $name = $user.substring(0, $dotSep)
        $surname = $user.substring($secPart, $size)
    }
    
    $formattedUser = [PSCustomObject]@{
        userName = $name
        userSurname = $surname
    }
  
    $result += $formattedUser
}

$result

$result | Export-CSV -Path "C:\Users\naeth\Desktop\Data\driveUsers.csv"

Read-Host "Press any key"