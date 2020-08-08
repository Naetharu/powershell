<#  
    This script takes a text file that contains a list of user-names (name.lastname) and 
    converts it into a formatted csv file with a name and surname column. This is a useful
    pre-processing stage to allow easier manipulation of data inside other automation 
    scripts.

    Generally this should be run on a local computer to pre-process the data.
    
    Author: James Bridge
    Creation Date: 08/08/2020
    Version: 1.0
#>

# Import the text file
$leavers = Get-Content 'C:\Users\naeth\Desktop\Data\testRaw.txt'

# Create variables to contain logging results and the user names
$result = @()
$name = ""
$surname = ""

# Iterate through the list extracting each user name
foreach($user in $leavers){
    $dotSep = $user.indexOf(".")
    $secPart = $dotSep + 1
    $size = ($user.length - $dotSep) - 1

    # check if there is a dot-character inside the name. If so then break the name into first/surname. Else treat the whole
    # name as a first name and set the surname to a default of 'none'.
    if($dotSep -eq -1){
        $name = $user
        $surname = "none"
    }
    else {
        $name = $user.substring(0, $dotSep)
        $surname = $user.substring($secPart, $size)
    }
    
    # create a custom psobject that we can use to format the csv export.
    $formattedUser = [PSCustomObject]@{
        userName = $name
        userSurname = $surname
    }
  
    # add the new custom object to our $result array.
    $result += $formattedUser
}

# Print results to the screen for quick checking.
$result

# Generate the formatted csv file.
$result | Export-CSV -Path "C:\Users\naeth\Desktop\Data\driveUsers.csv"

Read-Host "Press any key"