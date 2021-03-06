<#
    .SYNOPSIS
        Update Time and Reapply GPO
	.Description
    .EXAMPLE
    .Inputs
    .Outputs
    .NOTES
		Author: Benjamin Ruoff
      	Company: Login Consultants Germany GmbH
		
		History
      	Last Change: 27.10.2014 BR: Script created
		Last Change: 15.10.2014 JP: added wait:0 parameter fo gpupdate
		Last Change: 06.10.2015 MS: rewritten script with standard .SYNOPSIS
		Last Change: 26.10.2015 BR: Delay between Timesync and GPO apply
		Last Change: 02.08.2016 MS: with AppLayering in OS-Layer do nothing
		Last Change: 31.08.2017 MS: change sleep timer from 60 to 5 seconds after time sync on startup
		Last Change: 11.09.2017 MS: change sleep timer from 5 to 20 seconds after time sync on startup
	.Link
#>


Begin {

	}


Process {
	IF (!($CTXAppLayerName -eq "OS-Layer"))
	{
		# Resync Time with Domain
		Write-BISFLog -Msg "Syncing Time from Domain" 
		& "$env:SystemRoot\system32\w32tm.exe" /config /update
		& "$env:SystemRoot\system32\w32tm.exe" /resync /nowait
		sleep 20
		# Reapply Computer GPO
		Write-BISFLog "Apply Computer GPO"
		& "$env:SystemRoot\system32\gpupdate.exe" /Target:Computer /Force /Wait:0
	} ELSE {
		Write-BISFLog -Msg "Do nothing in AppLayering $CTXAppLayerName"
	}
}


End {
	Add-BISFFinishLine
}

 
