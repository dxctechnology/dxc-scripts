[CmdletBinding()]
param(
    [string]
    $DomainName,

    [string]
    $UserName,

    [string]
    $Password
)

Write-Host
Write-Host "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [DEBUG] Joining Computer to Domain $($DomainName)"

try {
    $pass = ConvertTo-SecureString $Password -AsPlainText -Force
    $cred = New-Object System.Management.Automation.PSCredential -ArgumentList $UserName,$pass

    Add-Computer -DomainName $DomainName -Credential $cred -Restart -ErrorAction Stop
    Write-Host "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [DEBUG] Computer $env:ComputerName joined to Domain $($DomainName)"
}
catch {
    $_ | Write-AWSQuickStartException
}
