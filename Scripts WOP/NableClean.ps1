$session = New-PSSession -ComputerName ukrjc_47ygn13 -Credential "keku.local\admin.jamesb" 

Invoke-Command -Session $session -ScriptBlock {

    #Remove the XML files
    try{
        Remove-Item "C:\Program Files (x86)\N-able Technologies\NcentralAsset.xml" -WhatIf
    }
    catch{
        Write-Host "Unable to delete C:\Program Files (x86)\N-able Technologies\NcentralAsset.xml"
        Write-Host "This file may not exist"
    }
    
    try{
        Remove-Item "C:\Windows\Temp\NcentralAsset.xml" -WhatIf
    }
    catch{
        Write-Host "Unable to delete C:\Windows\Temp\NcentralAsset.xml"
        Write-Host "This file may not exist"
    }

    #Remove the Reg Key
    try{
        set-location -path HKLM:\SOFTWARE\'N-able Technologies'
        Get-ChildItem
        Remove-Item -path HKLM:\SOFTWARE\'N-able Technologies'\NcentralAsset -Recurse -WhatIf
    }
    catch{
        Write-Host "Unable to remove registary key"
        Write-Host "This key may not exist"
    }

    #Remove the WMI entry
    try{
        Remove-WmiObject -Class "NcentralAssetTag" -Namespace "root\cimv2\NcentralAsset" -Whatif
    }
    catch{
        Write-Host "Unable to WIM class"
        Write-Host "This class may not exist"
    }

    #Uninstall the software
}

# =================== THIS PART WORKS =========================================#



