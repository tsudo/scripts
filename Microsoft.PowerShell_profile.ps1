############################################
# Title: Powershell Profile
# LastMod: 20190320
# Author: Keith Crawford // @tsudo on Github & Twitter
############################################

############################################
# DISCLAIMER: Use it an your own risk.
# Licensed under MIT License https://github.com/tsudo/scripts/blob/master/License.md
############################################

######################
# VARIABLES
$foregroundColor = 'white'
$time = Get-Date
$psVersion= $host.Version.Major
$curUser= (Get-ChildItem Env:\USERNAME).Value
$curDomain= (Get-ChildItem Env:\USERDOMAIN).Value
$curComp= (Get-ChildItem Env:\COMPUTERNAME).Value
$curLogonSvr= (Get-ChildItem Env:\LOGONSERVER).Value
$ip_ext = Invoke-RestMethod http://ipinfo.io/json | Select -exp ip

######################
# Script Directory: Determine script location for PowerShell
$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path


######################
# ALIASES
new-item alias:np -value "C:\Program Files (x86)\Notepad++\notepad++.exe"

######################
# COMMANDS
# Set Working Directory
set-location C:\
# Clear Screen
clear-host

######################
# Write Banner Text
Write-Host "Greetings, $curUser@$curDomain" -foregroundColor Magenta
Write-Host "Today is: $($time.ToLongDateString())"
Write-Host "You're running PowerShell version: $psVersion" -foregroundColor Green
Write-Host "Your COMPUTER NAME is: $curComp" -foregroundColor Green
Write-Host "Your LOGON SERVER is: $curLogonSvr" -foregroundColor Green
Write-Host "Your EXTERNAL IP is: $ip_ext" -foregroundColor Green
Write-Host "ScriptDir is $ScriptDir" -foregroundColor Green
Write-Host "Happy scripting!" `n

######################
# Change prompt
function Prompt {

$curtime = Get-Date

Write-Host -NoNewLine "P" -foregroundColor Green
Write-Host -NoNewLine "$" -foregroundColor Green
Write-Host -NoNewLine "[" -foregroundColor $foregroundColor
Write-Host -NoNewLine ("{0:HH}:{0:mm}:{0:ss}" -f (Get-Date)) -foregroundColor $foregroundColor
Write-Host -NoNewLine "]" -foregroundColor $foregroundColor
Write-Host -NoNewLine ">" -foregroundColor Red

$host.UI.RawUI.WindowTitle = "P$ >> tsudoShell >> DIR: $((Get-Location).Path)"

Return " "

}