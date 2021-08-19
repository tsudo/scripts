############################################
# Title: PS_365SecurityScript.ps1
# Desc: Get list of Domain (AD) Computers sorted by last login date.
# LastMod: 20200302
# Author: Keith Crawford // @tsudo on Github & Twitter
############################################

############################################
# DISCLAIMER: Use it an your own risk.
# Licensed under MIT License https://github.com/tsudo/scripts/blob/master/LICENSE.md
############################################

############################################
# INSTRUCTIONS
# Requires Run As Administrator
# Note: Blocking basic authentication will require this script to be used with the MFA connection in the remote powershell module if used again.
# You need to install the modules that are required for Azure AD, SharePoint Online, and Teams:
# Azure Active Directory V2
# SharePoint Online Management Shell
# Teams PowerShell Overview
############################################

############################################
# Instructions for Accounts with MFA Enabled
# 
# Actions inside of Exchange Online and the Security & Compliance Center will not run with this connection
# To get all actions to run there are 2 options, disable MFA on account and run script without MFA, or: 
# 
# - Open Internet Explorer(Must Use) and login to your tenant
# - Open the Exchange admin center (EAC). 
# - In the EAC, go to Hybrid > Setup and click the appropriate Configure button to download the Exchange Online Remote PowerShell Module for multi-factor authentication.
# - Install the module
# - Uncomment MFA connection and comment without MFA connection out
# - Open up the powershell window and navigate to the directory of the script and run it
############################################


<# -----------------------------------UNCOMMENT FOR MFA-----------------------------------

# Connect to O365 account with MFA (You will be asked to sign in multiple times)
$orgName= Read-Host "Please enter domain name (Use the one that matches your SharePoint)"
Connect-EXOPSSession
Connect-IPPSSession 
Connect-MsolService 
Connect-SPOService -Url https://$orgName-admin.sharepoint.com 
Import-Module MicrosoftTeams
Connect-MicrosoftTeams -Credential $credential

# -----------------------------------UNCOMMENT FOR MFA----------------------------------- #>


# --------------------------------COMMENT OUT if USING MFA--------------------------- 

# Connect to O365 account without MFA
$orgName= Read-Host "Please enter domain name (Use the one that matches your SharePoint)"
$credential = Get-Credential
Connect-MsolService -Credential $credential
Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
Connect-SPOService -Url https://$orgName-admin.sharepoint.com -credential $credential
$exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://outlook.office365.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $exchangeSession -DisableNameChecking -AllowClobber
$SccSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri "https://ps.compliance.protection.outlook.com/powershell-liveid/" -Credential $credential -Authentication "Basic" -AllowRedirection
Import-PSSession $SccSession -Prefix cc -DisableNameChecking -AllowClobber

Import-Module MicrosoftTeams
Connect-MicrosoftTeams -Credential $credential

# --------------------------------COMMENT OUT if USING MFA--------------------------- #

# Description
Write-Host '                 
These are some of the recommended security settings. Please go through each action and make sure you know the impact that it might have on your tenant before enabling.
 
Actions Performed:

- Enable mailbox auditing for all mailboxes 
- Enable 365 Audit Data Recording
- Set 365 account passwords to never expire 
- Allow anonymous guest sharing links for sites and docs 
- Set Expiry time for external sharing links to 14 days
- Set all mailboxes to keep deleted items for a maximum of 30 days
- Disable connecting to outside storage locations
- Disable Anonymous Calendar Sharing
- Create transport rule for client auto forwarding rule block
- Enable modern authentication for Exchange Online
- Block basic authentication 
- Automatically decrypt attachments upon download
- Pre-provision Onedrive storage for all licensed accounts
- Create DLP policies 
- Prevent winmail.dat attachments
- Reset the default malware filter policy with recommended settings
- Reset the default spam filter policy with recommended settings
- Enable MFA for all Global Admins 
- Set Language and Time Zone for All Users
- Show MailTip for External Recipients & for large # of recipients  
- Prepend disclaimer on external messages

  ATP Licensing

- Enable Advanced Threat Protection safe links policy 
- Enable Advanced Threat Protection safe attachments policy
- Creates Anti-Phish policy based on recommended settings

  AIP Licensing

- Enable OWA Encryption
'

Write-Host '-----------------------------------------------------------------'
Write-Host '              Starting O365 Security Configuration'
Write-Host '-----------------------------------------------------------------'

