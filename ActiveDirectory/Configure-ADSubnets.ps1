<#
.Synopsis
Configures Active Directory Subnets, associated within Sites
.Description
Configure-ADSubnets by obtaining subnets per availability zone from the AWS API,
and then creating them within the appropriate Site.
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
Write-Host "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [DEBUG] Configuring Subnets"
try {
    Write-Verbose "Obtaining Region"
    $region = (Invoke-RestMethod http://169.254.169.254/latest/dynamic/instance-identity/document).region

    Write-Verbose "Adding ZoneA Subnets to Site ZoneA"
    Get-EC2Subnet -Filter @( @{Name = 'vpc-id'; Values = $VpcId}; @{Name = 'availabilityZone'; Values = $ZoneA} ) |
    Select-Object CidrBlock, @{Name="Description";Expression={$_.tags | where key -eq "Name" | select Value -expand Value}} |
    ForEach-Object { New-ADReplicationSubnet -Name $_.CidrBlock -Description $_.Description -Location $region -Site ZoneA }
    Write-Host "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [DEBUG] ZoneA Subnets added to to Site ZoneA"

    if ($MultiZone) {
        Write-Verbose "Adding ZoneB Subnets to Site ZoneB"
        Get-EC2Subnet -Filter @( @{Name = 'vpc-id'; Values = $VpcId}; @{Name = 'availabilityZone'; Values = $ZoneB} ) |
        Select-Object CidrBlock, @{Name="Description";Expression={$_.tags | where key -eq "Name" | select Value -expand Value}} |
        ForEach-Object { New-ADReplicationSubnet -Name $_.CidrBlock -Description $_.Description -Location $region -Site ZoneB }
        Write-Host "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [DEBUG] ZoneB Subnets added to to Site ZoneB"
    }
    else {
        Write-Verbose "Adding ZoneB Subnets to Site ZoneA"
        Get-EC2Subnet -Filter @( @{Name = 'vpc-id'; Values = $VpcId}; @{Name = 'availabilityZone'; Values = $ZoneB} ) |
        Select-Object CidrBlock, @{Name="Description";Expression={$_.tags | where key -eq "Name" | select Value -expand Value}} |
        ForEach-Object { New-ADReplicationSubnet -Name $_.CidrBlock -Description $_.Description -Location $region -Site ZoneA }
        Write-Host "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [DEBUG] ZoneB Subnets added to to Site ZoneA"
    }
}
catch {
    Write-Warning "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [WARNING] ZoneB Subnets could not be added to Site, Error $_.Exception.Message"
}
