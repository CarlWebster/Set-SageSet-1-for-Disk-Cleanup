<#
.SYNOPSIS
	Set the registry keys for all options for Disk Cleanup (cleanmgr.exe).
.DESCRIPTION
	Set the registry keys for all options for Disk Cleanup (cleanmgr.exe).
	
	Running cleanmgr.exe /SageSet:1 presents more options than running the
	Disk Cleanup Windows app. This script retrieves all registry keys in 
	HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches 
	and sets the property named StateFlags0001 to a value of 2 or 0 if the
	Clean parameter is used.
	
	Using ideas from 
	https://msdn.microsoft.com/en-us/library/windows/desktop/bb776782(v=vs.85).aspx
	
	This Script runs best in version 5.

	This script requires an elevated PowerShell session.

.PARAMETER Downloads
	Defaults to $False
	
	Windows 10 1809 added the Downloads folder to the list of folders that can be cleaned.
	By default, the script will exclude the Downloads folder.
	If you want the Downloads folder cleaned, use -Downloads $True
.PARAMETER Reset
	Defaults to $False
	
	Sets or resets all values to 0 in 
	HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches
.EXAMPLE
	PS C:\PSScript > .\Set-SageSet1.ps1

	Except for DownloadsFolder, sets all StateFlags0001 value to 2 in 
	HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches
.EXAMPLE
	PS C:\PSScript > .\Set-SageSet1.ps1 -Downloads

	Sets all StateFlags0001 value to 2, including DownloadsFolder, in 
	HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches
.EXAMPLE
	PS C:\PSScript > .\Set-SageSet1.ps1 -Reset

	Sets all StateFlags0001 value to 0 in 
	HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches
.INPUTS
	None.  You cannot pipe objects to this script.
.OUTPUTS
	No objects are output from this script.
.NOTES
	NAME: Set-SageSet1.ps1
	VERSION: 1.10
	AUTHOR: Carl Webster, Sr. Solutions Architect, Choice Solutions, LLC
	LASTEDIT: December 14, 2018
#>

#region script parameters
[CmdletBinding(SupportsShouldProcess = $False, ConfirmImpact = "None") ]

Param(
	[parameter(Mandatory=$False)] 
	[Switch]$Downloads=$False,

	[parameter(Mandatory=$False)] 
	[Switch]$Reset=$False

	)
#endregion

#webster@carlwebster.com
#Sr. Solutions Architect at Choice Solutions, LLC
#@carlwebster on Twitter
#http://www.CarlWebster.com
#Created on September 4, 2017

#Version 1.0 released to the community on May 17, 2018
#Thanks to Michael B. Smith for the code review and suggestions
#
#V1.10
#	Add -Downloads switch parameter.
#		Win10 1809 added the DOwnloads folder to the list of folders that can be cleaned.
#		-Downloads is $False by default to exlude cleaning out the Downloads folder

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
		If($Reset -eq $False)
		{
			#this is what is returned in $result.name:
			#HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\<some name>
			#change HKEY_LOCAL_MACHINE to HKLM:
			
			If($Downloads -eq $False -and $result.name -eq "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\DownloadsFolder")
			{
				#do nothing
			}
			Else
			{
				$tmp = 'HKLM:' + $result.Name.Substring( 18 )
				$tmp2 = $result.Name.SubString( $result.Name.LastIndexOf( '\' ) + 1 )
				Write-Host "Setting $tmp2 to 2"
				$null = New-ItemProperty -Path $tmp -Name 'StateFlags0001' -Value 2 -PropertyType DWORD -Force -EA 0
				
				If(!$?)
				{
					Write-Warning "`tUnable to set $tmp2"
				}
			}
		}
		ElseIf($Reset -eq $True)
		{
			$tmp = 'HKLM:' + $result.Name.Substring( 18 )
			$tmp2 = $result.Name.SubString( $result.Name.LastIndexOf( '\' ) + 1 )
			Write-Host "Resetting $tmp2 to 0"
			$null = New-ItemProperty -Path $tmp -Name 'StateFlags0001' -Value 0 -PropertyType DWORD -Force -EA 0
			
			If(!$?)
			{
				Write-Warning "`tUnable to set $tmp2"
			}
		}
	}
	Write-Host "Script ended Successfully"
}
