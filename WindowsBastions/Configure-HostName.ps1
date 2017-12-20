[CmdletBinding()]
param (
    [string]
    [Parameter(Position=0, Mandatory=$true)]
    $ZoneA,

    [string]
    [Parameter(Position=1, Mandatory=$true)]
    $ZoneB,

    [string]
    [Parameter(Position=2, Mandatory=$true)]
    $HostNamePrefix
)

try {
    $ErrorActionPreference = "Stop"

    # Get zone
    $Zone = Invoke-RestMethod http://169.254.169.254/latest/meta-data/placement/availability-zone

    # Append HostName Instance and Zone Code
    if ($Zone -eq $ZoneA) {
        $HostName = $HostNamePrefix + "01a"
    }
    else {
        $HostName = $HostNamePrefix + "01b"
    }

    # Associate Public Address
    Write-Host
    Write-Host "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [DEBUG] Renaming Computer to $HostName"
    Rename-Computer -NewName $HostName -Restart
}
catch {
    Write-Verbose "$($_.exception.message)@ $(Get-Date)"
    $_ | Write-AWSQuickStartException
}
