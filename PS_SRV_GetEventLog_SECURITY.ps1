############################################
# Title: PS_SRV_GetEventLog_SECURITY.ps1
# Desc: Get a .csv export of security logs from multiple computers
# LastMod: 20190711
# Author: Keith Crawford // @tsudo on Github & Twitter
############################################

############################################
# DISCLAIMER: Use it an your own risk.
# Licensed under MIT License https://github.com/tsudo/scripts/blob/master/LICENSE.md
############################################


############################################
# Credit: Original Script Author Michael Karsyan, FSPro Labs, eventlogxp.com (c) 2016
############################################

Set-Variable -Name EventAgeDays -Value 30     #we will take events for the latest 30 days
Set-Variable -Name CompArr -Value @("srv01", "srv02")   # replace it with your server names
Set-Variable -Name LogNames -Value @("Security")  # Checking app and system logs
Set-Variable -Name EntryTypes -Value @("FailureAudit", "SuccessAudit")  # Loading only Failure and SuccessAudit
Set-Variable -Name ExportFolder -Value "C:\temp\"


$el_c = @()   #consolidated error log
$now=get-date
$startdate=$now.adddays(-$EventAgeDays)
$ExportFile=$ExportFolder + "EvtLog_SEC" + $now.ToString("yyyyMMdd_HHmmss") + ".csv"  # we cannot use standard delimiteds like ":"

foreach($comp in $CompArr)
{
  foreach($log in $LogNames)
  {
    Write-Host Processing $comp\$log
    $el = get-eventlog -ComputerName $comp -LogName $log -After $startdate -EntryType $EntryTypes
    $el_c += $el  #consolidating
  }
}
$el_sorted = $el_c | Sort-Object TimeGenerated    #sort by time
Write-Host Exporting to $ExportFile
$el_sorted|Select EntryType, TimeGenerated, Source, EventID, MachineName, Message | Export-CSV $ExportFile -NoTypeInfo  #EXPORT
Write-Host Done!