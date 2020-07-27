Add-Type -AssemblyName PresentationFramework

Function Get-FixedDisk {
    [CmdletBinding()]

    param(
        [parameter(Mandatory)]
        [string]$Computer
    )

    $DiskInfo = Get-WmiObject Win32_LogicalDisk -ComputerName $Computer -Filter 'DriveType=3'
    $DiskInfo
}

#Locate the XAML file
$xmalFile = "E:\MyGIT\PowerShell\powershell\Work Scripts\GUI\MainWindow.xaml"

#Create Window
$inputXML = Get-Content $xmalFile -Raw
$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace '<Win.*', '<Window'
[xml]$XMAL = $inputXML

#Read XAML
$reader = (New-Object System.Xml.XmlNodeReader $xmal)
try{
    $window = [Windows.Markup.XamlReader]::Load( $reader )
}
catch{
    Write-Warning $_.Exception
    throw
}

#Create variables based on form control names

$xmal.SelectNodes("//*[@Name]") | ForEach-Object {

    try{
        Set-Variable -Name "var_$($_.Name)" -Value $window.FindName($_.Name) -ErrorAction Stop
    }
    catch{
        throw
    }
}

Get-Variable var_*

$var_btnQuery.Add_Click( {
    #clear the result box
    $var_txtResults.Text = ""
        if ($result = Get-FixedDisk -Computer $var_txtComputer.Text) {
            foreach ($item in $result) {
                $var_txtResults.Text = $var_txtResults.Text + "DeviceID: $($item.DeviceID)`n"
                $var_txtResults.Text = $var_txtResults.Text + "VolumeName: $($item.VolumeName)`n"
                $var_txtResults.Text = $var_txtResults.Text + "FreeSpace: $($item.FreeSpace)`n"
                $var_txtResults.Text = $var_txtResults.Text + "Size: $($item.Size)`n`n"
            }
        }       
    })
 
 $var_txtComputer.Text = $env:COMPUTERNAME

$Null = $window.ShowDialog()