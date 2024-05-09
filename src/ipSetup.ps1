param(
    [string]$d = $(Join-Path -Path $PSScriptRoot -ChildPath "\assets\config.txt")
)

$config = Get-Content -Path $d
$hostname = $null
$windowsHostsPath = $null
$linuxHostsPath = $null
$linuxBashScript = $(Join-Path -Path $PSScriptRoot -ChildPath "/assets/ipSetupWSL.sh") -replace '\\', '/' -replace '^C:', '/mnt/c'

foreach ($line in $config) {
    if ($line.StartsWith('hostname=')) {
        $hostname = $line.Replace('hostname=', '')
    } elseif ($line.StartsWith('windowsHostsPath=')) {
        $windowsHostsPath = $line.Replace('windowsHostsPath=', '')
    } elseif ($line.StartsWith('linuxHostsPath=')) {
        $linuxHostsPath = $line.Replace('linuxHostsPath=', '')
    }
}

# Get the IP address
$NetConnection = Test-NetConnection
$InterfaceAlias = $NetConnection.InterfaceAlias
$Ip = $NetConnection.SourceAddress.IPAddress
Write-Output "Current IP: $Ip"
Write-Output "Current interface: $InterfaceAlias"

# Update Windows hosts file
$windowsHostsContent = Get-Content -Path $windowsHostsPath
$windowsLine = $windowsHostsContent | Where-Object { $_ -match $hostname }
$IpWin = ($windowsLine -split '\s+')[0]
Write-Output "Old $hostname IP in Windows: $IpWin"
$windowsHostsContent = $windowsHostsContent -replace "$IpWin", $Ip
[System.IO.File]::WriteAllLines($windowsHostsPath, $windowsHostsContent)

# Update Linux hosts file
Invoke-Expression -Command "wsl chmod +x $linuxBashScript"
Invoke-Expression -Command "wsl sudo bash $linuxBashScript $linuxHostsPath $hostname $Ip"

Write-Output "IP configuration setup completed"
Write-Output "Have a nice day"
