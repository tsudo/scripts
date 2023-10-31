 ############################################
# Title: PS_Launch-Support-URLs
# Description: Launches Websites for Downloads
# LastMod: 2023-10-30
# Author: @tsudo on Github & Twitter
############################################

############################################
# DISCLAIMER: Use it an your own risk.
# Licensed under MIT License https://github.com/tsudo/scripts/blob/master/License.md
############################################


$urls = @(
    "https://ninite.com/7zip-firefox-notepadplusplus-revo-teamviewer15/ninite.exe",
	"https://ninite.com/avast-malwarebytes/ninite.exe",
	"https://forwardslashsecurity.com/download/advisorinstaller.exe",
	"https://www.uranium-backup.com/uranium-backup-free-download/",
    "https://www.hdsentinel.com/download.php",
    "https://patchmypc.com/home-updater",
    "https://learn.microsoft.com/en-us/sysinternals/downloads/sysinternals-suite",
    "https://www.ccleaner.com/ccleaner/builds",
    "https://keepassxc.org/download/#windows"
    )

foreach ($url in $urls) {
    Start-Process $url
    Start-Sleep -Seconds 5
}
