#1 Import the System.Web type from MS.net - we are going to use this to generate our passwords
Add-Type -AssemblyName 'System.Web'


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

    Write-Host "Once more 'round the Sun"
}

Write-Host "Break on through to the other side!"

