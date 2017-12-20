<#
.Synopsis
Creates Active Directory Users, and optionally adds them to Groups
.Description
Configure-Users reads a CSV file containing Active Directory Users to create a set of users
within the Users container in Active Directory. Users can optionally be added to additional
groups.
.Parameter UsersPath
The path to the Users input CSV file. The default value is “.\Users.csv”.
.Parameter Password
A prefix to append to the per-user passwords contained in the Users CSV file.
.Example
Configure-Users
Creates Users using the default ./Users.csv file.
.Example
Configure-Users -UsersPath “C:\cfn\temp\CustomUsers.csv” -Password Safer
Creates Users using a custom CSV file, and a custom password prefix.
.Notes
    Author: Michael Crawford
 Copyright: 2017 by DXC.technology
          : Permission to use is granted but attribution is appreciated
#>
[CmdletBinding()]
param (
    [string]
    [Parameter(Position=0, Mandatory=$false)]
    $UsersPath = ".\Users.csv",

    [string]
    [Parameter(Position=1, Mandatory=$false)]
    $Password = "UnSafe"
)

Write-Verbose "UsersPath $UsersPath"
Write-Verbose "Password $Password"

$DNSRoot = (Get-ADDomain).DNSRoot
$Users = @()
If (Test-Path $UsersPath) {
   $Users = Import-CSV $UsersPath
}
else {
   Throw  “-UsersPath $($UsersPath) is invalid.”
}

Write-Host
Write-Host "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [DEBUG] Adding Users"
ForEach ($User In $Users) {
    Try {
        If (Get-ADUser -Filter "SamAccountName -eq '$($User.SamAccountName)'") {
            Write-Verbose "User $($User.Name) exists"
        }
        else {
            Write-Verbose "User $($User.Name) does not exist"
            $SecurePassword = ConvertTo-SecureString -String "$($Password)$($User.Password)" -AsPlainText -Force
            New-ADUser -Name $($User.Name) `
                       -SamAccountName $User.SamAccountName `
                       -UserPrincipalName "$($User.SamAccountName)@$($DNSRoot)" `
                       -GivenName $User.GivenName `
                       -Surname $User.Surname `
                       -AccountPassword $SecurePassword `
                       -ChangePasswordAtLogon $([System.Convert]::ToBoolean($User.ChangePasswordAtLogon)) `
                       -CannotChangePassword $([System.Convert]::ToBoolean($User.CannotChangePassword)) `
                       -PasswordNeverExpires $([System.Convert]::ToBoolean($User.PasswordNeverExpires)) `
                       -Enabled $([System.Convert]::ToBoolean($User.Enabled))`
                       -Description $($User.Description)
            Write-Host "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [DEBUG] User $($User.Name) created"
        }
    }
    Catch {
        Write-Warning "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [WARNING] User $($User.Name) could not be created, Error $_.Exception.Message"
    }

    $UserGroups = ($User.Groups).split(",")
    ForEach ($UserGroup in $UserGroups) {
        Try {
            Add-ADGroupMember -Identity $UserGroup $User.SamAccountName
            Write-Host "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [DEBUG] - User $($User.Name) added to Group $($UserGroup)"
        }
        Catch {
            Write-Warning "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [WARNING] - User $($User.Name) could not be added to Group $($UserGroup), , Error $_.Exception.Message"
        }
    }
}
