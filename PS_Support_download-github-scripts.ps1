 ############################################
# Title: PS_support-script-download
# Description: Creates folders for Support and gathers basic info.
# LastMod: 2023-10-30
# Author: @tsudo on Github & Twitter
############################################

############################################
# DISCLAIMER: Use it an your own risk.
# Licensed under MIT License https://github.com/tsudo/scripts/blob/master/License.md
############################################

# Download the first script
$url1 = "https://github.com/tsudo/scripts/raw/master/PS_Support-Info-Gathering.ps1"
$downloadsPath1 = [System.IO.Path]::Combine([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::MyDocuments), "Downloads\PS_Support-Info-Gathering.ps1")

# Download the second script
$url2 = "https://github.com/tsudo/scripts/raw/master/PS_Support-launch_downloads"
$downloadsPath2 = [System.IO.Path]::Combine([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::MyDocuments), "Downloads\PS_SetProtectionAlert.ps1")

# Download the first script
Invoke-WebRequest -Uri $url1 -OutFile $downloadsPath1

# Download the second script
Invoke-WebRequest -Uri $url2 -OutFile $downloadsPath2
