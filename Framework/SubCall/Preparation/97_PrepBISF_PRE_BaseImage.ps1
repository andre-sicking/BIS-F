[CmdletBinding(SupportsShouldProcess = $true)]
param(
)
    <#
    .Synopsis
      prepare Base Image System
    .Description
    .EXAMPLE
    .Inputs
    .Outputs
    .NOTES
      Author: Matthias Schlimm
      Editor: Mike Bijl (Rewritten variable names and script format)
      Company: Login Consultants Germany GmbH

      Date: 27.09.2012

      History
      Last Change: 27.09.2012 MS: Script created
      Last Change: 10.10.2012 MS: Removed slmgr.vbs /rearm - write it into extra script
      Last Change: 17.10.2012 MS: Removed chkdsk /F - because it would like to run at next start
      Last Change: 04.02.2013 MS: Added Get-ChildItem -Path $CTX_SYS32_CACHE_PATH -filter * -Recurse | foreach ($_) {remove-item $_.fullname}
      Last Change: 18.09.2013 MS: Replaced $date with $(Get-date) to get current timestamp at running scriptlines write to the logfile
      Last Change: 18.09.2013 MS: Added startup scheduled task to personalize system
      Last Change: 17.12.2013 MS: ARP Cache Changes – Windows 2008 / Vista / Windows 7, see http://support.citrix.com/article/ctx127549 for further details"
      Last Change: 28.01.2014 MS: Added ErrorAction to "Remove-Item -Path '$CTX_SYS32_CACHE_PATH' -Recurse -ErrorAction SilentlyContinue"
      Last Change: 28.01.2014 MS: Removed ipconfig /release
      Last Change: 28.01.2014 MS: Changed executionpoliy unrestricted for Line 36
      Last Change: 11.03.2014 MS: Read language specified adapter name to support mui installations for each customer, thanks to Benny Ruoff
      Last Change: 18.03.2014 BR: Revisited Script
      Last Change: 01.04.2014 MS: Added array to remove WindowsUpdateInformations
      Last Change: 02.04.2014 MS: [array]$PreMSG  = "N"   #<<-- display a messagebox to perform these step, set Y = YES or N = NO
      Last Change: 02.04.2014 MS: Added Question to run Defrag on Systemdisk
      Last Change: 02.04.2014 MS: Added Question to run Sysinternals SDelete to zero out empty vDisk areas and reduce storage
      Last Change: 13.05.2014 MS: Added multihoming support to read adaptername from each network,  see line 80
      Last Change: 13.05.2014 MS: Added PreCLI commands for silent action
      Last Change: 15.05.2014 MS: Changed console output to get-adaptername, line 91 -> Write-BISFLog -Msg  "Read AdapterName: $element"
      Last Change: 13.08.2014 MS: Removed $logfile = Set-logFile, it would be used in the 10_XX_LIB_Config.ps1 Script only
      Last Change: 14.08.2014 MS: Removed CLI-Command to show on console, send to logfile only
      Last Change: 13.10.2014 MS: Check WSUS Client-Side-Targeting to delete ClientID or set Service to manual
      Last Change: 09.02.2015 MS: Use NimbleFastReclaim instead of SDelete
      Last Change: 09.02.2015 JP/MS: Clear the Windows event logs
      Last Change: 09.02.2015 JP/MS: Added Question to run CCleaner
      Last Change: 12.12.2015 MS: Added question to run reset perfomance Counters
      Last Change: 14.04.2015 MS: Removed defrag, now it performed on the vDisk in the POST Script
      Last Change: 18.05.2015 MS: Added CLI Switch VERYSILENT handling
      Last Change: 20.05.2015 MS: Feature 45; W2012 R2 only - fix No remote Desktop Licence Server availible on RD Session Host server 2012
      Last Change: 08.06.2015 MS: Executing all queued .NET compilation jobs - Precompiling assemblies with Ngen.exe can improve the startup time for some applications.
      Last Change: 21.07.2015 BR: Edited Path $Dir_SwDistriPath, attended "Download"
      Last Change: 10.08.2015 MS: Bug 62; Added new function Write-ZeroesToFreeSpace instead of NimbleFastReclaim -> buggy on W2012R2
      Last Change: 11.08.2015 BR: Disable Windows Update Service
      Last Change: 11.08.2015 MS: Fixed code error at line 98 -> $NgenPath = Get-ChildItem -Path 'c:\windows\Microsoft.NET' -Recurse "ngen.exe" | % {$_.FullName}
	  Last Change: 01.10.2015 MS: Rewritten script to use central BISF function
	  Last Change: 04.11.2015 MS: Added CLI switch -DelAllUsersStartMenu to delete all Objects in C:\ProgramData\Microsoft\Windows\Start Menu\*
	  Last Change: 25.11.2015 MS: Stop DHCP client Service, see https://www.citrix.com/blogs/2015/09/29/pvs-target-devices-the-blue-screen-of-death-rest-easy-we-can-fix-that/
	  Last Change: 25.11.2015 MS: Added clear DHCP entries of Networkadapter, to prevent BlueScreen on some PVS Targetdevices https://www.citrix.com/blogs/2015/09/29/pvs-target-devices-the-blue-screen-of-death-rest-easy-we-can-fix-that/
	  Last Change: 25.11.2015 MS: Reset Distributed Transaction Coordinator service if installed
	  Last Change: 15.12.2015 MS: Feature 96; Added VMware Tools optimizations, thx to Ingmar Verheij - http://www.ingmarverheij.com
	  Last Change: 16.12.2015 MS: Feature 99; Added Disable Task offload, thx to Ingmar Verheij - http://www.ingmarverheij.com
	  Last Change: 16.12.2015 MS: Feature 99; Added increases the UDP packet size to 1500 bytes for FastSend - http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2040065, thx to Ingmar Verheij - http://www.ingmarverheij.com
	  Last Change: 16.12.2015 MS: Feature 99; Added set multiplication factor to the default UDP scavenge value (MaxEndpointCountMult), http://support.microsoft.com/kb/2685007/en-us , thx to Ingmar Verheij - http://www.ingmarverheij.com
	  Last Change: 16.12.2015 MS: Feature 99; Added disable Receive Side Scaling (RSS), http://support.microsoft.com/kb/951037/en-us , thx to Ingmar Verheij - http://www.ingmarverheij.com
	  Last Change: 16.12.2015 MS: Feature 99; Added disable IPv6 completely , thx to Ingmar Verheij - http://www.ingmarverheij.com
	  Last Change: 16.12 2015 MS: Feature 97; Added Hide PVS status icon, http://forums.citrix.com/thread.jspa?threadID=273278, , thx to Ingmar Verheij - http://www.ingmarverheij.com
	  Last Change: 16.12.2015 MS: Feature 100; Disable Windows Services, thx to Thomas Krampe
	  Last Change: 16.12.2015 MS: Feature 100; Disable useless Scheduled tasks, thx to Thomas Krampe
	  Last Change: 16.12.2015 MS: Feature 100; Win8 only, run disk cleanup, thx to Thomas Krampe
	  Last Change: 16.12.2015 MS: Feature 100; Added Disable Data Execution Prevention, Disable Startup Repair option, Disable New Network dialog, Set Power Saving Scheme to High Performance, , thx to Thomas Krampe
	  Last Change: 07.01.2016 MS: Feature 79; Added Optimize-BISFWinSxs to cleanup and reduce WinSxs Folder
	  Last Change: 20.01.2016 MS: Fix for Feature 99; Wrong Dword to completly disable IPv6 - 0x000000FF, thanks to Jonathan Pitre
      Last Change: 20.01.2016 MS: Fix for DelAllUsersStartMenu, typos in variable
	  Last Change: 10.03.2016 MS: Issue 111; use nvspbind.exe to unbind IPV6 from AdapterGuid
	  Last Change: 10.03.2016 MS: Added Delprof2.exe support
	  Last Change: 22.03.2016 MS: Changed SDelete to run on the WriteCacheDisk on PVS Target Devices only
	  Last Change: 24.03.2016 MS: Modified BIS-F scheduled task if even exist, thx to Valentino Pemoni
	  Last Change: 10.11.2016 MS: Added Pre-Commands for Windows Server 2016 and Windows 10
	  Last Change: 11.11.2016 MS: Create-BISFTask running in own function
      Last Change: 05.12.2016 MS: Bug fix: defrag not identify the right driveletter of the vDisk after P2PVS, if the Drivelabel is empty
      Last Change: 05.12.2016 MS: Variables must be cleared after each step, to not store the value in the variable and use them in the next $prepCommand
      Last Change: 01.13.2017 JP: Fixed the Disk Cleanup/WinSxS functions, added support for Windows 7 and 2008 R2
	  Last Change: 21.02.2017 MS: Create BIS-F Adminshortcut on personal Desktop
	  Last Change: 06.03.2017 MS: Bug Fix: Detecting WSUS TargetGroup
	  Last Change: 06.03.2017 MS: Get FileVersion of Testpath for 3rd Party Apps
	  Last Change: 07.03.2017 JP: Fixed typos and trailing space
	  Last Change: 08.03.2017 MS: Syntax error Line 654: $varCLI = $($prepCommand.CLI)
	  Last Change: 13.03.2017 MS: extend unneeded services for Win10 and Server 2016 to disable
	  Last Change: 13.03.2017 MS: extend unneeded scheduled tasks for Win10 and Server 2016 to disable
	  Last Change: 13.03.2017 MS: Disable Cortana for Win10 and Server 2016
	  Last Change: 16.03.2017 FF: Bugfix for useless Service / Scheduled Task Disable
	  Last Change: 11.04.2017 MS: Bugfix in Line 659 using $prepCommand insted of $PostCommand
	  Last Change: 29.07.2017 MS: add schedule Task "ServerCeipAssistant" to disable, thx to Trentent Tye
	  Last Change: 01.08.2017 MS: 3rd Party tools like sdelete, ccleaner, nvpsbind, delprof2, using custom searchfolder from ADMX if enabled
	  Last Change: 01.08.2017 MS: add Progressbar for .NET Optimization
	  Last Change: 02.08.2017 MS: delprof2 - get custom arguments from ADMX or use default value
	  Last Change: 22.08.2017 MS: create or update BIS-F schedule Task to run with highest privileges, thx to Brandon Mitchgell
	  Last Change: 22.08.2017 MS: clenup various directories, like temp, thx to Trentent Tye
	  Last Change: 31.08.2017 MS: Clear all Eventlogs
	  Last Change: 07.11.2017 MS: add $LIC_BISF_3RD_OPT = $false, if vmOSOT or CTXO is enabled and found, $LIC_BISF_3RD_OPT = $true and disable BIS-F own optimizations
	  Last Change: 10.11.2017 MS: Feature: .NET Optimization to run if enabled or not configured in ADMX
	  Last Change: 19.10.2018 MS: Bugfix 71: not to process ANY scheduled task disable actions
	  Last Change: 20.10.2018 MS: Bugfix 56: Office click to run issue after BIS-F seal



	  .Link
    #>

