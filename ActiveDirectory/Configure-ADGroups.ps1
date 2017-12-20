<#
.Synopsis
Creates Active Directory Groups
.Description
Configure-Groups reads a CSV file containing Active Directory Groups to create a set of groups
within the Users container in Active Directory.
.Parameter GroupsPath
The path to the Groups input CSV file. The default value is “.\Groups.csv”.
.Example
Configure-Groups
Creates Groups using the default ./Groups.csv file.
.Example
Configure-Groups -GroupsPath “C:\cfn\temp\CustomGroups.csv”
Creates Groups using a custom CSV file.
.Notes
    Author: Michael Crawford
 Copyright: 2017 by DXC.technology
          : Permission to use is granted but attribution is appreciated
#>
[CmdletBinding()]
param (
    [string]
    [Parameter(Position=0, Mandatory=$false)]
    $GroupsPath = ".\Groups.csv"
)

Write-Verbose "GroupsPath $GroupsPath"

$Groups = @()
If (Test-Path $GroupsPath) {
   $Groups = Import-CSV $GroupsPath
}
else {
   Throw  “-GroupsPath $($GroupsPath) is invalid.”
}

Write-Host
Write-Host "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [DEBUG] Adding Groups"
ForEach ($Group In $Groups) {
    Try {
        If (Get-ADGroup -Filter "Name -eq '$($Group.Name)'") {
            Write-Verbose "Group $($Group.Name) exists"
        }
        else {
            Write-Verbose "Group $($Group.Name) does not exist"
            New-ADGroup -Name $($Group.Name) `
                        -GroupScope $Group.GroupScope `
                        -GroupCategory $Group.GroupCategory `
                        -Description $($Group.Description)
            Write-Host "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [DEBUG] Group $($Group.Name) created"
        }
    }
    Catch {
        Write-Warning "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [WARNING] Group $($Group.Name) could not be created, Error $_.Exception.Message"
    }
}
