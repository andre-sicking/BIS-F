<#
    .SYNOPSIS
        Prepare SCCM Client for Image Managemement
	.Description
      	Delete Computer specified entries
    .EXAMPLE
    .Inputs
    .Outputs
    .NOTES
		Author: Matthias Schlimm
      	Company: Login Consultants Germany GmbH

		History
      	Last Change: 26.03.2014 MS: Script created for SCCM 2012 R2
		Last Change: 01.04.2014 MS: Change Console message
		Last Change: 02.05.2014 MS: BUG code-error certstore SMS not deleted > & Invoke-Expression 'certutil -delstore SMS "SMS"'
		Last Change: 11.08.2014 MS: Remove Write-Host change to Write-BISFLog
		Last Change: 13.08.2014 MS: Remove $logfile = Set-logFile, it would be used in the 10_XX_LIB_Config.ps1 Script only
		Last Change: 19.02.2015 MS: Syntax error and error handling
		Last Change: 06.03.2015 MS: Delete CCM Package Cache
		Last Change: 05.05.2015 MS: #temp. deactivate Remove-CCMCache , some errors more testing
		Last Change: 01.09.2015 MS: Bugfix 42 - fixing deleteCCMCahce, this must be running before service stops
		Last Change: 30.09.2015 MS: Rewritten script with standard .SYNOPSIS, use central BISF function to configure service
		Last Change: 10.05.2019 JP: Added command to remove hardware inventory as recommended by Citrix https://support.citrix.com/article/CTX238513
		Last Change: 10.05.2019 JP: Converted wmic commands to Get-WmiObject and reworked script synthax
	.Link
#>


Begin {
	$PSScriptFullName = $MyInvocation.MyCommand.Path
	$PSScriptRoot = Split-Path -Parent $PSScriptFullName
	$PSScriptName = [System.IO.Path]::GetFileName($PSScriptFullName)
	$Product = "Microsoft SCCM Agent"
	$ProductPath = "$env:windir\CCM"
	$ServiceName = "CcmExec"
}


Process {
    Function Remove-CCMData
    {
		Write-BISFLog -Msg "Delete Smscfg.ini"
		Remove-Item -Path "$env:windir\SMSCFG.ini" -Force -ErrorAction SilentlyContinue

		Write-BISFLog -Msg "Remove existing certificates from SMS store"
		Remove-Item -Path HKLM:\Software\Microsoft\SystemCertificates\SMS\Certificates\* -Force

		Write-BISFLog -Msg "Reset site key information"
		Get-WmiObject -Namespace "root\ccm\locationservices" -Class TrustedRootKey | Remove-WmiObject

		Write-BISFLog -Msg "Delete hardware inventory"
		Get-WmiObject -Namespace "root\ccm\invagt" -Class InventoryActionStatus | Where {$_.InventoryActionID -eq "{00000000-0000-0000-0000-000000000001}"} | Remove-WmiObject

		Write-BISFLog -Msg "Delete scheduler history"
		Get-WmiObject -Namespace "root\ccm\scheduler" -Class CCM_Scheduler_History | Where {$_.ScheduleID -eq "{00000000-0000-0000-0000-000000000001}"} | Remove-WmiObject
	}

    Function Remove-CCMCache
    {
        #Original source http://www.david-obrien.net/2013/02/how-to-configure-the-configmgr-client/
        [CmdletBinding()]
        $UIResourceMgr = New-Object -ComObject UIResource.UIResourceMgr
        $Cache=$UIResourceMgr.GetCacheInfo()
        $CacheElements=$Cache.GetCacheElements()
        foreach ($Element in $CacheElements)
        {
            Write-BISFLog -Msg "Deleting CacheElement with PackageID $($Element.ContentID)"
            Write-BISFLog -Msg "in folder location $($Element.Location)"
            $Cache.DeleteCacheElement($Element.CacheElementID)
         }
    }

	If (Test-BISFService -ServiceName $ServiceName -eq $True)
	{
		Remove-CCMCache #01.09.2015 MS: Remove-CCMCache  must be running before StopService
		Invoke-BISFService -ServiceName "$ServiceName" -Action Stop -StartType manual
		Remove-CCMData
	}
}

End {
	Add-BISFFinishLine
}