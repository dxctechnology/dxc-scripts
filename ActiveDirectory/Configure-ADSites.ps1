<#
.Synopsis
Configures Active Directory Sites, including a Site Link.
.Description
Configure-ADSites changes the name of the default Site to ZoneA, then optionally
creates a second site for ZoneB, along with a Site Link.
groups.
.Parameter VpcId
The VPC ID
.Parameter ZoneA
The first availabliity zone.
.Parameter ZoneB
The second availabliity zone.
.Parameter MultiZone
A boolean to indicate if multi-zone should be configured.
.Notes
    Author: Michael Crawford
 Copyright: 2017 by DXC.technology
          : Permission to use is granted but attribution is appreciated
#>
[CmdletBinding()]
param (
    [string]
    [Parameter(Position=0, Mandatory=$true)]
    $VpcId,

    [string]
    [Parameter(Position=1, Mandatory=$true)]
    $ZoneA,

    [string]
    [Parameter(Position=2, Mandatory=$true)]
    $ZoneB,

    [switch]
    $MultiZone
)

Write-Host
Write-Host "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [DEBUG] Configuring Sites"
try {
    Get-ADObject -SearchBase (Get-ADRootDSE).ConfigurationNamingContext -filter {Name -eq 'Default-First-Site-Name'} | Rename-ADObject -NewName ZoneA
    Write-Host "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [DEBUG] Site Default-First-Site-Name renamed to ZoneA"
}
catch {
    Write-Warning "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [WARNING] Site Default-First-Site-Name could not be renamed to ZoneA, Error $_.Exception.Message"
}

if ($MultiZone) {
    try {
        New-ADReplicationSite ZoneB
        Write-Host "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [DEBUG] Site ZoneB created"
    }
    catch {
        Write-Warning "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [WARNING] Site ZoneB could not be created, Error $_.Exception.Message"
    }

    Write-Host "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [DEBUG] Configuring SiteLink"
    try {
        Get-ADObject -SearchBase (Get-ADRootDSE).ConfigurationNamingContext -filter {Name -eq 'DEFAULTIPSITELINK'} | Rename-ADObject -NewName 'ZoneA-ZoneB'
        Write-Host "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [DEBUG] SiteLink DEFAULTIPSITELINK renamed to ZoneA-ZoneB"
    }
    catch {
        Write-Warning "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [WARNING] SiteLink DEFAULTIPSITELINK could not be renamed to ZoneA-ZoneB, Error $_.Exception.Message"
    }

    try {
        Get-ADReplicationSiteLink -Filter {SitesIncluded -eq "ZoneA"} | Set-ADReplicationSiteLink -SitesIncluded @{add='ZoneB'} -ReplicationFrequencyInMinutes 15 -Replace @{'options'=1}
        Write-Host "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [DEBUG] SiteLink ZoneA-ZoneB configured"
    }
    catch {
        Write-Warning "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [WARNING] SiteLink ZoneA-ZoneB could not be configured, Error $_.Exception.Message"
    }
}
