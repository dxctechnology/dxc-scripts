<#
.Synopsis
Configures the Windows TaskBar with useful Programs.
.Description
Configure-WindowsTaskBar configures the taskbar with programs useful to a Domain Admin
on a Domain Controller.
groups.
.Notes
    Author: Michael Crawford
 Copyright: 2017 by DXC.technology
          : Permission to use is granted but attribution is appreciated
#>
Write-Host
Write-Host "$(Get-Date -format 'yyyy-MM-dd HH:mm:ss,fff') [DEBUG] Configuring Windows TaskBar"

function Install-TaskBarPinnedItem() {
    [CMDLetBinding()]
    param (
        [Parameter(Mandatory=$true)] [System.IO.FileInfo] $Item
    )

    $Pinned = Get-ComFolderItem -Path $Item

    $Pinned.invokeverb('taskbarpin')
}

function Uninstall-TaskBarPinnedItem() {
    [CMDLetBinding()]
    param(
        [Parameter(Mandatory=$true)] [System.IO.FileInfo] $Item
    )

    $Pinned = Get-ComFolderItem -Path $Item

    $Pinned.invokeverb('taskbarunpin')
}

function Get-ComFolderItem() {
    [CMDLetBinding()]
    param(
        [Parameter(Mandatory=$true)] $Path
    )

    $ShellApp = New-Object -ComObject 'Shell.Application'

    $Item = Get-Item $Path -ErrorAction Stop

    if ($Item -is [System.IO.FileInfo]) {
        $ComFolderItem = $ShellApp.Namespace($Item.Directory.FullName).ParseName($Item.Name)
    }
    elseif ($Item -is [System.IO.DirectoryInfo]) {
        $ComFolderItem = $ShellApp.Namespace($Item.Parent.FullName).ParseName($Item.Name)
    }
    else {
        throw "Path is not a file nor a directory"
    }

    return $ComFolderItem
}

$PinnedItems = @(
    'C:\Program Files\Internet Explorer\iexplore.exe'
    'C:\Windows\System32\domain.msc'
    'C:\Windows\System32\dssite.msc'
    'C:\Windows\System32\dsa.msc'
    'C:\Windows\System32\dnsmgmt.msc'
    'C:\Windows\System32\certsrv.msc'
    'C:\Windows\System32\eventvwr.msc'
    'C:\Windows\System32\taskschd.msc'
    'C:\Windows\System32\mstsc.exe'
    'C:\Windows\System32\notepad.exe'
    'C:\Program Files\Windows NT\Accessories\wordpad.exe'
)

ForEach ($Item in $PinnedItems) {
    Uninstall-TaskBarPinnedItem -Item "$Item"
    Install-TaskBarPinnedItem   -Item "$Item"
}
