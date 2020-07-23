
# Import CSV file and extract AD users with relevant properties
Function locateUserList {
    param($path, $prop)

    $file = Import-Csv -path $path
    $result = @()

    foreach ($user in $file) {
        $name = $user.name
        $surname = $user.surname

        $user = Get-ADUser -Filter "((Givenname -eq '$name') -and (Surname -eq '$surname'))" -Properties $prop
        $result += $user
    }
    return $result
}

Function updateUserDetails {
    param($userList, $csvFile, $property)

    foreach ($user in $userList) {
        $activeProperty = $user.$property

        Set-ADUser -Identity $user -Replace @{ $property = $activeProperty }
    }

    
}

