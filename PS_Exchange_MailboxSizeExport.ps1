#       Author: Keith S. Crawford 
#       Twitter: @tsudo
#		Website: KeithCrawford.me
#		Git: https://github.com/tsudo
#       Date: 20161216
#       Description: All Mailbox Size Export from Exchange, sorted by Total Size Descending 2010/2013/2016.
#       Version: 1.1
#       Disclaimer: Use it an your own risk.

Get-Mailbox -Resultsize Unlimited | Get-MailboxStatistics | select DisplayName,Database,Totalitemsize,Totaldeleteditemsize | Sort-Object TotalItemSize -Descending | export-csv c:\temp\MailboxSize-$((Get-Date).ToString('yyyyMMdd')).csv -NoTypeInformation