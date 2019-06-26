############################################
# Title: PS_AD_Comp_LastLogin
# Desc: Get list of Domain (AD) Computers sorted by last login date.
# LastMod: 20190626
# Author: Keith Crawford // @tsudo on Github & Twitter
############################################

############################################
# DISCLAIMER: Use it an your own risk.
# Licensed under MIT License https://github.com/tsudo/scripts/blob/master/LICENSE.md
############################################

######################
# Variables Global
$Now = Get-Date
$ResultFile = "C:\temp\ADComputers_LastLogin" + $Now.ToString("_yyyyMMdd_HH-mm-ss") + ".csv"

######################
# SCRIPT
Get-ADComputer -Filter * -Properties * | Select-Object CN, CanonicalName, LastLogonDate, Created, OperatingSystem, OperatingSystemVersion, IPv4Address | Sort-Object LastLogonDate | Export-CSV $ResultFile -NoTypeInformation