# optimize_vhdx.ps1 - Optimize VHDX drive file
 param (
    [Parameter(Mandatory=$true, HelpMessage="Pathname to *.vhdx file to optimize")][string]$vhdx
 )

# Stop on error in cmdlets
$ErrorActionPreference = "Stop"

# From: https://www.experts-exchange.com/viewCodeSnippet.jsp?codeSnippetId=20-39724941-1
Mount-VHD -Path $vhd -ReadOnly
Optimize-VHD -Path $vhd -Mode Full
DisMount-VHD -Path $vhd

