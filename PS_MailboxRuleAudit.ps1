############################################
# Title: PS_MailboxRuleAudit
# Desc: Get list of server side mailbox rules
# LastMod: 20200118
# Author: TK (Edafio)
############################################

############################################
# DISCLAIMER: Use it an your own risk.
# Licensed under MIT License https://github.com/tsudo/scripts/blob/master/License.md
############################################

######################
# Variables Global
$users = (get-mailbox -resultsize unlimited).UserPrincipalName foreach ($user in $users)

######################
# SCRIPT

{Get-InboxRule -Mailbox $user | Select-Object MailboxOwnerID,Name,Description | Export-CSV C:\users.csv -NoTypeInformation -Append}

