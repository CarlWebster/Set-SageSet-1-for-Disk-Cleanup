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
	AUTHOR: Carl Webster
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

# SIG # Begin signature block
# MIIf8QYJKoZIhvcNAQcCoIIf4jCCH94CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUNL+LnAtXS7d0lodGR/aP5pDh
# 6RWgghtYMIIDtzCCAp+gAwIBAgIQDOfg5RfYRv6P5WD8G/AwOTANBgkqhkiG9w0B
# AQUFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVk
# IElEIFJvb3QgQ0EwHhcNMDYxMTEwMDAwMDAwWhcNMzExMTEwMDAwMDAwWjBlMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3Qg
# Q0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCtDhXO5EOAXLGH87dg
# +XESpa7cJpSIqvTO9SA5KFhgDPiA2qkVlTJhPLWxKISKityfCgyDF3qPkKyK53lT
# XDGEKvYPmDI2dsze3Tyoou9q+yHyUmHfnyDXH+Kx2f4YZNISW1/5WBg1vEfNoTb5
# a3/UsDg+wRvDjDPZ2C8Y/igPs6eD1sNuRMBhNZYW/lmci3Zt1/GiSw0r/wty2p5g
# 0I6QNcZ4VYcgoc/lbQrISXwxmDNsIumH0DJaoroTghHtORedmTpyoeb6pNnVFzF1
# roV9Iq4/AUaG9ih5yLHa5FcXxH4cDrC0kqZWs72yl+2qp/C3xag/lRbQ/6GW6whf
# GHdPAgMBAAGjYzBhMA4GA1UdDwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB0G
# A1UdDgQWBBRF66Kv9JLLgjEtUYunpyGd823IDzAfBgNVHSMEGDAWgBRF66Kv9JLL
# gjEtUYunpyGd823IDzANBgkqhkiG9w0BAQUFAAOCAQEAog683+Lt8ONyc3pklL/3
# cmbYMuRCdWKuh+vy1dneVrOfzM4UKLkNl2BcEkxY5NM9g0lFWJc1aRqoR+pWxnmr
# EthngYTffwk8lOa4JiwgvT2zKIn3X/8i4peEH+ll74fg38FnSbNd67IJKusm7Xi+
# fT8r87cmNW1fiQG2SVufAQWbqz0lwcy2f8Lxb4bG+mRo64EtlOtCt/qMHt1i8b5Q
# Z7dsvfPxH2sMNgcWfzd8qVttevESRmCD1ycEvkvOl77DZypoEd+A5wwzZr8TDRRu
# 838fYxAe+o0bJW1sj6W3YQGx0qMmoRBxna3iw/nDmVG3KwcIzi7mULKn+gpFL6Lw
# 8jCCBSYwggQOoAMCAQICEAZY+tvHeDVvdG/HsafuSKwwDQYJKoZIhvcNAQELBQAw
# cjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQ
# d3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVk
# IElEIENvZGUgU2lnbmluZyBDQTAeFw0xOTEwMTUwMDAwMDBaFw0yMDEyMDQxMjAw
# MDBaMGMxCzAJBgNVBAYTAlVTMRIwEAYDVQQIEwlUZW5uZXNzZWUxEjAQBgNVBAcT
# CVR1bGxhaG9tYTEVMBMGA1UEChMMQ2FybCBXZWJzdGVyMRUwEwYDVQQDEwxDYXJs
# IFdlYnN0ZXIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDCib5DeGTG
# 3J70a2CA8i9n+dPsDklvWpkUTAuZesMTdgYYYKJTsaaNY/UEAHlJukWzaoFQUJc8
# cf5mUa48zGHKjIsFRJtv1YjaeoJzdLBWiqSaI6m3Ttkj8YqvAVj7U3wDNc30gWgU
# eJwPQs2+Ge6tVHRx7/Knzu12RkJ/fEUwoqwHyL5ezfBHfIf3AiukAxRMKrsqGMPI
# 20y/mc8oiwTuyCG9vieR9+V+iq+ATGgxxb+TOzRoxyFsYOcqnGv3iHqNr74y+rfC
# /HfkieCRmkwh0ss4EVnKIJMefWIlkH3HPirYn+4wmeTKQZmtIq0oEbJlXsSryOXW
# i/NjGfe2xXENAgMBAAGjggHFMIIBwTAfBgNVHSMEGDAWgBRaxLl7KgqjpepxA8Bg
# +S32ZXUOWDAdBgNVHQ4EFgQUqRd4UyWyhbxwBUPJhcJf/q5IdaQwDgYDVR0PAQH/
# BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMHcGA1UdHwRwMG4wNaAzoDGGL2h0
# dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQtY3MtZzEuY3JsMDWg
# M6Axhi9odHRwOi8vY3JsNC5kaWdpY2VydC5jb20vc2hhMi1hc3N1cmVkLWNzLWcx
# LmNybDBMBgNVHSAERTBDMDcGCWCGSAGG/WwDATAqMCgGCCsGAQUFBwIBFhxodHRw
# czovL3d3dy5kaWdpY2VydC5jb20vQ1BTMAgGBmeBDAEEATCBhAYIKwYBBQUHAQEE
# eDB2MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wTgYIKwYB
# BQUHMAKGQmh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFNIQTJB
# c3N1cmVkSURDb2RlU2lnbmluZ0NBLmNydDAMBgNVHRMBAf8EAjAAMA0GCSqGSIb3
# DQEBCwUAA4IBAQBMkLEdY3RRV97ghwUHUZlBdZ9dFFjBx6WB3rAGTeS2UaGlZuwj
# 2zigbOf8TAJGXiT4pBIZ17X01rpbopIeGGW6pNEUIQQlqaXHQUsY8kbjwVVSdQki
# c1ZwNJoGdgsE50yxPYq687+LR1rgViKuhkTN79ffM5kuqofxoGByxgbinRbC3PQp
# H3U6c1UhBRYAku/l7ev0dFvibUlRgV4B6RjQBylZ09+rcXeT+GKib13Ma6bjcKTq
# qsf9PgQ6P5/JNnWdy19r10SFlsReHElnnSJeRLAptk9P7CRU5/cMkI7CYAR0GWdn
# e1/Kdz6FwvSJl0DYr1p0utdyLRVpgHKG30bTMIIFMDCCBBigAwIBAgIQBAkYG1/V
# u2Z1U0O1b5VQCDANBgkqhkiG9w0BAQsFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UE
# ChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYD
# VQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3QgQ0EwHhcNMTMxMDIyMTIwMDAw
# WhcNMjgxMDIyMTIwMDAwWjByMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNl
# cnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdp
# Q2VydCBTSEEyIEFzc3VyZWQgSUQgQ29kZSBTaWduaW5nIENBMIIBIjANBgkqhkiG
# 9w0BAQEFAAOCAQ8AMIIBCgKCAQEA+NOzHH8OEa9ndwfTCzFJGc/Q+0WZsTrbRPV/
# 5aid2zLXcep2nQUut4/6kkPApfmJ1DcZ17aq8JyGpdglrA55KDp+6dFn08b7KSfH
# 03sjlOSRI5aQd4L5oYQjZhJUM1B0sSgmuyRpwsJS8hRniolF1C2ho+mILCCVrhxK
# hwjfDPXiTWAYvqrEsq5wMWYzcT6scKKrzn/pfMuSoeU7MRzP6vIK5Fe7SrXpdOYr
# /mzLfnQ5Ng2Q7+S1TqSp6moKq4TzrGdOtcT3jNEgJSPrCGQ+UpbB8g8S9MWOD8Gi
# 6CxR93O8vYWxYoNzQYIH5DiLanMg0A9kczyen6Yzqf0Z3yWT0QIDAQABo4IBzTCC
# AckwEgYDVR0TAQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAww
# CgYIKwYBBQUHAwMweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8v
# b2NzcC5kaWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRp
# Z2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwgYEGA1UdHwR6
# MHgwOqA4oDaGNGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3Vy
# ZWRJRFJvb3RDQS5jcmwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9E
# aWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcmwwTwYDVR0gBEgwRjA4BgpghkgBhv1s
# AAIEMCowKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMw
# CgYIYIZIAYb9bAMwHQYDVR0OBBYEFFrEuXsqCqOl6nEDwGD5LfZldQ5YMB8GA1Ud
# IwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3zbcgPMA0GCSqGSIb3DQEBCwUAA4IBAQA+
# 7A1aJLPzItEVyCx8JSl2qB1dHC06GsTvMGHXfgtg/cM9D8Svi/3vKt8gVTew4fbR
# knUPUbRupY5a4l4kgU4QpO4/cY5jDhNLrddfRHnzNhQGivecRk5c/5CxGwcOkRX7
# uq+1UcKNJK4kxscnKqEpKBo6cSgCPC6Ro8AlEeKcFEehemhor5unXCBc2XGxDI+7
# qPjFEmifz0DLQESlE/DmZAwlCEIysjaKJAL+L3J+HNdJRZboWR3p+nRka7LrZkPa
# s7CM1ekN3fYBIM6ZMWM9CBoYs4GbT8aTEAb8B4H6i9r5gkn3Ym6hU/oSlBiFLpKR
# 6mhsRDKyZqHnGKSaZFHvMIIGajCCBVKgAwIBAgIQAwGaAjr/WLFr1tXq5hfwZjAN
# BgkqhkiG9w0BAQUFADBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQg
# SW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2Vy
# dCBBc3N1cmVkIElEIENBLTEwHhcNMTQxMDIyMDAwMDAwWhcNMjQxMDIyMDAwMDAw
# WjBHMQswCQYDVQQGEwJVUzERMA8GA1UEChMIRGlnaUNlcnQxJTAjBgNVBAMTHERp
# Z2lDZXJ0IFRpbWVzdGFtcCBSZXNwb25kZXIwggEiMA0GCSqGSIb3DQEBAQUAA4IB
# DwAwggEKAoIBAQCjZF38fLPggjXg4PbGKuZJdTvMbuBTqZ8fZFnmfGt/a4ydVfiS
# 457VWmNbAklQ2YPOb2bu3cuF6V+l+dSHdIhEOxnJ5fWRn8YUOawk6qhLLJGJzF4o
# 9GS2ULf1ErNzlgpno75hn67z/RJ4dQ6mWxT9RSOOhkRVfRiGBYxVh3lIRvfKDo2n
# 3k5f4qi2LVkCYYhhchhoubh87ubnNC8xd4EwH7s2AY3vJ+P3mvBMMWSN4+v6GYeo
# fs/sjAw2W3rBerh4x8kGLkYQyI3oBGDbvHN0+k7Y/qpA8bLOcEaD6dpAoVk62RUJ
# V5lWMJPzyWHM0AjMa+xiQpGsAsDvpPCJEY93AgMBAAGjggM1MIIDMTAOBgNVHQ8B
# Af8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDCC
# Ab8GA1UdIASCAbYwggGyMIIBoQYJYIZIAYb9bAcBMIIBkjAoBggrBgEFBQcCARYc
# aHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzCCAWQGCCsGAQUFBwICMIIBVh6C
# AVIAQQBuAHkAIAB1AHMAZQAgAG8AZgAgAHQAaABpAHMAIABDAGUAcgB0AGkAZgBp
# AGMAYQB0AGUAIABjAG8AbgBzAHQAaQB0AHUAdABlAHMAIABhAGMAYwBlAHAAdABh
# AG4AYwBlACAAbwBmACAAdABoAGUAIABEAGkAZwBpAEMAZQByAHQAIABDAFAALwBD
# AFAAUwAgAGEAbgBkACAAdABoAGUAIABSAGUAbAB5AGkAbgBnACAAUABhAHIAdAB5
# ACAAQQBnAHIAZQBlAG0AZQBuAHQAIAB3AGgAaQBjAGgAIABsAGkAbQBpAHQAIABs
# AGkAYQBiAGkAbABpAHQAeQAgAGEAbgBkACAAYQByAGUAIABpAG4AYwBvAHIAcABv
# AHIAYQB0AGUAZAAgAGgAZQByAGUAaQBuACAAYgB5ACAAcgBlAGYAZQByAGUAbgBj
# AGUALjALBglghkgBhv1sAxUwHwYDVR0jBBgwFoAUFQASKxOYspkH7R7for5XDStn
# As0wHQYDVR0OBBYEFGFaTSS2STKdSip5GoNL9B6Jwcp9MH0GA1UdHwR2MHQwOKA2
# oDSGMmh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRENB
# LTEuY3JsMDigNqA0hjJodHRwOi8vY3JsNC5kaWdpY2VydC5jb20vRGlnaUNlcnRB
# c3N1cmVkSURDQS0xLmNybDB3BggrBgEFBQcBAQRrMGkwJAYIKwYBBQUHMAGGGGh0
# dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBBBggrBgEFBQcwAoY1aHR0cDovL2NhY2Vy
# dHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEQ0EtMS5jcnQwDQYJKoZI
# hvcNAQEFBQADggEBAJ0lfhszTbImgVybhs4jIA+Ah+WI//+x1GosMe06FxlxF82p
# G7xaFjkAneNshORaQPveBgGMN/qbsZ0kfv4gpFetW7easGAm6mlXIV00Lx9xsIOU
# GQVrNZAQoHuXx/Y/5+IRQaa9YtnwJz04HShvOlIJ8OxwYtNiS7Dgc6aSwNOOMdgv
# 420XEwbu5AO2FKvzj0OncZ0h3RTKFV2SQdr5D4HRmXQNJsQOfxu19aDxxncGKBXp
# 2JPlVRbwuwqrHNtcSCdmyKOLChzlldquxC5ZoGHd2vNtomHpigtt7BIYvfdVVEAD
# kitrwlHCCkivsNRu4PQUCjob4489yq9qjXvc2EQwggbNMIIFtaADAgECAhAG/fkD
# lgOt6gAK6z8nu7obMA0GCSqGSIb3DQEBBQUAMGUxCzAJBgNVBAYTAlVTMRUwEwYD
# VQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xJDAi
# BgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQgUm9vdCBDQTAeFw0wNjExMTAwMDAw
# MDBaFw0yMTExMTAwMDAwMDBaMGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdp
# Q2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERp
# Z2lDZXJ0IEFzc3VyZWQgSUQgQ0EtMTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
# AQoCggEBAOiCLZn5ysJClaWAc0Bw0p5WVFypxNJBBo/JM/xNRZFcgZ/tLJz4Flnf
# nrUkFcKYubR3SdyJxArar8tea+2tsHEx6886QAxGTZPsi3o2CAOrDDT+GEmC/sfH
# MUiAfB6iD5IOUMnGh+s2P9gww/+m9/uizW9zI/6sVgWQ8DIhFonGcIj5BZd9o8dD
# 3QLoOz3tsUGj7T++25VIxO4es/K8DCuZ0MZdEkKB4YNugnM/JksUkK5ZZgrEjb7S
# zgaurYRvSISbT0C58Uzyr5j79s5AXVz2qPEvr+yJIvJrGGWxwXOt1/HYzx4KdFxC
# uGh+t9V3CidWfA9ipD8yFGCV/QcEogkCAwEAAaOCA3owggN2MA4GA1UdDwEB/wQE
# AwIBhjA7BgNVHSUENDAyBggrBgEFBQcDAQYIKwYBBQUHAwIGCCsGAQUFBwMDBggr
# BgEFBQcDBAYIKwYBBQUHAwgwggHSBgNVHSAEggHJMIIBxTCCAbQGCmCGSAGG/WwA
# AQQwggGkMDoGCCsGAQUFBwIBFi5odHRwOi8vd3d3LmRpZ2ljZXJ0LmNvbS9zc2wt
# Y3BzLXJlcG9zaXRvcnkuaHRtMIIBZAYIKwYBBQUHAgIwggFWHoIBUgBBAG4AeQAg
# AHUAcwBlACAAbwBmACAAdABoAGkAcwAgAEMAZQByAHQAaQBmAGkAYwBhAHQAZQAg
# AGMAbwBuAHMAdABpAHQAdQB0AGUAcwAgAGEAYwBjAGUAcAB0AGEAbgBjAGUAIABv
# AGYAIAB0AGgAZQAgAEQAaQBnAGkAQwBlAHIAdAAgAEMAUAAvAEMAUABTACAAYQBu
# AGQAIAB0AGgAZQAgAFIAZQBsAHkAaQBuAGcAIABQAGEAcgB0AHkAIABBAGcAcgBl
# AGUAbQBlAG4AdAAgAHcAaABpAGMAaAAgAGwAaQBtAGkAdAAgAGwAaQBhAGIAaQBs
# AGkAdAB5ACAAYQBuAGQAIABhAHIAZQAgAGkAbgBjAG8AcgBwAG8AcgBhAHQAZQBk
# ACAAaABlAHIAZQBpAG4AIABiAHkAIAByAGUAZgBlAHIAZQBuAGMAZQAuMAsGCWCG
# SAGG/WwDFTASBgNVHRMBAf8ECDAGAQH/AgEAMHkGCCsGAQUFBwEBBG0wazAkBggr
# BgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUFBzAChjdo
# dHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290
# Q0EuY3J0MIGBBgNVHR8EejB4MDqgOKA2hjRodHRwOi8vY3JsMy5kaWdpY2VydC5j
# b20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMDqgOKA2hjRodHRwOi8vY3Js
# NC5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMB0GA1Ud
# DgQWBBQVABIrE5iymQftHt+ivlcNK2cCzTAfBgNVHSMEGDAWgBRF66Kv9JLLgjEt
# UYunpyGd823IDzANBgkqhkiG9w0BAQUFAAOCAQEARlA+ybcoJKc4HbZbKa9Sz1Lp
# MUerVlx71Q0LQbPv7HUfdDjyslxhopyVw1Dkgrkj0bo6hnKtOHisdV0XFzRyR4WU
# VtHruzaEd8wkpfMEGVWp5+Pnq2LN+4stkMLA0rWUvV5PsQXSDj0aqRRbpoYxYqio
# M+SbOafE9c4deHaUJXPkKqvPnHZL7V/CSxbkS3BMAIke/MV5vEwSV/5f4R68Al2o
# /vsHOE8Nxl2RuQ9nRc3Wg+3nkg2NsWmMT/tZ4CMP0qquAHzunEIOz5HXJ7cW7g/D
# vXwKoO4sCFWFIrjrGBpN/CohrUkxg0eVd3HcsRtLSxwQnHcUwZ1PL1qVCCkQJjGC
# BAMwggP/AgEBMIGGMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJ
# bmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0
# IFNIQTIgQXNzdXJlZCBJRCBDb2RlIFNpZ25pbmcgQ0ECEAZY+tvHeDVvdG/Hsafu
# SKwwCQYFKw4DAhoFAKBAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMCMGCSqG
# SIb3DQEJBDEWBBQi7Nu1RXI9VuUeRZAgNfYo0zbBYjANBgkqhkiG9w0BAQEFAASC
# AQCiUIyHllKPavhs4KY58d/nnK1YGqpx9Jslgev6CEujit9Q4EJSK4b3sRPuRQ8b
# n0ZMSuqcRTI4VBQAdO3MlczdSYqiRkjYNt07Yp4uVjYUJFOCmLSLRa9DFJY0f1Iq
# F9EntDdI3U7gHTuiWrly5YEKLaE/WHet2ugMqN6NyFFgm3U9534Kjuhj63ddeG7I
# AlA+ijS1kLvk042roIsrQkqM8mZNhec76ehBR/Nl5QNPQ7H85i/lOHToYEWBOue6
# sI0HWdS2jzwx6c26jXHDAuIXVX7pWJqK2Mc75xEQdTR39s2SVRx+SsvhuqJ+KU4l
# U/5/7n544/6oBcGX2238KQv+oYICDzCCAgsGCSqGSIb3DQEJBjGCAfwwggH4AgEB
# MHYwYjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UE
# CxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgQXNzdXJlZCBJ
# RCBDQS0xAhADAZoCOv9YsWvW1ermF/BmMAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0B
# CQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yMDEwMzExNDAwMDNaMCMG
# CSqGSIb3DQEJBDEWBBTQ/MkPGrt+56a0tuLV8e45pdHiHDANBgkqhkiG9w0BAQEF
# AASCAQAbYHZ898GPP3adUHsm/V1fsR77iue2guUh2NQ8trE/5mvcGfO2kTBahpRJ
# pP825cwt9I309NIadbOfJYEIjWIm4LN1Hzf41pVbYKRF8/pDKoXfbC/79FYJXhty
# qhQMcwzrmRAORBLN8KC6Pj0BZ3GTjqgRpvyfn+otIF0HK/QTrmDzspsACj/DOGzp
# dKDhJ5Q28JE13PIyULgRhnEf7z4YFdRa6LCh+jZjynVKOFLk0FC0g2N8OPNtrY4K
# FO9SHpCaKzcFGXPYzcb86TOiiEZ1PDAaM0AinkUTiyhtcyMD+n8KkjzNAB/Gzs1o
# jYL6cuoNR2M6yLidnMHFIpNp3Afx
# SIG # End signature block
