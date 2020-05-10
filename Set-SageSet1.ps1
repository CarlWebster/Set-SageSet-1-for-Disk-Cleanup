<#
.SYNOPSIS
	Set the registry keys for all options for Disk Cleanup (cleanmgr.exe).
.DESCRIPTION
	Set the registry keys for all options for Disk Cleanup (cleanmgr.exe).
	
	Running cleanmgr.exe /SageSet:1 presents more options than running the
	Disk Cleanup Windows app. This script retrieves all registry keys in 
	HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches 
	and sets the property named StateFlags0001 to a value of 2.
	
	Using ideas from https://msdn.microsoft.com/en-us/library/windows/desktop/bb776782(v=vs.85).aspx
	
	This Script runs best in version 5.

	This script requires an elevated PowerShell session.

.INPUTS
	None.  You cannot pipe objects to this script.
.OUTPUTS
	No objects are output from this script.
.NOTES
	NAME: Set-SageSet1.ps1
	VERSION: 1.00
	AUTHOR: Carl Webster, Sr. Solutions Architect, Choice Solutions, LLC
	LASTEDIT: May 17, 2018
#>

#webster@carlwebster.com
#Sr. Solutions Architect at Choice Solutions, LLC
#@carlwebster on Twitter
#http://www.CarlWebster.com
#Created on September 4, 2017

#Version 1.0 released to the community on May 17, 2018
#Thanks to Michael B. Smith for the code review and suggestions

Set-StrictMode -Version 2

#make sure the script is running from an elevated PowerShell session
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent() )

If($currentPrincipal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator ))
{
	Write-Host "This is an elevated PowerShell session"
}
Else
{
	Write-Host "$(Get-Date): This is NOT an elevated PowerShell session. Script will exit."
	Exit
}

$results = Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches

If(!$?)
{
	#error
	Write-Error "Unable to retrieve data from the registry"
}
ElseIf($? -and $null -eq $results)
{
	#nothing there
	Write-Host "Didn't find anything in HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches which is odd"
}
Else
{
	ForEach($result in $results)
	{
		#this is what is returned in $result.name:
		#HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\<some name>
		#change HKEY_LOCAL_MACHINE to HKLM:
		$tmp = 'HKLM:' + $result.Name.Substring( 18 )
		$tmp2 = $result.Name.SubString( $result.Name.LastIndexOf( '\' ) + 1 )
		Write-Host "Setting $tmp2"
		$null = New-ItemProperty -Path $tmp -Name 'StateFlags0001' -Value 2 -PropertyType DWORD -Force -EA 0
		
		If(!$?)
		{
			Write-Warning "`tUnable to set $tmp2"
		}
	}
	Write-Host "Script ended Successfully"
}
