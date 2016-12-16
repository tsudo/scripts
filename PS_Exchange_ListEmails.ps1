#       Author: Keith S. Crawford 
#       Twitter: @tsudo
#		Website: KeithCrawford.me
#		Git: https://github.com/tsudo
#       Date: 20161216
#       Description: All Mailbox Size Export from Exchange, sorted by Total Size Descending 2010/2013/2016.
#       Version: 1.1
#       Disclaimer: Use it an your own risk.
<#

.Requires -version 2 - Runs in Exchange Management Shell

.SYNOPSIS
.\AddresslistMemberReport.ps1 - It Can Display all the Address list and its members on a List

Or It can Export to a CSV file


Example 1

[PS] C:\>.\AddresslistMemberReport.ps1


Addresslist Member Report
----------------------------

1.Display in Exchange Management Shell

2.Export to CSV File

Choose The Task: 1

DisplayName                   Alias                         Primary SMTP address          Addresslist
-----------                   -----                         --------------------          -----------
test2 test2                   test2                         test2@Careexchange.in         \All Rooms
HONDA Room                    HONDAROOM                     Room@Careexchange.in          \All Rooms


Example 2

[PS] C:\>.\AddresslistMemberReport.ps1


Addresslist Member Report
----------------------------

1.Display in Exchange Management Shell

2.Export to CSV File

Choose The Task: 2

Enter the Path of CSV file (Eg. C:\ALmembers.csv): C:\Addresslistmembers.csv

.Author
Written By: Satheshwaran Manoharan

Change Log
V1.0, 08/04/2013 - Initial version
#>

Write-host "

Addresslist Member Report
----------------------------

1.Display in Exchange Management Shell

2.Export to CSV File" -ForeGround "Cyan"

#----------------
# Script
#----------------

Write-Host "               "

$number = Read-Host "Choose The Task"
$output = @()
switch ($number) 
{

1 {

$AllAL = Get-Addresslist

Foreach($AL in $allAL)

{

$Members = (Get-Recipient -RecipientPreviewFilter $al.RecipientFilter -ResultSize unlimited)

$Total = $Members.Count

$RemoveNull = $Total-1

For($i=0;$i -le $RemoveNull;$i++)

{

$userObj = New-Object PSObject

$userObj | Add-Member NoteProperty -Name "DisplayName" -Value $members[$i].Name
$userObj | Add-Member NoteProperty -Name "Alias" -Value $members[$i].Alias
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value $members[$i].PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Addresslist" -Value $AL
Write-Output $Userobj

}

}

;Break}

2 {

$CSVfile = Read-Host "Enter the Path of CSV file (Eg. C:\ALmembers.csv)" 

$AllAL = Get-addresslist

Foreach($AL in $allAL)

{

$Members = (Get-Recipient -RecipientPreviewFilter $al.RecipientFilter -ResultSize unlimited)

$Total = $Members.Count

$RemoveNull = $Total-1

For($i=0;$i -le $RemoveNull;$i++)

{

$userObj = New-Object PSObject

$userObj | Add-Member NoteProperty -Name "DisplayName" -Value $members[$i].Name
$userObj | Add-Member NoteProperty -Name "Alias" -Value $members[$i].Alias
$userObj | Add-Member NoteProperty -Name "RecipientType" -Value $members[$i].RecipientType
$userObj | Add-Member NoteProperty -Name "Primary SMTP address" -Value $members[$i].PrimarySmtpAddress
$userObj | Add-Member NoteProperty -Name "Addresslist" -Value $AL

$output += $UserObj  

}

$output | Export-csv -Path $CSVfile -NoTypeInformation

}



;Break}

Default {Write-Host "No matches found , Enter Options 1 or 2" -ForeGround "red"}

}