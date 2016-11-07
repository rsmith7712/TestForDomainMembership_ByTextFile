<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2016 v5.2.127
	 Created on:   	9/6/2016 11:10 AM
	 Created by:   	Unknown
	 Modified by: 	Richard Smith, GSweet
	 Organization: 	
	 Filename:     	git-TestForDomainMembership_ByTextFile.ps1
	===========================================================================
	.DESCRIPTION
		- Test for system's domain membership status; 
		- Pulling system names from a text file; 
		- Logging results in a text file
#>

# Import AD Module
Import-Module ActiveDirectory;
Write-Host "AD Module Imported";

# Function - Logging file
function Logging($pingerror, $Computer, $Membership)
{
	$outputfile = "\\DOMAIN.com\Shares\UTILITY\log_TestForDomainMembership.txt";
	
	$timestamp = (Get-Date).ToString();
	
	$logstring = "Computer / Domain Status: {0}, {1}" -f $Computer, $Membership;
	
	"$timestamp - $logstring" | out-file $outputfile -Append;
	
	if ($pingerror -eq $false)
	{
		Write-Host "$timestamp - $logstring";
	}
	else
	{
		Write-Host "$timestamp - $logstring" -foregroundcolor red;
	}
	return $null;
}

# Sets the Server Inclusion List from a Text File
$ServerList = Get-Content "\\FILE_SERVER\Shares\UTILITY\list_TestForDomainMembership.txt"

# ForEach Loop - Test each system listed in text file for domain membership status
ForEach ($Server in $ServerList)
{
	# Set timeout value so script doesn't keep hitting an unresponsive system
	$timeoutSeconds = 15
	
	
	
	# Test connection to target server
	Write-Host "Testing connection to target system";
	If (Test-Connection -CN $Server -Quiet)
	{
		Write-Host "Connection to target system successful";
		
		# Switch statement - Create variable and test system's domain membership
		$Membership = gwmi -Class win32_computersystem | select -ExpandProperty domainrole
		switch ($Membership)
		{
			0 { "Standalone Workstation" }
			1 { "Member Workstation" }
			2 { "Standalone Server" }
			3 { "Member Server" }
			4 { "Backup Domain Controller" }
			5 { "Primary Domain Controller" }
			default { "Domain Membership Unknown" }
		}
		
		# Export results to logging function
		Logging $False $Server $Membership;
	}
}
