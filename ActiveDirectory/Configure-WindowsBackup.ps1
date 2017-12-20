<#
.Synopsis
Configures Windows Backup to backup Active Directory System State every 2 hours
.Description
Configure-WindowsBackup configures a scheduled job to backup windows system state every 2 hours.
.Notes
    To list backups, you can use:
    Get-WBBackupSet

    To confirm a backup worked
    Get-WinEvent -LogName Microsoft-Windows-Backup -FilterXPath "*[System[EventID=4]]"

    Author: Michael Crawford
 Copyright: 2017 by DXC.technology
          : Permission to use is granted but attribution is appreciated
#>
Write-Host
Write-Host "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [DEBUG] Configuring ScheduledJob for Windows SystemState Backup"

$Interval = (New-TimeSpan -Hours 2)
$Trigger = New-JobTrigger -Once -At (Get-Date).Date -RepeatIndefinitely -RepetitionInterval $Interval
$SystemStateBackup = Register-ScheduledJob -Name "System State Backup" -Trigger $Trigger -ScriptBlock {
    $Policy = New-WBPolicy
    Add-WBSystemState -Policy $Policy
    $BackupTarget = New-WBBackupTarget -VolumePath "D:"
    Add-WBBackupTarget -Policy $Policy -Target $BackupTarget
    Start-WBBackup -Policy $Policy

    #$BackupsBucket = backups-us-east-2-dxcp
    #$HostName = dxcue2caddc01a
    #Write-S3Object -Folder "D:\WindowsImageBackup\$HostName" -Recurse -BucketName $BackupsBucket -KeyPrefix $HostName\
}

# Or, you can remove setting -Trigger above, and add specific time triggers with this
# $BackupTimes = ("06:00", "08:00", "10:00", "12:00", "14:00", "16:00", "18:00")
# ForEach ($Time in $BackupTimes) {
#     $SystemStateBackup | Add-JobTrigger -trigger (New-JobTrigger -Daily -At $Time)
# }
