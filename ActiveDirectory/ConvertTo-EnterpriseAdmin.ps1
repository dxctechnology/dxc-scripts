[CmdletBinding()]
param(
    [string[]]
    [Parameter(Position=0)]
    $Groups = @('domain admins','schema admins','enterprise admins'),

    [string[]]
    [Parameter(Mandatory=$true, Position=1)]
    $Members
)

Write-Host
Write-Host "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [DEBUG] Converting $($Members)  to Enterprise Admins"

$Groups | ForEach-Object{
    Add-ADGroupMember -Identity $_ -Members $Members
}
