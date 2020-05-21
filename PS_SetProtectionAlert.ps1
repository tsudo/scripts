############################################
# Title: PS_SetProtectionAlert
# Desc: Configure notification email recipient for 365 users when they are blocked based on suspcious actiity.
# LastMod: 20200130
# Author: Edafio
############################################


######################
# SCRIPT
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking

New-ProtectionAlert -Name "Create ticket for restricted user" -Category ThreatManagement -NotifyUser EMAILADDRESS -ThreatType Activity -Operation CompromisedAccount -Description "Custom alert policy to track when user gets blocked from sending email that looks suspicious" -AggregationType none -severity high

Remove-PSSession $Session 