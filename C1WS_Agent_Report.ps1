Clear-Host
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

$ErrorActionPreference = 'Continue'

$Config     		= (Get-Content "$PSScriptRoot\TM-Config.json" -Raw) | ConvertFrom-Json
$Manager    		= $Config.MANAGER
$APIKEY     		= $Config.APIKEY
$REPORTNAME 		= $Config.REPORTNAME
$POLICY_ID_Filter	= $Config.POLICYID

$StartTime  = $(get-date)

$REPORTFILE          = $REPORTNAME + ".csv"
$DSM_URI             = "https://" + $Manager
$Computers_Uri       = $DSM_URI + "/api/computers"
$ComputerSearch_Uri	 = $DSM_URI + "/api/computers/search"
$Policies_Uri        = $DSM_URI + "/api/policies"

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", $APIKEY)
$headers.Add("api-version", 'v1')
$headers.Add("Content-Type", "application/json")
$headers.Add("expand", "ec2VirtualMachineSummary")

try {
	If ($POLICY_ID_Filter -ne ""){

		[int]$Policy_ID = [convert]::ToInt32($POLICY_ID_Filter,10)
		Write-host "Using Filter: $POLICY_ID_Filter "
		$Criteria = @{
			searchCriteria = @{
				fieldName = "policyID"
				numericTest = "equal"
				numericValue = $Policy_ID
				}
		}
		
		$BodyData = $Criteria | ConvertTo-Json
		Write-Host "quering all computers with Policy ID $Policy_ID"
		$Computers = Invoke-RestMethod -Uri $ComputerSearch_Uri -Method Post -Headers $Headers -Body $BodyData
	}Else{
		Write-Host "quering all computers"
		$Computers = Invoke-RestMethod -Uri $Computers_Uri -Method Get -Headers $Headers
	}	
}
catch {
	Write-Host "[ERROR]	Pulling Computers: $_"
    Exit
}

try {
	$Policies  = Invoke-RestMethod -Uri $Policies_Uri -Method Get -Headers $Headers
}
catch {
	Write-Host "[ERROR]	Pulling Policies: $_"
    Exit
}

if ((Test-Path $REPORTFILE) -eq $true){
    $BackupDate          = get-date -format MMddyyyy-HHmm
    $BackupReportName    = $REPORTNAME + "_" + $BackupDate + ".csv"
    copy-item -Path $REPORTFILE -Destination $BackupReportName
    Remove-item $REPORTFILE
}

$ReportHeader = 'AWSAccountID, Host_ID, HostName, DisplayName, RelayID, AgentStatus, AgentVersion, AgentOS, InstanceID, InstancePowerState, PolicyName, AntiMalwareState, WebReputationState, FirewallState, IntrusionPreventionState, IntegrityMnitoringState, LogInspectionState, ApplicaionControlState, ActivityMonitoringState'
Add-Content -Path $REPORTFILE -Value $ReportHeader

foreach ($Item in $Computers.computers){
	$Host_ID					= $Item.ID
	$PolicyID					= $Item.policyID
	$PolicyName					= ($Policies.policies | Where-Object {$_.ID -eq $PolicyID}).name
	$HostName					= $Item.hostName
	$DisplayName				= $Item.displayName
	$RelayID					= $Item.relayListID
	$AgentStatus				= $Item.computerStatus.agentStatusMessages
	$AgentVersion				= $Item.agentVersion
	$AgentOS					= $Item.ec2VirtualMachineSummary.operatingSystem
	$InstanceID					= $Item.ec2VirtualMachineSummary.instanceID
	$InstancePowerState			= $Item.ec2VirtualMachineSummary.state
	$AWSAccountID				= $Item.ec2VirtualMachineSummary.accountID
	$AntiMalwareState			= $Item.antiMalware.state
	$WebReputationState			= $Item.webReputation.state
	$FirewallState				= $Item.firewall.state 
	$IntrusionPreventionState	= $Item.intrusionPrevention.state
	$IntegrityMnitoringState	= $Item.integrityMonitoring.state
	$LogInspectionState			= $Item.logInspection.state
	$ApplicaionControlState		= $Item.applicationControl.state
	$ActivityMonitoringState	= $Item.activityMonitoring.state

	$ReportData =  "$AWSAccountID, $Host_ID, $HostName, $DisplayName, $RelayID, $AgentStatus, $AgentVersion, $AgentOS, $InstanceID, $InstancePowerState, $PolicyName, $AntiMalwareState, $WebReputationState, $FirewallState, $IntrusionPreventionState, $IntegrityMnitoringState, $LogInspectionState, $ApplicaionControlState, $ActivityMonitoringState"
	Add-Content -Path $REPORTFILE -Value $ReportData
}

$elapsedTime = $(get-date) - $StartTime
$totalTime = "{0:HH:mm:ss}" -f ([datetime]$elapsedTime.Ticks)

Write-Host "Script Execution is Complete.  It took $totalTime"