Begin {

    ####################################################################
    # define environment
    # Setting default variables ($PSScriptroot/$logfile/$PSCommand,$PSScriptFullname/$scriptlibrary/LogFileName) independent on running script from console or ISE and the powershell version.
    If ($($host.name) -like "* ISE *") { # Running script from Windows Powershell ISE
        $PSScriptFullName = $psise.CurrentFile.FullPath.ToLower()
        $PSCommand = (Get-PSCallStack).InvocationInfo.MyCommand.Definition
    } ELSE {
        $PSScriptFullName = $MyInvocation.MyCommand.Definition.ToLower()
        $PSCommand = $MyInvocation.Line
    }
    [string]$PSScriptName = (Split-Path $PSScriptFullName -leaf).ToLower()
    If (($PSScriptRoot -eq "") -or ($PSScriptRoot -eq $null)) { [string]$PSScriptRoot = (Split-Path $PSScriptFullName).ToLower()}

    ####################################################################
    # define environment
    $PreMSG = @()
    $PreTXT = @()
    $PreCMD = @()
    $PreCLI = @()
    $CTX_SYS32_CACHE_PATH = "C:\Program Files (x86)\Citrix\System32\Cache\*"
    $REG_hklm_WSUS = "$hklm_software\Microsoft\Windows\CurrentVersion\WindowsUpdate"
    $REG_hklm_Pol_WSUS = "$hklm_software\Policies\Microsoft\Windows\WindowsUpdate"
	$REG_hku_HP = "$hku_software\Hewlett-Packard\"
    $WSUS_TargetGroupEnabled = (Get-ItemProperty "$REG_hklm_Pol_WSUS" -Name "TargetGroupEnabled").TargetGroupEnabled
	$Dir_SwDistriPath = "C:\Windows\SoftwareDistribution\Download\*"
    $File_WindowsUpdateLog = "C:\Windows\WindowsUpdate.log"
	$Dir_AllUsersStartMenu = "C:\ProgramData\Microsoft\Windows\Start Menu\*"
	$Global:BISFtask="LIC_BISF_Device_Personalize"

	#Processing CLI commands to get 3rd Party custom searchfolders
	#ccleaner
	IF ($LIC_BISF_CLI_CC_SF -eq "1") {$SearchFoldersCC = $LIC_BISF_CLI_CC_SF_CUS } ELSE {$SearchFoldersCC = "$($env:ProgramFiles)\CCleaner"}
	#delprof2
	IF ($LIC_BISF_CLI_DP_SF -eq "1") {$SearchFoldersDP = $LIC_BISF_CLI_DP_SF_CUS } ELSE {$SearchFoldersDP = "C:\Windows\system32"}
	IF ($LIC_BISF_CLI_DP_Args -eq "1") {$DPargs = $LIC_BISF_CLI_DP_ARGS_CUS } ELSE {$DPargs = "/u /r"}

	#nvpsbind (IPV6)
	IF ($LIC_BISF_CLI_V6_SF -eq "1") {$SearchFoldersV6 = $LIC_BISF_CLI_V6_SF_CUS } ELSE {$SearchFoldersV6 = "C:\Windows\system32"}
	#sdelete
	IF ($LIC_BISF_CLI_SD_SF -eq "1") {$SearchFoldersSD = $LIC_BISF_CLI_SD_SF_CUS } ELSE {$SearchFoldersSD = "C:\Windows\system32"}

	Write-BISFLog -Msg "Preparing Array of PreCommands... please wait" -ShowConsole -Color Cyan
    # All commands that are used to prepare for building the vDisk
    $ordercnt = 10
	[array]$PrepCommands = @()

		$PrepCommands += [pscustomobject]@{
			Order="$ordercnt";
			Enabled="$true";
			showmessage="N";
			CLI="";
			TestPath ="";
			Description="Delete all Citrix Cached files $CTX_SYS32_CACHE_PATH";
			Command="Remove-Item -Path '$CTX_SYS32_CACHE_PATH' -Recurse -ErrorAction SilentlyContinue"};
			$ordercnt += 1

		$PrepCommands += [pscustomobject]@{
			Order="$ordercnt";
			Enabled="$true";
			showmessage="N";
			CLI="";
			TestPath ="";
			Description="Delete SoftwareDistribution $Dir_SwDistriPath";
			Command="Remove-Item -Path '$Dir_SwDistriPath' -Recurse -ErrorAction SilentlyContinue"};
			$ordercnt += 1

		$PrepCommands += [pscustomobject]@{
			Order="$ordercnt";
			Enabled="$true";
			showmessage="N";
			CLI="";
			TestPath ="";
			Description="Delete Windows Update Log $File_WindowsUpdateLog";
			Command="Remove-Item '$File_WindowsUpdateLog' -ErrorAction SilentlyContinue"};
			$ordercnt += 1

        $PrepCommands += [pscustomobject]@{
			Order="$ordercnt";
			Enabled="$true";
			showmessage="Y";
			CLI="LIC_BISF_CLI_SM";
			TestPath ="";
			Description="Delete AllUsers Start Menu $Dir_AllUsersStartMenu ?";
			Command="Remove-Item '$Dir_AllUsersStartMenu' -Recurse -Force -ErrorAction SilentlyContinue"};
			$ordercnt += 1

		$PrepCommands += [pscustomobject]@{
			Order="$ordercnt";
			Enabled="$true";
			showmessage="Y";
			CLI="LIC_BISF_CLI_DP";
			TestPath ="$($SearchFoldersDP)\delprof2.exe";
			Description="Run Delprof2 to deletes inactive user profiles ?";
			Command="$($SearchFoldersDP)\delprof2.exe $($DPargs)"};
			$ordercnt += 1

		$PrepCommands += [pscustomobject]@{
			Order="$ordercnt";
			Enabled="$true";
			showmessage="N";
			CLI="";
			TestPath ="";
			Description="Purge DNS resolver Cache";
			Command="ipconfig /flushdns"};
			$ordercnt += 1

		$PrepCommands += [pscustomobject]@{
			Order="$ordercnt";
			Enabled="$true";
			showmessage="N";
			CLI="";
			TestPath ="";
			Description="Purge IP-to-Physical address translation tables Cache (ARP Table)";
			Command="arp -d *"};
			$ordercnt += 1

        $PrepCommands += [pscustomobject]@{
			Order="$ordercnt";
			Enabled="$true";
			showmessage="Y";
			CLI="LIC_BISF_CLI_CC";
			TestPath = "$($SearchFoldersCC)\CCleaner.exe" ;
			Description="Run CCleaner to clean temp files";
			Command="Start-BISFProcWithProgBar -ProcPath '$($SearchFoldersCC)\CCleaner.exe' -Args '/AUTO' -ActText 'CCleaner is running'"};
			$ordercnt += 1

        $PrepCommands += [pscustomobject]@{
			Order="$ordercnt";
			Enabled="$true";
			showmessage="Y";
			CLI="LIC_BISF_CLI_PF";
			TestPath ="";
			Description="Reset Performance Counters";
			Command="lodctr.exe /r"};
			$ordercnt += 1

        $PrepCommands += [pscustomobject]@{
			Order="$ordercnt";
			Enabled="$true";
			showmessage="N";
			CLI="";
			TestPath ="";
			Description="Clear all event logs";
			Command="'wevtutil el | Foreach-Object {wevtutil cl $_}'"};
			$ordercnt += 1
		IF ($LIC_BISF_3RD_OPT -eq $false)
		{
			$PrepCommands += [pscustomobject]@{
				Order="$ordercnt";
				Enabled="$true";
				showmessage="N";
				CLI="";
				TestPath ="";
				Description="Disabling TCP/IP task offloading";
				Command="Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' -Name 'DisableTaskOffload' -Value '1' -Type DWORD"};
				$ordercnt += 1
		} ELSE {
			Write-BISFLog -Msg "TCP/IP task offloading not optimized from BIS-F, because 3rd Party Optimization is configured" -Type W -ShowConsole -SubMsg
		}

		IF ($LIC_BISF_3RD_OPT -eq $false)
		{
			$PrepCommands += [pscustomobject]@{
				Order="$ordercnt";
				Enabled="$true";
				showmessage="N";
				CLI="";
				TestPath ="";
				Description="Increases the UDP packet size to 1500 bytes for FastSend";
				Command="Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\afd\Parameters' -Name 'FastSendDatagramThreshold' -Value '1500' -Type DWORD"};
				$ordercnt += 1
		} ELSE {
			Write-BISFLog -Msg "Increases the UDP packet size to 1500 bytes for FastSend not optimized from BIS-F, because 3rd Party Optimization is configured" -Type W -ShowConsole -SubMsg
		}

		IF ($LIC_BISF_3RD_OPT -eq $false)
		{
			$PrepCommands += [pscustomobject]@{
				Order="$ordercnt";
				Enabled="$true";
				showmessage="N";
				CLI="";
				TestPath ="";
				Description="Set multiplication factor to the default UDP scavenge value (MaxEndpointCountMult)";
				Command="Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\BFE\Parameters' -Name 'MaxEndpointCountMult' -Value '0x10' -Type DWORD"};
				$ordercnt += 1
		} ELSE {
			Write-BISFLog -Msg "Set multiplication factor to the default UDP scavenge value (MaxEndpointCountMult) not optimized from BIS-F, because 3rd Party Optimization is configured" -Type W -ShowConsole -SubMsg
		}

		$PrepCommands += [pscustomobject]@{
			Order="$ordercnt";
			Enabled="$true";
			showmessage="N";
			CLI="";
			TestPath ="";
			Description="Disable Receive Side Scaling (RSS)";
			Command="Start-Process -FilePath 'netsh.exe' -Argumentlist 'int tcp set global rss=disable' -Wait -WindowStyle Hidden"};
			$ordercnt += 1

		$PrepCommands += [pscustomobject]@{
			Order="$ordercnt";
			Enabled="$true";
			showmessage="Y";
			CLI="LIC_BISF_CLI_V6";
			TestPath ="";
			Description="Disable IPv6 in registry ?";
			Command="Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\TcpIp6\Parameters' -Name 'DisabledComponents' -Value '0x000000FF' -Type DWORD"};
			$ordercnt += 1

        $PrepCommands += [pscustomobject]@{
			Order="$ordercnt";
			Enabled="$true";
			showmessage="N";
			CLI="";
			TestPath ="";
			Description="Disable Data Execution Prevention";
			Command="Start-Process 'bcdedit.exe' -Verb runAs -ArgumentList '/set nx AlwaysOff' | Out-Null"};
			$ordercnt += 1

		$PrepCommands += [pscustomobject]@{
			Order="$ordercnt";
			Enabled="$true";
			showmessage="N";
			CLI="";
			TestPath ="";
			Description="Disable Startup Repair option";
			Command="Start-Process 'bcdedit.exe' -Verb runAs -ArgumentList '/set {default} bootstatuspolicy ignoreallfailures' | Out-Null"};
			$ordercnt += 1

        $PrepCommands += [pscustomobject]@{
			Order="$ordercnt";
			Enabled="$true";
			showmessage="N";
			CLI="";
			TestPath ="";
			Description="Disable New Network dialog";
			Command="Set-ItemProperty -Name NewNetworkWindowOff -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Network' -Type String -Value 0"};
			$ordercnt += 1

	    $PrepCommands += [pscustomobject]@{
			Order="$ordercnt";
			Enabled="$true";
			showmessage="N";
			CLI="";
			TestPath ="";
			Description="Set Power Saving Scheme to High Performance";
			Command="Start-Process 'powercfg.exe' -Verb runAs -ArgumentList '-s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'"};
			$ordercnt += 1

	# recommended: Running SDelete on PVS WriteCacheDisk on each PVS Target Devices only
	IF ($returnTestPVSSoftware -eq "true")
	{
		IF (($LIC_BISF_CLI_SD -ne $null) -or ($LIC_BISF_CLI_SD -ne "")) {
			$PrepCommands += [pscustomobject]@{
				Order="$ordercnt";
				Enabled="$true";
				showmessage="N";
				CLI="";
				TestPath ="";
				Description="Reset value LIC_BISF_SDeleteRun in registry ?";
				Command="Set-ItemProperty -Path '$hklm_software_LIC_CTX_BISF_SCRIPTS' -Name 'LIC_BISF_SDeleteRun' -value '$false'"};
				$ordercnt += 1
		}
		$PrepCommands += [pscustomobject]@{
			Order="$ordercnt";
			Enabled="$true";
			showmessage="Y";
			CLI="LIC_BISF_CLI_SD";
			TestPath ="$($SearchFoldersSD)\sdelete.exe";
			Description="Run SDelete to Zero-Out free space on PVS WriteCacheDisk on each PVS Target Device at system startup ?";
			Command="Set-ItemProperty -Path '$hklm_software_LIC_CTX_BISF_SCRIPTS' -Name 'LIC_BISF_SDeleteRun' -value '$true'"};
			$ordercnt += 1
	} ELSE {
		$PrepCommands += [pscustomobject]@{
			Order="$ordercnt";
			Enabled="$true";
			showmessage="N";
			CLI="";
			TestPath ="";
			Description="Reset value LIC_BISF_SDeleteRun in registry ?";
			Command="Set-ItemProperty -Path '$hklm_software_LIC_CTX_BISF_SCRIPTS' -Name 'LIC_BISF_SDeleteRun' -value '$false'"};
			$ordercnt += 1
	}

	if (!($LIC_BISF_CLI_DotNet -eq "NO"))
	{

		### Executing all queued .NET compilation jobs - Precompiling assemblies with Ngen.exe can improve the startup time for some applications.
		$NgenPath = Get-ChildItem -Path 'C:\Windows\Microsoft.NET' -Recurse "ngen.exe" | % {$_.FullName}
		foreach ($element in $NgenPath) {
		   Write-BISFLog -Msg  "Read Ngen Path: $element"
		   $PrepCommands += [pscustomobject]@{
			   Order="$ordercnt";
			   Enabled="$true";
			   showmessage="N";
			   CLI="";
			   TestPath ="";
			   Description="Executing all queued .NET compilation jobs for $element";
			   Command="Start-BISFProcWithProgBar -ProcPath '$element' -Args 'ExecuteQueuedItems' -ActText 'Running .NET Optimization in $element'"};
			   $ordercnt += 1
		}
	} ELSE {
		Write-BISFLog -Msg "Microsoft .NET Optimization is disabled in ADMX"
	}

	IF ($LIC_BISF_3RD_OPT -eq $false)
	{
		## Read language specified adapter name to support mui installations for each customer
		$adapter = get-BISFAdapterName
		foreach ($element in $adapter) {
			Write-BISFLog -Msg  "Read AdapterName: $element"
			$PrepCommands += [pscustomobject]@{
				Order="$ordercnt";
				Enabled="$true";
				showmessage="N";
				CLI="";
				TestPath ="";
				Description="ARP Cache Changes Adapter: $element ... (http://support.citrix.com/article/ctx127549)";
				Command="netsh interface ipv4 set interface ""$element"" basereachable=600000"};
				$ordercnt += 1

		}

		## Read GUID of DHCP Network Adapter and clear DHCP-option, see https://www.citrix.com/blogs/2015/09/29/pvs-target-devices-the-blue-screen-of-death-rest-easy-we-can-fix-that/
		$adapter = get-BISFAdapterGUID
		$PrepCommands += [pscustomobject]@{
			Order="$ordercnt";
			Enabled="$true";
			showmessage="N";
			CLI="";
			TestPath ="";
			Description="Stop DHCP Client Service";
			Command="Stop-Service -Name dhcp -ErrorAction SilentlyContinue"};
		$ordercnt += 1

		$PrepCommands += [pscustomobject]@{
			Order="$ordercnt";
			Enabled="$true";
			showmessage="N";
			CLI="";
			TestPath ="";
			Description="Clear NameServer in Registry TCPIP\Parameters";
			Command="Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters' -Name 'NameServer' -value '' "};
		$ordercnt += 1

		foreach ($element in $adapter)
		{
			Write-BISFLog -Msg  "Read AdapterGUID: $element"
			$REG_HKLM_TCPIP_Interfaces_GUID = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\$element"
			$PrepCommands += [pscustomobject]@{
				Order="$ordercnt";
				Enabled="$true";
				showmessage="N";
				CLI="";
				TestPath ="";
				Description="AdapterGUID: $element - clear NameServer";
				Command="Set-ItemProperty -Path '$REG_HKLM_TCPIP_Interfaces_GUID' -Name 'NameServer' -value '' "};
			$ordercnt += 1

			$PrepCommands += [pscustomobject]@{
				Order="$ordercnt";
				Enabled="$true";
				showmessage="N";
				CLI="";
				TestPath ="";
				Description="AdapterGUID: $element - clear Domain";
				Command="Set-ItemProperty -Path '$REG_HKLM_TCPIP_Interfaces_GUID' -Name 'Domain' -value '' "};
			$ordercnt += 1

			$PrepCommands += [pscustomobject]@{
				Order="$ordercnt";
				Enabled="$true";
				showmessage="N";
				CLI="";
				TestPath ="";
				Description="AdapterGUID: $element - clear DhcpIPAddress";
				Command="Set-ItemProperty -Path '$REG_HKLM_TCPIP_Interfaces_GUID' -Name 'DHCPIPAddress' -value '' "};
			$ordercnt += 1

			$PrepCommands += [pscustomobject]@{
				Order="$ordercnt";
				Enabled="$true";
				showmessage="N";
				CLI="";
				TestPath ="";
				Description="AdapterGUID: $element - clear DhcpSubnetmask";
				Command="Set-ItemProperty -Path '$REG_HKLM_TCPIP_Interfaces_GUID' -Name 'DhcpSubnetmask' -value '' "};
			$ordercnt += 1

			$PrepCommands += [pscustomobject]@{
				Order="$ordercnt";
				Enabled="$true";
				showmessage="N";
				CLI="";
				TestPath ="";
				Description="AdapterGUID: $element - clear DhcpServer";
				Command="Set-ItemProperty -Path '$REG_HKLM_TCPIP_Interfaces_GUID' -Name 'DhcpServer' -value '' "};
			$ordercnt += 1

			$PrepCommands += [pscustomobject]@{
				Order="$ordercnt";
				Enabled="$true";
				showmessage="N";
				CLI="";
				TestPath ="";
				Description="AdapterGUID: $element - clear DhcpNameServer";
				Command="Set-ItemProperty -Path '$REG_HKLM_TCPIP_Interfaces_GUID' -Name 'DhcpNameServer' -value '' "};
			$ordercnt += 1

			$PrepCommands += [pscustomobject]@{
				Order="$ordercnt";
				Enabled="$true";
				showmessage="N";
				CLI="";
				TestPath ="";
				Description="AdapterGUID: $element - clear DhcpDefaultGateway";
				Command="Set-ItemProperty -Path '$REG_HKLM_TCPIP_Interfaces_GUID' -Name 'DhcpDefaultGateway' -value '' "};
			$ordercnt += 1

			$PrepCommands += [pscustomobject]@{
				Order="$ordercnt";
				Enabled="$true";
				showmessage="Y";
				CLI="LIC_BISF_CLI_V6";
				TestPath ="$($SearchFoldersV6)\nvspbind.exe";
				Description="Disable IPv6 on AdapterGUID: $element ?";
				Command="$($SearchFoldersV6)\nvspbind.exe /d ""$element"" ms_tcpip6"};
			$ordercnt += 1
		}
	} ELSE {
		Write-BISFLog -Msg "Network Adapter are not optimized from BIS-F, because 3rd Party Optimization is configured" -Type W -ShowConsole -SubMsg
	}
	## reset Distributed Transaction Coordinator service if installed
	$svc = Test-BISFService -ServiceName "MSDTC"
	IF ($svc -eq $true)
	{
	$PrepCommands += [pscustomobject]@{
		Order="$ordercnt";
		Enabled="$true";
		showmessage="N";
		CLI="";
		TestPath ="";
		Description="Reset Microsoft Distributed Transaction Service ";
		Command="msdtc.exe -reset" };
	$ordercnt += 1
	}


	## vmware tools optimizations
	$svc = Test-BISFService -ServiceName "vmtools"
	IF ($svc -eq $true)
	{
		$PrepCommands += [pscustomobject]@{
			Order="$ordercnt";
			Enabled="$true";
			showmessage="N";
			CLI="";
			TestPath ="";
			Description="Hide Vmware Tools icon in systray";
			Command="Set-ItemProperty -Path 'HKLM:\SOFTWARE\VMware, Inc.\VMware Tools' -Name 'ShowTray' -Value '0' -Type DWORD" };
		$ordercnt += 1
	}

	$svc = Test-BISFService -ServiceName "vmdebug"
	IF ($svc -eq $true)
	{
		$PrepCommands += [pscustomobject]@{
			Order="$ordercnt";
			Enabled="$true";
			showmessage="N";
			CLI="";
			TestPath ="";
			Description="Disable VMware debug driver";
			Command="Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\services\vmdebug' -Name 'Start' -Value '4' -Type DWORD" };
		$ordercnt += 1
	}


	## hide PVS status icon
	IF ($returnTestPVSSoftware -eq "true")
	{
		$PrepCommands += [pscustomobject]@{
			Order="$ordercnt";
			Enabled="$true";
			showmessage="N";
			CLI="";
			TestPath ="";
			Description="Hide PVS Status icon in systray";
			Command="New-Item -Path 'HKLM:\SOFTWARE\CITRIX\ProvisioningServices\Status' -Force | out-null; Set-ItemProperty -Path 'HKLM:\SOFTWARE\CITRIX\ProvisioningServices\Status' -Name 'ShowIcon' -Value '0' -Type DWORD" };
		$ordercnt += 1

	}

	    ## WSUS client-side targeting

    IF ($WSUS_TargetGroupEnabled -eq 1)
        {
          Write-BISFLog -Msg "WSUS client-side targeting detected"
          $PrepCommands +=  [pscustomobject]@{
			  Order="$ordercnt";
			  Enabled="$true";
			  showmessage="N";
			  CLI="";
			  TestPath ="";
			  Description="Delete WSUS - SusClientId in $REG_hklm_WSUS";
			  Command="Remove-ItemProperty -Path '$REG_hklm_WSUS' -Name 'SusClientId' -ErrorAction SilentlyContinue"};
			$ordercnt += 1

          $PrepCommands +=  [pscustomobject]@{
			  Order="$ordercnt";
			  Enabled="$true";
			  showmessage="N";
			  CLI="";
			  TestPath ="";
			  Description="Delete WSUS - SusClientIdValidation in $REG_hklm_WSUS";
			  Command="Remove-ItemProperty -Path '$REG_hklm_WSUS' -Name 'SusClientIdValidation' -ErrorAction SilentlyContinue"};
			$ordercnt += 1
        }
	$PrepCommands +=  [pscustomobject]@{
		Order="$ordercnt";
		Enabled="$true";
		showmessage="N";
		CLI="";
		TestPath ="";
		Description="Set Windows Update Service to Disabled";
		Command="Set-Service -Name wuauserv -StartupType Disabled -ErrorAction SilentlyContinue"};
	$ordercnt += 1
	IF ($LIC_BISF_3RD_OPT -eq $false)
	{
		## Disable useless scheduled tasks
		IF (($OSVersion -like "6.3*") -or ($OSVersion -like "10*"))
		{
			Write-BISFLog -Msg "Disable Scheduled Tasks" -ShowConsole -Color Cyan
			$ScheduledTasksList = @("AitAgent","ProgramDataUpdater","StartupAppTask","Proxy","UninstallDeviceTask","BthSQM","Consolidator","KernelCeipTask","Uploader","UsbCeip","Scheduled","Microsoft-Windows-DiskDiagnosticDataCollector","Microsoft-Windows-DiskDiagnosticResolver","WinSAT","HotStart","AnalyzeSystem","RacTask","MobilityManager","RegIdleBackup","FamilySafetyMonitor","FamilySafetyRefresh","AutoWake","GadgetManager","SessionAgent","SystemDataProviders","UPnPHostConfig","ResolutionHost","BfeOnServiceStartTypeChange","UpdateLibrary","ServerManager","Proxy","UninstallDeviceTask","Scheduled","Microsoft-Windows-DiskDiagnosticDataCollector","Microsoft-Windows-DiskDiagnosticResolver","WinSAT","MapsToastTask","MapsUpdateTask","ProcessMemoryDiagnosticEvents","RunFullMemoryDiagnostic","MNO Metadata Parser","AnalyzeSystem","MobilityManager","RegIdleBackup","CleanupOfflineContent","FamilySafetyMonitor","FamilySafetyRefresh","SR","UPnPHostConfig","ResolutionHost","UpdateLibrary","WIM-Hash-Management","WIM-Hash-Validation","ServerCeipAssistant")
			ForEach ($ScheduledTaskList in $ScheduledTasksList)
			{
				$task = Get-ScheduledTask -TaskName "$ScheduledTaskList" -ErrorAction SilentlyContinue
				IF ($task)
				{
					Write-BISFLog -Msg "Scheduled Task $ScheduledTaskList exists" -ShowConsole -SubMsg -Color DarkCyan
					$TaskPathName = Get-ScheduledTask -TaskName "$ScheduledTaskList" | % {$_.TaskPath}
					$PrepCommands +=  [pscustomobject]@{
						Order="$ordercnt";
						Enabled="$true";
						showmessage="N";
						CLI="";
						Testpath="";
						Description="Disable scheduled Task $ScheduledTaskList ";
						Command="Disable-ScheduledTask -Taskname '$ScheduledTaskList' -TaskPath '$TaskPathName' | Out-Null"};
					$ordercnt += 1
				} ELSE {
					Write-BISFLog -Msg "Scheduled Task $ScheduledTaskList NOT exists"
				}
			}
		}
	} ELSE {
		Write-BISFLog -Msg "Schedule Task are not disabled from BIS-F, because 3rd Party Optimization is configured" -Type W -ShowConsole -SubMsg
	}

	$paths = @( "$env:windir\Temp","$env:temp")

    foreach ($path in $paths) {
       $PrepCommands += [pscustomobject]@{
		   Order="$ordercnt";
		   Enabled="$true";
		   showmessage="N";
		   CLI="";
		   TestPath ="";
		   Description="Cleaning directory: $path";
		   Command="Remove-BISFFolderAndContent($path)"};
		$ordercnt += 1
	}

	####################################################################

    ####################################################################
    ####### functions #####

    # Prepare System
    function PreCommand {
	    Write-BISFLog -Msg "Running PreCommands on your Base-Image" -ShowConsole -Color Cyan
        Foreach ($prepCommand in ($PrepCommands | Sort-Object -Property "Order")) {
            Write-BISFLog -Msg "Processing Order-Nbr $($prepCommand.Order): $($prepCommand.Description)"
            #write-host "TestPath: $($prepCommand.TestPath)" -ForegroundColor White -BackgroundColor Red  #<<< enable for debug only
            IF ( ($prepCommand.TestPath -eq "" ) -or   (Test-Path $($prepCommand.TestPath)) )
			{

				IF ($($prepCommand.TestPath) -ne "" ) {
					$Productname = (Get-Item $($prepCommand.TestPath)).Basename
					$ProductFileVersion = (Get-Item $($prepCommand.TestPath)).VersionInfo.FileVersion
					Write-BISFLog -Msg "Product $Productname $ProductFileVersion installed" -ShowConsole -Color Cyan
					IF (($Productname -eq "sdelete") -and ($ProductFileVersion -eq "2.0"))
					{
						Write-BISFLog -Msg "WARNING: $Productname $ProductFileVersion has an vendor bug, please install Version 1.6.1 or newer !!" -ShowConsole -Type W
						Start-Sleep 20
					}

				}
				Write-BISFLog -Msg "Configure $($prepCommand.Description)" -ShowConsole -Color DarkCyan -SubMsg
				# write-host "MessageBox: $($prepCommand.showmessage)" -ForegroundColor White -BackgroundColor Red  #<<< enable for debug only
                IF ($($prepCommand.showmessage) -eq "N") {
                   # Write-BISFLog -Msg "$($prepCommand.Command)" -ShowConsole
					invoke-expression $($prepCommand.Command)
				} ELSE {
					Write-BISFLog -Msg "Check Silentswitch..."
					$varCLI = Get-Variable -Name $($prepCommand.CLI) -ValueOnly
					If (($varCLI -eq "YES") -or ($varCLI -eq "NO")) {
						Write-BISFLog -Msg "Silentswitch will be set to $varCLI" -ShowConsole -Color DarkCyan -SubMsg
					} ELSE {

						If ($LIC_BISF_CLI_VS)
						{
							Write-BISFLog -Msg "VerySilent will be configured with the BIS-F ADMX template! Please configure the BIS-F ADMX to run $($prepCommand.Description) and start the script again !" -Type E
						}
						Write-BISFLog -Msg "Silentswitch not defined, show MessageBox"
						$PreMsgBox = Show-BISFMessageBox -Msg "$($prepCommand.Description)" -Title "PRE build Base Image Action" -YesNo -Question
						Write-BISFLog -Msg "`"$PreMsgBox`" is the response to perform $($prepCommand.Description)... please wait" -ShowConsole -Color DarkGreen -SubMsg
					}
					if (($PreMsgBox -eq "YES") -or ($varCLI -eq "YES")) {
						 Write-BISFLog -Msg "Running Command $($prepCommand.Command)"
						invoke-expression $($prepCommand.Command)
					}
				}
                # these 2 variables must be cleared after each step, to not store the value in the variable and use them in the next $prepCommand
                $varCLI = @()
                $PreMsgBox = @()
			} ELSE {
				Write-BISFLog -Msg "Product $($prepCommand.TestPath) NOT installed, neccessary for Order-Nbr $($prepCommand.Order): $($prepCommand.Description)"

			}
        }

    }

    function Create-BISFTask
    {
        # searching for BISF scheduled task and if from different BIS-F version delete them

	    $testBISFtask = schtasks /query /v /FO CSV | ConvertFrom-Csv | Where {$_.TaskName -eq "\$BISFtask"}
	    IF (!($testBISFtask))
	    {
	        Write-BISFLog -Msg "Create startup task $BISFtask to personalize System" -ShowConsole -Color Cyan
		    schtasks.exe /create /sc ONSTART /TN "$BISFtask" /IT /RU 'System' /RL HIGHEST /tr "powershell.exe -Executionpolicy unrestricted -file '$LIC_BISF_MAIN_PersScript'" /f | Out-Null
        } ELSE {
			Write-BISFLog -Msg "Task alrady exist, modify startup task $BISFtask to personalize System" -ShowConsole -Color Cyan
			schtasks.exe /change /TN "$BISFtask" /RL HIGHEST /tr "powershell.exe -Executionpolicy unrestricted -file '$LIC_BISF_MAIN_PersScript'" | Out-Null
	    }

    }

    function Test-DrvLabel
    {
        $SysDrive = $env:SystemDrive
        $Sysdrvlabel = gwmi -Class win32_volume -Filter "Driveletter = '$SysDrive' "| % {$_.Label}
        $DriveLabel = "OSDisk"
        IF ($Sysdrvlabel -eq $null)
        {
            Write-BISFLog -Msg "DriveLabel for $SysDrive would be set to $DriveLabel" -ShowConsole -Color Cyan
            $drive = gwmi win32_volume -Filter "DriveLetter = '$SysDrive'"
            $drive.Label = "$DriveLabel"
            $drive.put() | Ou-Null
        }


    }


    function Add-AdminShortcut
	{
		Write-BISFLog -Msg "Create BIS-F Shortcut on your Desktop" -ShowConsole -Color Cyan
		$DisplayIcon=(Get-ItemProperty "$HKLM_Full_Uninsstall" -Name "DisplayIcon").DisplayIcon
		$WshShell = New-Object -comObject WScript.Shell
		$Shortcut = $WshShell.CreateShortcut("$Home\Desktop\PrepareBaseImage (BIS-F) Admin Only.lnk")
		$Shortcut.TargetPath = "$InstallLocation\PrepareBaseImage.cmd"
		$Shortcut.IconLocation = "$DisplayIcon"
		$Shortcut.Description ="Run Base Image Script Framework (Admin Only)"
		$Shortcut.WorkingDirectory ="$InstallLocation"
		$Shortcut.Save()
	}


	function Disable-Cortana
	{
		IF ($LIC_BISF_3RD_OPT -eq $false)
		{
			Write-BISFLog -Msg  "Disabling Cortana..." -ShowConsole -Color DarkCyan -Submsg
			New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\' -Name 'Windows Search' | Out-Null
			New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' -Name 'AllowCortana' -PropertyType DWORD -Value '0' | Out-Null
		} ELSE {
			Write-BISFLog -Msg "Disabling Cortana are not set from BIS-F, because 3rd Party Optimization is configured" -Type W -ShowConsole -SubMsg
		}
	}


	function Clear-EventLog
	{
		wevtutil el | Foreach-Object {
			Write-BISFLog -Msg  "Clearing Event-Log $_" -ShowConsole -Color DarkCyan -Submsg
			wevtutil cl "$_"
		}
	}

	function Create-AllusersStartmenuPrograms
	{
		#bugfix 56: recreate "$Dir_AllUsersStartMenu\Programs" that is necassary for to start Office C2R or other AppX after delete $Dir_AllUsersStartMenu
		$StartMenuProgramsPath = "$Dir_AllUsersStartMenu\Programs"
		IF (!(Test-path "$StartMenuProgramsPath"))
		{
			Write-BISFLog -Msg "Create Directory $StartMenuProgramsPath" -ShowConsole -Color Cyan
			New-Item -ItemType Directory -Path "$StartMenuProgramsPath" | out-null
		}
	}

	function Pre-Win7
	{
		<#
        IF (Test-Path "$env:WinDir\System32\cleanmgr.exe" -PathType Leaf )
        {
            Write-BISFLog -Msg "Perform a disk cleanup" -ShowConsole -Color DarkCyan -SubMsg
            # Automate by creating the reg checks corresponding to "cleanmgr /sageset:100" so we can use "sagerun:100"
        	Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Active Setup Temp Folders' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\BranchCache' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Downloaded Program Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\GameNewsFiles' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\GameStatisticsFiles' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\GameUpdateFiles' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Internet Cache Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Memory Dump Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Offline Pages Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Old ChkDsk Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Previous Installations' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Service Pack Cleanup' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Setup Log Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error memory dump files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error minidump files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Setup Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Sync Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Upgrade Discarded Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\User file versions' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Defender' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Archive Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Queue Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting System Archive Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting System Queue Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows ESD installation files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Upgrade Log Files' -Type DWord -Value 0x00000002
		    # Perform a disk cleanup
            Start-Process 'cleanmgr.exe' -Verb runAs -ArgumentList '/sagerun:100 | Out-Null' -Wait
		    Show-BISFProgressBar -CheckProcess "cleanmgr" -ActivityText "Running Disk Cleanup..."
		}
		ELSE
        {
		    Write-BISFLog -Msg "Disk Cleanup is NOT installed" -ShowConsole -Color DarkCyan -SubMsg
        }
		#>
	}

   	function Pre-Win2008R2
	{
		<#
        IF (Test-Path "$env:WinDir\System32\cleanmgr.exe" -PathType Leaf )
        {
            Write-BISFLog -Msg "Perform a disk cleanup" -ShowConsole -Color DarkCyan -SubMsg
            # Automate by creating the reg checks corresponding to "cleanmgr /sageset:100" so we can use "sagerun:100"
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Active Setup Temp Folders' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\BranchCache' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Downloaded Program Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\GameNewsFiles' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\GameStatisticsFiles' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\GameUpdateFiles' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Internet Cache Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Memory Dump Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Offline Pages Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Old ChkDsk Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Previous Installations' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Service Pack Cleanup' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Setup Log Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error memory dump files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error minidump files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Setup Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Sync Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Update Cleanup' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Upgrade Discarded Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\User file versions' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Defender' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Archive Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Queue Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting System Archive Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting System Queue Files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows ESD installation files' -Type DWord -Value 0x00000002
		    Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Upgrade Log Files' -Type DWord -Value 0x00000002
        	# Perform a disk cleanup
            Start-Process 'cleanmgr.exe' -Verb runAs -ArgumentList '/sagerun:100 | Out-Null' -Wait
		    Show-BISFProgressBar -CheckProcess "cleanmgr" -ActivityText "Running Disk Cleanup..."
        }
        ELSE
        {
		    Write-BISFLog -Msg "Disk Cleanup is NOT installed" -ShowConsole -Color DarkCyan -SubMsg
            # Install Disk Cleanup (without Desktop Experience feature)
		    #Copy-Item -Path "$env:WinDir\winsxs\amd64_microsoft-windows-cleanmgr_31bf3856ad364e35_6.1.7600.16385_none_c9392808773cd7da\cleanmgr.exe" -Destination "$env:WinDir\System32\"  -Force |Out-Null
		    #Depends on Windows Language!
		    #Copy-Item -Path "$env:WinDir\winsxs\amd64_microsoft-windows-cleanmgr.resources_31bf3856ad364e35_6.1.7600.16385_en-us_b9cb6194b257cc63\cleanmgr.exe.mui" -Destination "$env:WinDir\System32\en-US\"  -Force |Out-Null
        }
		#>
	}

	function Pre-Win8
	{
		<#
		Write-BISFLog -Msg "Perform a disk cleanup" -ShowConsole -Color DarkCyan -SubMsg
		# Automate by creating the reg checks corresponding to "cleanmgr /sageset:100" so we can use "sagerun:100"
		Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Active Setup Temp Folders' -Type DWord -Value 0x00000002
		Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Downloaded Program Files' -Type DWord -Value 0x00000002
		Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Internet Cache Files' -Type DWord -Value 0x00000002
		Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Memory Dump Files' -Type DWord -Value 0x00000002
		Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Offline Pages Files' -Type DWord -Value 0x00000002
		Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Old ChkDsk Files' -Type DWord -Value 0x00000002
		Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Previous Installations' -Type DWord -Value 0x00000000
		Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin' -Type DWord -Value 0x00000002
		Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Setup Log Files' -Type DWord -Value 0x00000002
		Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error memory dump files' -Type DWord -Value 0x00000002
		Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\System error minidump files' -Type DWord -Value 0x00000002
		Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files' -Type DWord -Value 0x00000002
		Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Setup Files' -Type DWord -Value 0x00000002
		Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache' -Type DWord -Value 0x00000002
		Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Upgrade Discarded Files' -Type DWord -Value 0x00000000
		Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Archive Files' -Type DWord -Value 0x00000002
		Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting Queue Files' -Type DWord -Value 0x00000002
		Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting System Archive Files' -Type DWord -Value 0x00000002
		Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Error Reporting System Queue Files' -Type DWord -Value 0x00000002
		Set-ItemProperty -Name StateFlags0100 -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Windows Upgrade Log Files' -Type DWord -Value 0x00000002
		# Perform a disk cleanup
		Start-Process 'cleanmgr.exe' -Verb runAs -ArgumentList '/sagerun:100 | Out-Null' -Wait
		Show-BISFProgressBar -CheckProcess "cleanmgr" -ActivityText "Running Disk Cleanup..."
		#>
		Optimize-BISFWinSxs
	}

	function Pre-Win2012R2
	{

		Optimize-BISFWinSxs
	}

	function Pre-Win2016
	{
		Disable-Cortana
		Optimize-BISFWinSxs

	}

	function Pre-Win10
	{
		Disable-Cortana
		Optimize-BISFWinSxs
	}



    ####################################################################
}

Process {
    #### Main Program


    ## OS Windows 7
	IF ($OSName -contains '*Windows 7*')
	{
		Write-BISFLog -Msg "Running PreCommands for Windows 7" -ShowConsole -Color Cyan
		Pre-Win7
	}

	## OS Windows 2008 R2
	IF (($OSVersion -like "6.1*") -and ($ProductType -eq "3"))
	{
        Write-BISFLog -Msg "Running PreCommands for Windows 2008 R2" -ShowConsole -Color Cyan
		Pre-Win2008R2
	}

	## OS Windows 8
	IF ($OSName -contains '*Windows 8*')
	{
		Write-BISFLog -Msg "Running PreCommands for Windows 8" -ShowConsole -Color Cyan
		Pre-Win8
	}

	## OS Windows 2012 R2
	IF (($OSVersion -like "6.3*") -and ($ProductType -eq "3"))
	{
		Write-BISFLog -Msg "Running PreCommands for Windows 2012 R2" -ShowConsole -Color Cyan
		Pre-Win2012R2
	}

	## OS Windows 2016
	IF (($OSVersion -like "10*") -and ($ProductType -eq "3"))
	{
		Write-BISFLog -Msg "Running PreCommands for Windows Server 2016" -ShowConsole -Color Cyan
		Pre-Win2016
	}

	## OS Windows 10
	IF (($OSVersion -like "10*") -and ($ProductType -eq "1"))
	{
		Write-BISFLog -Msg "Running PreCommands for Windows 10" -ShowConsole -Color Cyan
		Pre-Win10
	}

    PreCommand
    Clear-EventLog
	Test-DrvLabel
	Create-AllusersStartmenuPrograms
    Create-BISFTask
	Add-AdminShortcut

}
End {
    Add-BISFFinishLine
}