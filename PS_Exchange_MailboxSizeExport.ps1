############################################
# Title: PS_Exchange_MailboxSizeExport
# Desc: Get list of Exchange Mailboxes and their Size
# LastMod: 20190320
# Author: Keith Crawford // @tsudo on Github & Twitter
############################################

############################################
# DISCLAIMER: Use it an your own risk.
# Licensed under MIT License https://github.com/tsudo/scripts/blob/master/License.md
############################################

######################
# Variables Global
$Now = Get-Date
$ResultFile = "C:\temp\ExchangeMailboxSize" + $Now.ToString("_yyyyMMdd_HH-mm-ss") + ".csv"

######################
# SCRIPT
Get-Mailbox -Resultsize Unlimited | Get-MailboxStatistics | select DisplayName,Database,Totalitemsize,Totaldeleteditemsize | Sort-Object TotalItemSize -Descending | export-csv $ResultFile -NoTypeInformation