# Set-SageSet-1-for-Disk-Cleanup
Set SageSet=1 for Disk Cleanup

	Set the registry keys for all options for Disk Cleanup (cleanmgr.exe).
	
	Running cleanmgr.exe /SageSet:1 presents more options than running the
	Disk Cleanup Windows app. This script retrieves all registry keys in 
	HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches 
	and sets the property named StateFlags0001 to a value of 2.
	
	Using ideas from https://msdn.microsoft.com/en-us/library/windows/desktop/bb776782(v=vs.85).aspx
	
	This Script runs best in version 5.

	This script requires an elevated PowerShell session.
