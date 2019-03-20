 ############################################
# Title: PS_GetACL
# Desc: List of Access Rights to a target folder
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
$TargetFolder = C:\temp

######################
# SCRIPT
 Get-Acl $TargetFolder | select -ExpandProperty AccessToString | format-List