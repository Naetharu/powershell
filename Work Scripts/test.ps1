$check = $true

while ($check) {

    Write-Host "[1] Check mailbox permissions"
    Write-Host "[2] Remove mailbox permissions"
    Write-Host "[3] Add mailbox permissions"
    Write-Host "[x] Return to main menu"

    $answer = Read-Host "Please make a selection: "

    switch ($answer) {
        1 { checkCalendar ; break }
        2 { Write-Host "Option Two"; break }
        3 { Write-Host "Option Three"; break }
        x {
            $check
            $check = $false
            $check
            Write-Host "Option Four"; 
        }
    }

    Write-host $check
}
