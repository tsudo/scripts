 ############################################
# Title: PS_Support_Setup_Script
# Description: Creates folders for Support and gathers basic info.
# LastMod: 2023-10-30
# Author: @tsudo on Github & Twitter
############################################

############################################
# DISCLAIMER: Use it an your own risk.
# Licensed under MIT License https://github.com/tsudo/scripts/blob/master/License.md
############################################

# Task 1: Create C:\support folder
New-Item -ItemType Directory -Path "C:\support" -Force

# Task 2: Create C:\support\apps sub-folder
New-Item -ItemType Directory -Path "C:\support\apps" -Force

# Task 3: Create C:\support\installs sub-folder
New-Item -ItemType Directory -Path "C:\support\installs" -Force

# Task 4: Create C:\support\docs sub-folder
New-Item -ItemType Directory -Path "C:\support\docs" -Force

# Task 5: Create C:\support\scripts sub-folder
New-Item -ItemType Directory -Path "C:\support\scripts" -Force

# Task 6: Run "systeminfo" and output to a file
$systemInfoOutput = systeminfo
$systemInfoOutput | Out-File -FilePath "C:\support\docs\systeminfo_$(Get-Date -Format 'yyyy-MM-dd').txt"

# Task 7: Run specified commands and put their output in a single text file
$ipconfigOutput = ipconfig /all
$serialNumberOutput = wmic bios get serialnumber
$nslookupOutput = nslookup yahoo.com

$combinedOutput = @"
IPConfig Output:
$ipconfigOutput

Serial Number Output:
$serialNumberOutput

NSLookup Output:
$nslookupOutput
"@

$combinedOutput | Out-File -FilePath "C:\support\docs\cmd-docs_$(Get-Date -Format 'yyyy-MM-dd').txt"