# Enable mailbox auditing for all mailboxes
Write-Host
Write-Host -ForegroundColor Yellow "Would you like to enable mailbox auditing for all mailboxes?"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost) {
y{
  Write-Host 'Enabling Mailbox Auditing for all Mailboxes...'
  $Audited = Get-Mailbox -ResultSize Unlimited -Filter {AuditEnabled -eq $false}
  if ($Audited.Count -eq "0") {
  Write-Host -ForegroundColor Green 'Auditing on all mailboxes is already enabled'
} else {
  $Audited | Set-Mailbox `
    -AuditEnabled $true `
    -AuditLogAgeLimit 365 `
    -AuditAdmin Update, MoveToDeletedItems, SoftDelete,HardDelete, SendAs, SendOnBehalf, Create, UpdateFolderPermission `
    -AuditDelegate Update, SoftDelete, HardDelete, SendAs, Create, UpdateFolderPermissions, MoveToDeletedItems, SendOnBehalf `
    -AuditOwner UpdateFolderPermission, MailboxLogin, Create, SoftDelete, HardDelete, Update, MoveToDeletedItems 
 
  Write-Host "Audit logging activation results"
  Get-Mailbox -ResultSize Unlimited | Select Name,Audit*
  Write-Host -ForegroundColor Green 'Auditing - Enabled'}
    }
Default{Write-Host -ForegroundColor Red 'Auditing - Not Enabled'}

}

# Enable 365 Audit Data Recording
Write-Host
Write-Host -ForegroundColor Yellow "Would you like to enable O365 Audit Data Recording?"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost) {
y{
Write-Host 'Enabling Office365 Auditing Data Injestion...'
$Auditdata = Get-AdminAuditLogConfig
if ($Auditdata.UnifiedAuditLogIngestionEnabled -eq $true) {
  Write-Host -ForegroundColor Green 'Audit Data Ingestion is already enabled'
} else {
    Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true;
    Write-Host -ForegroundColor Green 'Audit Data Ingestion is - Enabled'}
    }
Default{
Write-Host -ForegroundColor Red 'O365 Audit Data Recording - Not Enabled'}
  
}

# Set O365 account passwords to never expire
Write-Host
Write-Host -ForegroundColor Yellow "Would you like to set O365 account passwords to never expire?"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost) {
y{
Write-Host 'Setting all 365 user passwords to Never Expire...'
$Userexpire = Get-MSOLUser | Where-Object {$_.PasswordNeverExpires -eq $false}
if ($Userexpire.Count -eq "0") {
  Write-Host -ForegroundColor Green 'All user passwords are already set to never expire'
} else {
  $Userexpire | Set-MSOLUser -PasswordNeverExpires $true
  Write-Host -ForegroundColor Green 'All user passwords set to never expire - Enabled'
  }
    }
Default {Write-Host -ForegroundColor Red 'Account passwords to never expire - Not Enabled'}

}

# Allow anonymous guest sharing links for sites and docs 
Write-Host
Write-Host -ForegroundColor Yellow "Would you like to allow anonymous guest sharing links for sites and docs?"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost) {
y{
Write-Host 'Allowing anonymous guest sharing links on Sharepoint Sites...'
$sites = Get-sposite -template GROUP
Foreach($site in $sites)
{
Set-SPOSite -Identity $site.Url -SharingCapability ExternalUserAndGuestSharing;
}
Write-Host -ForegroundColor Green 'Anonymous guest sharing links are now - Enabled';}

Default{
Write-Host -ForegroundColor Red 'Allow anonymous guest sharing links for sites and docs - Not Enabled'}

}

# Set Expiry time for external sharing links to 14 days
Write-Host
Write-Host -ForegroundColor Yellow "Would you like to set expiry time for external sharing links to 14 days?"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost) {
y{
Write-Host 'Setting expiration time for external sharing links...'
$Spolinks = Get-SpoTenant
 if ($Spolinks.RequireAnonymousLinksExpireInDays -gt "0") {
  Write-Host -ForegroundColor Green 'External sharing links are already set to expire after a time'
}
 else {
  $expirationinDays = 14;
  Set-SpoTenant -RequireAnonymousLinksExpireInDays $expirationinDays;
  Write-Host -ForegroundColor Green 'External sharing links to expire after 14 days - Enabled'
  }}

Default{Write-Host -ForegroundColor Red 'Expiry time for external sharing links set to 14 days - Not Enabled'}

}

# Set all mailboxes to keep deleted items for a maximum of 30 days
Write-Host
Write-Host -ForegroundColor Yellow "Would you like to set all mailboxes to keep deleted items for a maximum of 30 days?"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost) {
y{Write-Host 'Setting all mailboxes to keep deleted items for a maximum of 30 days...'
$DeletedItems = Get-Mailbox 
 if ($DeletedItems.RetainDeletedItemsFor -gt "0") {
  Write-Host -ForegroundColor Green 'Deleted item retantion already has a set number of days'
  }
}
 else {
Get-Mailbox -ResultSize Unlimited | Set-Mailbox -RetainDeletedItemsFor 30
Write-Host -ForegroundColor Green '30 day deleted item retention for all mailboxes - Enabled'
    }
Default{Write-Host -ForegroundColor Red '30 day deleted item retention for all mailboxes - Not Enabled'}

}

# Disable connecting to outside storage locations
Write-Host
Write-Host -ForegroundColor Yellow "Would you like to disable OWA from connecting to outside storage locations like GoogleGrive and consumer OneDrive?"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost) {
y{Write-Host 'Disabling connecting to outside storage locations...' 
Get-OwaMailboxPolicy | Set-OwaMailboxPolicy -AdditionalStorageProvidersAvailable $False
Write-Host -ForegroundColor Green 'Disable outside storage locations like GoogleDrive and consumer OneDrive - Enabled'
    }
Default{Write-Host -ForegroundColor Red 'Disable outside storage locations like GoogleDrive and consumer OneDrive - Not Enabled'} 

}

# Disable Anonymous Calendar Sharing
Write-Host
Write-Host -ForegroundColor Yellow "Would you like to disable anonymous calendar sharing?"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost) {
y{Write-Host 'Disabling anonymous calendar sharing by default '
$Calendars = get-sharingpolicy -identity "Default Sharing Policy"
$Calendars = $Calendars.Domains
if ($Calendars -contains 'Anonymous:CalendarSharingFreeBusyReviewer')  { 
  Set-SharingPolicy -Identity "Default Sharing Policy" -Domains @{Remove='Anonymous:CalendarSharingFreeBusyReviewer'}  
  Write-Host -ForegroundColor Green 'Anonymous calendar sharing is now - Disabled'
  
} elseif ($Calendars -contains 'Anonymous:CalendarSharingFreeBusySimple')  {
    Set-SharingPolicy -Identity "Default Sharing Policy" -Domains @{Remove='Anonymous:CalendarSharingFreeBusySimple'}  
    Write-Host -ForegroundColor Green 'Anonymous calendar sharing is now - Disabled'

} elseif ($Calendars -contains 'Anonymous:CalendarSharingFreeBusyDetail')  {
    Set-SharingPolicy -Identity "Default Sharing Policy" -Domains @{Remove='Anonymous:CalendarSharingFreeBusyDetail'}  
    Write-Host -ForegroundColor Green 'Anonymous calendar sharing is now - Disabled'

} else {
  Write-Host -ForegroundColor Green 'Anonymous calendar sharing Is already disabled'
}
   }
Default{Write-Host -ForegroundColor Red  'Disable anonymous calendar sharing - Not Enabled'}

}

# Create transport rule for client auto forwarding block
Write-Host
Write-Host -ForegroundColor Yellow "Would you like to create transport rule for client auto forwarding block?"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost) {
y{Write-Host 'Creating a transport rule for client auto forwarding block';
$Clientrules = Get-TransportRule | Select Name
if ($Clientrules.Name -Like "Client Rules Forwarding Block") {
  Write-Host -ForegroundColor Green 'Client Rules Forwarding Block Already Exists'
} else {
    New-TransportRule "Client Rules Forwarding Block" `
      -FromScope "InOrganization" `
      -MessageTypeMatches "AutoForward" `
      -SentToScope "NotInOrganization" `
      -RejectMessageReasonText "External Email Forwarding via Client Rules is not permitted"
    Write-Host -ForegroundColor Green 'Client Rules Forwarding Block is now - Enabled'
  }
 }
Default{Write-Host -ForegroundColor Red 'Transport rule for client auto forwarding block - Not Enabled'}

}

# Enable modern authentication for Exchange Online
Write-Host
Write-Host -ForegroundColor Yellow "Would you like to enable modern authentication for Exchange Online?"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost) {
y{Write-Host 'Enabling modern authentication'
$OrgConfig = Get-OrganizationConfig 
 if ($OrgConfig.OAuth2ClientProfileEnabled) {
     Write-Host -ForegroundColor Green 'Modern Authentication for Exchange Online is already enabled'
 } 
 else {
     Write-Host 'Modern Authentication for Exchange online is not enabled'
         Set-OrganizationConfig -OAuth2ClientProfileEnabled $true
         Write-Host -ForegroundColor Green 'Modern Authentication is - Enabled'
         }
 }
 Default{Write-Host -ForegroundColor Red 'Modern Authentication - Not Enabled'}
 
}

 # Block basic authentication
 Write-Host
if ($OrgConfig.DefaultAuthenticationPolicy -eq $null -or $OrgConfig.DefaultAuthenticationPolicy -eq "") {
        Write-Host "There is no default authentication policy in place"}
Write-Host -ForegroundColor Yellow "Would you like to block basic authentication?"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost) {
y{$PolicyName = "Block Basic Auth"
$CheckPolicy = Get-AuthenticationPolicy | Where-Object {$_.Name -contains $PolicyName}
                    if (!$CheckPolicy) {
                    New-AuthenticationPolicy -Name $PolicyName
                    Write-Host "Block Basic Auth policy has been created"
                    } else {
                    Write-Host -ForegroundColor Green "Block Basic Auth policy already exists"
                    }
                Set-OrganizationConfig -DefaultAuthenticationPolicy $PolicyName
                      Write-Host -ForegroundColor Green "Block Basic Auth policy - Enabled"
                }
Default{Write-Host -ForegroundColor Red 'Block basic authentication - Not Enabled'}
}

# Automatically decrypt attachments upon download
Write-Host
Write-Host -foregroundcolor yellow "Do you want to automatically decrypt attachments upon download?"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost) {
y{Set-IRMConfiguration -DecryptAttachmentForEncryptOnly $true 
        Write-Host -foregroundcolor green "Automatically decrypt attachments upon download - Enabled"
        } 
Default{Write-Host -ForegroundColor Red "Automatically decrypt attachments upon download - Not Enabled"}

}

# Pre-provision Onedrive storage for all licensed accounts
Write-Host
Write-Host -foregroundcolor Yellow "Would you like to pre-provision Onedrive storage for all licensed accounts?"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost) {
y{Write-Host 'Pre-provisioning Onedrive for all licensed users'
$OneDriveUsers = Get-MSOLUser -All | Select-Object UserPrincipalName,islicensed | Where-Object {$_.islicensed -eq "True"}
Request-SPOPersonalSite -UserEmails $OneDriveUsers.UserPrincipalName -NoWait
Write-Host -ForegroundColor Green 'Pre-provision Onedrive storage for all licensed accounts - Enabled'  
    }
Default{Write-Host -foregroundcolor red "Pre-provision Onedrive storage for all licensed accounts - Not Enabled"}

}

# Create DLP policies
Write-Host
Write-Host -ForegroundColor Yellow "Would you like to create DLP policies to protect sensitive data?"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost) {
y{Write-Host 'Creating Data Loss Prevention Policies from templates...This will take awhile'
$Clientdlp = Get-DlpPolicy
if ($Clientdlp.Name -Like "U.S. Financial Data") {
    Write-Host 'DLP for U.S. Financial Data Already Exists'
} else {
    New-DlpPolicy -Name "U.S. Financial Data" -Mode AuditAndNotify -Template 'U.S. Financial Data';
    Remove-TransportRule -Identity "U.S. Financial: Scan text limit exceeded" -Confirm:$false
    Remove-TransportRule -Identity "U.S. Financial: Attachment not supported" -Confirm:$false
    Write-Host 'Added DLP for U.S. Financial Data'
}
if ($Clientdlp.Name -Like "U.S. Gramm-Leach-Bliley Act (GLBA)") {
    Write-Host 'DLP for U.S. Gramm-Leach-Bliley Act (GLBA) Already Exists'
} else {
    New-DlpPolicy -Name "U.S. Gramm-Leach-Bliley Act (GLBA)" -Mode AuditAndNotify -Template 'U.S. Gramm-Leach-Bliley Act (GLBA)'
    Remove-TransportRule -Identity "U.S. GLBA: Scan text limit exceeded" -Confirm:$false
    Remove-TransportRule -Identity "U.S. GLBA: Attachment not supported" -Confirm:$false
    Write-Host 'Added DLP for U.S. Gramm-Leach-Bliley Act (GLBA)'
}
if ($Clientdlp.Name -Like "U.S. Health Insurance Act (HIPAA)") {
    Write-Host 'DLP for U.S. Health Insurance Act (HIPAA) Already Exists'
} else {
    New-DlpPolicy -Name "U.S. Health Insurance Act (HIPAA)" -Mode AuditAndNotify -Template "U.S. Health Insurance Act (HIPAA)"
    Remove-TransportRule -Identity "U.S. HIPAA: Scan text limit exceeded" -Confirm:$false
    Remove-TransportRule -Identity "U.S. HIPAA: Attachment not supported" -Confirm:$false
    Write-Host 'Added DLP for U.S. Health Insurance Act (HIPAA)'
    }
if ($Clientdlp.Name -Like "U.S. Patriot Act") {
    Write-Host 'DLP for U.S. Patriot Act Already Exists'
} else {
    New-DlpPolicy -Name "U.S. Patriot Act" -Mode AuditAndNotify -Template "U.S. Patriot Act"
    Remove-TransportRule -Identity "U.S. Patriot Act: Scan text limit exceeded" -Confirm:$false
    Remove-TransportRule -Identity "U.S. Patriot Act: Attachment not supported" -Confirm:$false
    Write-Host 'Added DLP for U.S. Patriot Act'
    }
if ($Clientdlp.Name -Like "U.S. Personally Identifiable Information (PII) Data") {
    Write-Host 'DLP for U.S. Personally Identifiable Information (PII) Data'
} else {
    New-DlpPolicy -Name "U.S. Personally Identifiable Information (PII) Data" -Mode AuditAndNotify -Template "U.S. Personally Identifiable Information (PII) Data"
    Remove-TransportRule -Identity "U.S. PII: Scan text limit exceeded" -Confirm:$false
    Remove-TransportRule -Identity "U.S. PII: Attachment not supported" -Confirm:$false
    Write-Host 'Added DLP for U.S. Personally Identifiable Information (PII) Data'
    }
if ($Clientdlp.Name -Like "U.S. State Breach Notification Laws") {
    Write-Host 'DLP for U.S. State Breach Notification Laws'
} else {
    New-DlpPolicy -Name "U.S. State Breach Notification Laws" -Mode AuditAndNotify -Template "U.S. State Breach Notification Laws"
    Remove-TransportRule -Identity "U.S. State Breach Notification: Scan text limit exceeded" -Confirm:$false
    Remove-TransportRule -Identity "U.S. State Breach Notification: Attachment not supported" -Confirm:$false
    Write-Host 'Added DLP for U.S. State Breach Notification Laws'
    }
if ($Clientdlp.Name -Like "U.S. State Social Security Number Confidentiality Laws") {
    Write-Host 'DLP for U.S. State Social Security Number Confidentiality Lawss'
} else {
    New-DlpPolicy -Name "U.S. State Social Security Number Confidentiality Laws" -Mode AuditAndNotify -Template "U.S. State Social Security Number Confidentiality Laws"
    Remove-TransportRule -Identity "U.S. SSN Laws: Scan text limit exceeded" -Confirm:$false
    Remove-TransportRule -Identity "U.S. SSN Laws: Attachment not supported" -Confirm:$false
    Write-Host 'Added DLP for U.S. State Social Security Number Confidentiality Laws'
    }

    Write-Host -ForegroundColor Green 'DLP policies - Enabled'
}

Default { Write-Host -ForegroundColor Red  'DLP Policies - Not Enabled'}

}

# Prevent winmail.dat attachments
Write-Host
Write-Host -ForegroundColor yellow "Would you like to prevent winmail.dat attachments (Some attachments may appear as winmail.dat and be unreadable in certain mail clients)?"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost) {
y{$DefaultRemoteDomain = Get-RemoteDomain Default
        Set-RemoteDomain Default -TNEFEnabled $false 
        Write-Host -ForegroundColor Green "Prevent winmail.dat attachments - Enabled"
        } 
        Default{Write-Host -ForegroundColor red  'Prevent winmail.dat attachments - Not Enabled'}

}

# Reset the default malware filter policy with the recommended settings
Write-Host -ForegroundColor Yellow "Do you want to reset the default malware filter policy with recommended settings?"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost) {
y{$AlertAddress= Read-Host "Enter the email address where you would like to recieve alerts about malware and outbound spam"
    # Modify default malware filter policy
    $MalwarePolicyParam = @{
        'Action' =  'DeleteMessage';
        'EnableFileFilter' =  $true;
        'EnableInternalSenderAdminNotifications' = $true;
        'InternalSenderAdminAddress' =  $AlertAddress;
        'EnableInternalSenderNotifications' =  $false;
        'EnableExternalSenderNotifications' = $false;
        'Zap' = $true
    }
    Set-MalwareFilterPolicy Default @MalwarePolicyParam -MakeDefault
    Write-Host -ForegroundColor Green "Default malware filter policy with the recommended settings - Enabled"
        }  
     Default{Write-Host -ForegroundColor Red "Default malware filter policy with the recommended settings - Not Enabled"}

}

# Reset the default spam filter policy with recommended settings
Write-Host
Write-Host -ForegroundColor yellow "Would you like to reset the default spam filter policy with recommended settings?"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost) {
y{$HostedContentPolicyParam = @{
        'bulkspamaction' =  'MoveToJMF';
        'bulkthreshold' =  '6';
        'highconfidencespamaction' =  'quarantine';
        'inlinesafetytipsenabled' = $true;
        'markasspambulkmail' = 'on';
        'enablelanguageblocklist' = $false;
        'enableregionblocklist' = $false;
        'increasescorewithimagelinks' = 'off'
        'increasescorewithnumericips' = 'on'
        'increasescorewithredirecttootherport' = 'on'
        'increasescorewithbizorinfourls' = 'on';
        'markasspamemptymessages' ='on';
        'markasspamjavascriptinhtml' = 'on';
        'markasspamframesinhtml' = 'on';
        'markasspamobjecttagsinhtml' = 'on';
        'markasspamembedtagsinhtml' ='on';
        'markasspamformtagsinhtml' = 'on';
        'markasspamwebbugsinhtml' = 'off';
        'markasspamsensitivewordlist' = 'on';
        'markasspamspfrecordhardfail' = 'on';
        'markasspamfromaddressauthfail' = 'on';
        'markasspamndrbackscatter' = 'off';
        'phishspamaction' = 'quarantine';
        'spamaction' = 'MoveToJMF';
        'zapenabled' = $true;
        'EnableEndUserSpamNotifications' = $true;
        'EndUserSpamNotificationFrequency' = 1;
        'QuarantineRetentionPeriod' = 30
    }
    Set-HostedContentFilterPolicy Default @HostedContentPolicyParam -MakeDefault
    Write-Host -ForegroundColor Green  "Default spam filter policy with recommended settings - Enabled"
   } 
Default{Write-Host -ForegroundColor Red "Default spam filter policy with recommended settings - Not Enabled"}      

}

# Enable MFA for all Global Admins 
Write-Host
Write-Host -ForegroundColor yellow "Do you want to enable MFA for all Global Admins?"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost) {
y{$auth = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
	$auth.RelyingParty = "*"
	$auth.State = "Enabled"
	$auth.RememberDevicesNotIssuedBefore = (Get-Date)	
	$GlobalAdminsRoleGroup = Get-MsolRole | ? { $_.Name -eq "Company Administrator" }
	$GlobalAdmins = Get-MsolRoleMember -RoleObjectId $GlobalAdminsRoleGroup.ObjectId -MemberObjectTypes User -All
	$GlobalAdmins | % { Set-MsolUser -UserPrincipalName $_.EmailAddress -StrongAuthenticationRequirements $auth }
	Write-Host -ForegroundColor Green "MFA for all Global Admins - Enabled"	
    }
Default{Write-Host -ForegroundColor Red 'MFA for all Global Admins - Not Enabled'}

}

# Set Language and Time Zone for All Users
Write-Host
Write-Host -ForegroundColor yellow "Do you want to set language and time zone for all users?"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost) {
y{
Write-Host  'This will take some time...' 
Get-Mailbox | Get-MailboxRegionalConfiguration | ? {$_.TimeZone -eq $null} | Set-MailboxRegionalConfiguration -Language 1033 -TimeZone "Central Standard Time"
Write-Host -ForegroundColor Green 'Language and time zone for all users - Enabled' 
}
Default{Write-Host -ForegroundColor Red 'Language and time zone for all users - Not Enabled'}

}

# Show MailTips for external recipients & for large # of recipients
Write-Host
Write-Host -ForegroundColor yellow "Do you want to show MailTips for external recipients & for large # of recipients?"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost) {
y{
Set-OrganizationConfig -MailTipsExternalRecipientsTipsEnabled $True
Write-Host -ForegroundColor Green 'Show MailTips for external recipients & for large # of recipients - Enabled'
    }
Default{Write-Host -ForegroundColor Red 'Show MailTips for external recipients - Not Enabled'}

}

# Prepend disclaimer on external messages
Write-Host
Write-Host -ForegroundColor yellow "Do you want to prepend disclaimer on external messages?"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost) {
y{
$TransportSettings = @{
Name = 'External Sender Warning'
FromScope = 'NotInOrganization'
SentToScope = 'InOrganization'
ApplyHtmlDisclaimerLocation = 'Prepend'
ApplyHtmlDisclaimerText = "<p><div style='border:solid #9C6500 1.0pt;padding:2.0pt 2.0pt 2.0pt 2.0pt'><p class=MsoNormal style='line-height:12.0pt;background:#FFEB9C'><b><span style='font-size:10.0pt;color:#9C6500'></span></b><span style='font-size:10.0pt;color:black'>[EXTERNAL]<o:p></o:p></span></p>"
ApplyHtmlDisclaimerFallbackAction = 'Wrap'
} 
New-TransportRule @TransportSettings 
Write-Host -ForegroundColor green "Prepend disclaimer on external messages - Enabled"
    }
Default{Write-Host -ForegroundColor red "prepend disclaimer on external messages - Not Enabled"}

}

# Disable IMAP / POP Protocols
Write-Host
Write-Host -ForegroundColor yellow "Do you want to disable IMAP / POP protocols?"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost) {
y{
# Current Users 
Get-CASMailbox -Filter {ImapEnabled -eq "true" -or PopEnabled -eq "true" } | Select-Object @{n = "Identity"; e = {$_.primarysmtpaddress}} | Set-CASMailbox -ImapEnabled $false -PopEnabled $false
# Future Users
Get-CASMailboxPlan -Filter {ImapEnabled -eq "true" -or PopEnabled -eq "true" } | set-CASMailboxPlan -ImapEnabled $false -PopEnabled $false 
   Write-Host -ForegroundColor green "Disable IMAP / POP protocols - Enabled"
    }
Default{Write-Host -ForegroundColor red "Disable IMAP / POP protocols - Not Enabled"}

}

# Check for ATP licensing
$Licensing = Get-MsolSubscription
if (($Licensing.SkuPartNumber -contains 'ATP_ENTERPRISE' ) -or ($Licensing.SkuPartNumber -contains 'SPB' ) -or ($Licensing.SkuPartNumber -contains 'SPE_E5' ) -or ($Licensing.SkuPartNumber -contains 'ENTERPRISEPREMIUM' )){

  Write-host
  Write-Host 'Advanced Threat Protection Licensing Detected'
  Write-Host '----------------------------------------------'

# Enable Advanced Threat Protection safe links policy
  Write-Host
  Write-Host -ForegroundColor yellow "Do you want to enable Advanced Threat Protection safe links policy?"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost) {
y{
  Write-Host 'Enabling ATP Safe Links Policy'
  $Safelinks = Get-SafeLinksPolicy
  if ($Safelinks.Enabled -eq $true) {
    Write-Host -ForegroundColor green 'ATP Safe links Policy Already Enabled'
} elseif ($Safelinks.count -eq "0") {
    $Maildomains = get-msoldomain | Select-Object Name
    $Domains = $Maildomains.name;
    New-SafeLinksPolicy -Name 'Safe Links' -AdminDisplayName $null -IsEnabled:$true -AllowClickThrough:$false -TrackClicks:$false
    New-SafeLinksRule -Name 'Safe Links' -SafeLinksPolicy 'Safe Links' -RecipientDomainIs @($Domains)
    Write-Host -ForegroundColor green 'ATP Safe links is now Enabled'
} else {
    Get-SafeLinksPolicy | Set-SafeLinksPolicy -Enabled $true
    Write-Host -ForegroundColor green 'ATP Safe links is - Enabled'

  }
    }
Default{Write-Host -ForegroundColor green "Advanced Threat Protection safe links policy - Not Enabled"}

}
      
# Enable Advanced Threat Protection safe attachments policy
  Write-Host
  Write-Host -ForegroundColor yellow "Do you want to enable Advanced Threat Protection safe attachments policy?"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost) {
y{
  Write-Host 'Enabling ATP Safe Attachments Policy'
  $Safeattachments = Get-SafeAttachmentPolicy
  if ($Safeattachments.Enable -eq $true) {
    Write-Host -ForegroundColor green 'ATP Safe Attachment Policy Already Enabled'
  } elseif ($Safelattachments.count -eq "0") {
      $Maildomains = get-msoldomain | Select-Object Name
      $Domains = $Maildomains.name;
      New-SafeAttachmentPolicy "Safe Attachments" -Enable:$true -Redirect:$false -Action: Block
      New-SafeAttachmentRule "Safe Attachments" -RecipientDomainIs @($Domains) -SafeAttachmentPolicy "Safe Attachments" -Enable:$true
      Write-Host -ForegroundColor green 'ATP Safe Attachment Policy - Enabled'    
    } else {
      Get-SafeAttachmentPolicy | Set-SafeAttachmentPolicy -Enable $true;
      Write-Host -ForegroundColor green 'ATP Safe Attachment Policy - Enabled'

    }
        }
Default{Write-Host -ForegroundColor red "Advanced Threat Protection safe attachments policy - Not Enabled"}

}

# Creates Anti-Phish policy based on recommended settings
Write-Host
Write-Host -Foregroundcolor yellow "Do you want to create an Anti-Phish policy based on recommended settings?"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost) {
y{$PhishPolicyParam=@{
   'Name' = "AntiPhish Baseline Policy";
   'AdminDisplayName' = "AntiPhish Baseline Policy";
   'AuthenticationFailAction' =  'Quarantine';
   'EnableAntispoofEnforcement' = $true;
   'EnableAuthenticationSafetyTip' = $true;
   'Enabled' = $true;
   'EnableMailboxIntelligence' = $true;
   'EnableMailboxIntelligenceProtection' = $true;
   'MailboxIntelligenceProtectionAction' = 'Quarantine';
   'EnableOrganizationDomainsProtection' = $true;
   'EnableSimilarDomainsSafetyTips' = $true;
   'EnableSimilarUsersSafetyTips' = $true;
   'EnableTargetedDomainsProtection' = $false;
   'EnableTargetedUserProtection' = $false;
   'EnableUnusualCharactersSafetyTips' = $true;
   'PhishThresholdLevel' = 3;
   'TargetedDomainProtectionAction' =  'Quarantine';
   'TargetedUserProtectionAction' =  'Quarantine';
   'TreatSoftPassAsAuthenticated' = $true
}
Set-AntiPhishPolicy -Identity "Office365 AntiPhish Default" @PhishPolicyParam  
    Write-Host -Foregroundcolor green 'Anti-Phish policy based on recommended settings - Enabled'
    }
Default{Write-Host -Foregroundcolor red 'Anti-Phish policy based on recommended settings - Not Enabled'}

}

}

if (($Licensing.SkuPartNumber -notcontains 'ATP_ENTERPRISE' ) -or ($Licensing.SkuPartNumber -notcontains 'SPB' ) -or ($Licensing.SkuPartNumber -notcontains 'SPE_E5' ) -or ($Licensing.SkuPartNumber -notcontains 'ENTERPRISEPREMIUM' )){
    Write-Host
    Write-Host 'No Advanced Threat Protection Licensing Detected - Skipping'
    Write-Host '--------------------------------------------------------------' 
}

# Check for AIP licensing
$Licensing = Get-MsolSubscription
if (($Licensing.SkuPartNumber -contains 'RIGHTSMANAGEMENT' ) -or ($Licensing.SkuPartNumber -contains 'SPB' ) -or ($Licensing.SkuPartNumber -contains 'SPE_E5' ) -or ($Licensing.SkuPartNumber -contains 'ENTERPRISEPREMIUM' ) -or ($Licensing.SkuPartNumber -contains 'ENTERPRISEPACK' ) -or ($Licensing.SkuPartNumber -contains 'SPE_E3' ) -or ($Licensing.SkuPartNumber -contains 'SPE_F1' )){

  write-host
  Write-Host 'Azure Information Protection Licensing Detected'
  Write-Host '------------------------------------------------'

# Enable OWA Encryption
Write-Host
Write-Host -ForegroundColor Yellow "Do you want to enable OWA encryption?"
$ReadHost = Read-Host " ( y / n ) "
Switch($ReadHost) {
y{Set-IRMConfiguration -SimplifiedClientAccessEnabled $true
        Write-Host -ForegroundColor Green 'The OWA encryption - Enabled'
        }
     
Default{Write-Host -ForegroundColor Red 'OWA encryption - Not Enabled'}

}

}

if (($Licensing.SkuPartNumber -notcontains 'RIGHTSMANAGEMENT' ) -or ($Licensing.SkuPartNumber -notcontains 'SPB' ) -or ($Licensing.SkuPartNumber -notcontains 'SPE_E5' ) -or ($Licensing.SkuPartNumber -notcontains 'ENTERPRISEPREMIUM' ) -or ($Licensing.SkuPartNumber -notcontains 'ENTERPRISEPACK' ) -or ($Licensing.SkuPartNumber -notcontains 'SPE_E3' ) -or ($Licensing.SkuPartNumber -notcontains 'SPE_F1' )){
    Write-Host
    Write-Host 'No Azure Information Protection Licensing Detected - Skipping'
    Write-Host '--------------------------------------------------------------' 
}

Write-host
Write-Host
Write-Host -ForegroundColor Green '---------------------------------------------'
Write-Host -ForegroundColor Green 'Tenant security settings have been configured'
Write-Host -ForegroundColor Green '---------------------------------------------'

# Remove all connections
Remove-PSSession $exchangeSession ; Remove-PSSession $SccSession ; Disconnect-SPOService ; Disconnect-MicrosoftTeams 
Get-PSSession | Remove-PSSession