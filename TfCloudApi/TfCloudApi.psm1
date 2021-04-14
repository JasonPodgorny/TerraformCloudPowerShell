## JP TF Cloud Module - Powershell 4.0 + PowerCLI 5.8 release 1
function decodeToken {
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$True)]
		[securestring]$apiToken
	)
	begin {}
	process {
		$bstr  = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($apiToken)
    	try
    	{
        	$strToken = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    	}
    	finally
    	{
        	[Runtime.InteropServices.Marshal]::FreeBSTR($bstr)
    	}
    	Write-Output $strToken
	}
}
function Connect-JpTfCloud {
	<#
		.SYNOPSIS
			Connects to TF Cloud Via REST.
		.DESCRIPTION
			Connects to TF Cloud Via Via REST. The cmdlet starts a new session with an API token to the specified organization.
		.PARAMETER  Hostname
			Specify The Terraform Cloud Hostname.  Ex: app.terraform.io
		.PARAMETER  Organization
			Specify the Terraform Cloud Organization You Want To Connect To 
		.PARAMETER  ApiToken
			TF Cloud API Token.
		.EXAMPLE
			PS C:\> Connect-JpTfCloud -hostname "app.terraform.io" -organization "<YOUR_ORG>" -ApiToken "<YOUR API TOKEN>"
	#>
	[CmdletBinding()]
	[OutputType([Object])]
	Param (
		[string]$Hostname = "app.terraform.io",
		[Parameter(Mandatory=$True, HelpMessage="TF Cloud Organization.")]
		[string]$Organization,
		[Parameter(Mandatory=$True, HelpMessage="API Token As Secure String.")]
		[securestring]$ApiToken
	)
	begin {
		Write-Verbose "Connecting To TF Cloud At $organizationApiUrl"
	}
	process {
		$baseApiUrl= "https://" + "${Hostname}" + "/" + "api" + "/" + "v2" + "/"
		$organizationApiUrl =  $baseApiUrl + "organizations" + "/" + "${Organization}" + "/"
		Write-Debug "Connecting to TF Cloud at $organizationApiUrl"
		if ($Global:DefaultTfCloudOrg) {
			$current_url_name = ($Global:DefaultTfCloudOrg.ServerUri)
			Write-Warning "Cannot connect - already connected to TF Cloud Organization $current_url_name"
			return		
		}	
		try {	
			$connection_ok = $true
			$headers = @{"Authorization"="Bearer $(decodeToken -apiToken $ApiToken)";}
			$session = Invoke-RestMethod -Headers $headers -Uri $organizationApiUrl -Method Get -ContentType 'application/vnd.api+json' -Timeout 10
		} catch {
			Write-Warning "Failed to connect to TF Cloud Organization:  $organizationApiUrl"
			Write-Debug "$_"
			$connection_ok = $false
		}
		if ($connection_ok) {
			Write-Debug "Successfully connected to TF Cloud Organization at $organizationApiUrl"					
			$obj = New-Object -TypeName PSObject -Property @{
				Hostname = $Hostname
				Organization = $Organization
				ServerUri = $baseApiUrl
				OrganizationUri = $organizationApiUrl
				ApiToken = $ApiToken
			}	
			$Global:DefaultTfCloudOrg = $obj
			Write-Output $obj
		}
	}	
}
function Disconnect-JpTfCloud {
	<#
		.SYNOPSIS
			Disconnects TF Cloud REST Session.
		.DESCRIPTION
			Disconnects TF Cloud REST Session.  The cmdlet stops a session with an TF Cloud Organization.
		.EXAMPLE
			PS C:\> Disconnect-JpTfCloud 
	#>
	[CmdletBinding()]
	Param ()
	begin {}
	process {
		
		if ($Global:DefaultTfCloudOrg) {
			$current_url_name = ($Global:DefaultTfCloudOrg.ServerUri)
			Write-Verbose "Disconnecting from TF Cloud Organizationt: $current_url_name"
			$Global:DefaultTfCloudOrg = $null
			return		
		} else { 
			Write-Warning "Not connected to a TF Cloud Organization"
		}
	
	}
	
}
#Declare the GET function
Function Calling-Get {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$True)]
		[string]$Url
	)
	begin {
		Write-Verbose "Invoking REST GET at URL $url"	
	}
	process {	
		if ( !$Global:DefaultTfCloudOrg ) {		
			Write-Warning "Must connect to TF Cloud Organzation before attempting GET"
			return
		}	
		try {
			$ApiToken = ($Global:DefaultTfCloudOrg.ApiToken)
			$headers = @{"Authorization"="Bearer $(decodeToken -apiToken $ApiToken)";}		
			Invoke-RestMethod -Headers $headers -Uri $url -Method Get -ContentType 'application/vnd.api+json'
		} catch { 
			Write-Warning "$_"
			Write-Warning "Get Failed at - $url"
		}		
	
	}
}
Function Calling-Put {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$True)]
		[string]$Url,
		[Parameter(Mandatory=$True)]
		[string]$Body
	)
	begin {
		Write-Verbose "Invoking REST PUT at URL $url"	
	}
	process { 
		if ( !$Global:DefaultTfCloudOrg ) {
			Write-Warning "Must connect to TF Cloud Organization before attempting PUT"
			return
		}
		try {
		    $ApiToken = ($Global:DefaultTfCloudOrg.ApiToken)
			$headers = @{"Authorization"="Bearer $(decodeToken -apiToken $ApiToken)";}
			Invoke-RestMethod -Headers $headers -Uri $url -Body $Body -Method Put -ContentType 'application/vnd.api+json'
		} catch { 
			Write-Warning "$_"
			Write-Warning "Put Failed at - $url"
		}
	}
}
#Declare the POST function
Function Calling-Post {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$True)]
		[string]$Url,
		[Parameter(Mandatory=$True)]
		[string]$Body
	)
	begin {
		Write-Verbose "Invoking REST POST at URL $url"
	}
	process {	
		if ( !$Global:DefaultTfCloudOrg ) {
			Write-Warning "Must connect to TF Cloud Organization before attempting POST"
			return
		}
		try {
		    $ApiToken = ($Global:DefaultTfCloudOrg.ApiToken)
			$headers = @{"Authorization"="Bearer $(decodeToken -apiToken $ApiToken)";}
			Invoke-RestMethod -Headers $headers -Uri $url -Body $Body -Method Post -ContentType 'application/vnd.api+json' -TimeOutSec 300
		} catch { 
			Write-Warning "$_" 
			Write-Warning "Post Failed at - $url"
		}
	}
}
#Declare the DELETE function
Function Calling-Delete {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory=$True)]
		[string]$Url
	)
	begin {
		Write-Verbose "Invoking REST DELETE at URL $url"	
	}
	process {	
		if ( !$Global:DefaultTfCloudOrg ) {		
			Write-Warning "Must connect to TF Cloud Organization before attempting DELETE"
			return
		}	
		try {
			$ApiToken = ($Global:DefaultTfCloudOrg.ApiToken)
			$headers = @{"Authorization"="Bearer $(decodeToken -apiToken $ApiToken)";}	
			Invoke-RestMethod -Headers $headers -Uri $url -Method Delete -ContentType 'application/vnd.api+json' 
		} catch { 
			Write-Warning "$_"
			Write-Warning "Delete Failed at - $url"
		}		
	
	}
}
function Get-TfCloudWorkspace {
	<#
		.SYNOPSIS
			Gets List Of Workspaces From TFCloud Organization.  Lists all Workspaces if no name(s) specified
		.DESCRIPTION
			Gets List Of Workspaces From TFCloud Organization.  Lists all Workspaces if no name(s) specified
		.PARAMETER  Name
			TFCloud Workspace Name(s) to list.  Lists all Workspaces if left blank
		.EXAMPLE
			PS C:\> Get-TfCloudWorkspaces
		.EXAMPLE
			PS C:\> Get-TfCloudWorkspaces -name workspace1,workspace2
	#>
	[CmdletBinding()]
	[OutputType([Object])]
	param(
		[Parameter(ValueFromPipeline=$True, HelpMessage="TFCloud Workspace Names")]
		[string[]]$Name
	)
	begin {
		Write-Verbose "Getting TFCloud Workspaces"
	} 
	process { 
		$url = "$($Global:DefaultTfCloudOrg.OrganizationUri)workspaces"
		$workspaceList = Calling-Get -url $url
		foreach ($workspace in $workspaceList.data) {
			$workspace | Add-Member -NotePropertyName "name" -NotePropertyValue $workspace.attributes.name
			if ( $name ) { 
				foreach ( $workspaceName in $name ) {
					if ($workspace.name -eq $workspaceName) {
						write-output $workspace
					}
				}
			} else {
				write-output $workspace
			}
		}
	}
	
}
function Get-TfCloudWorkspaceDetails {
	<#
		.SYNOPSIS
			Gets List Of Workspaces From TFCloud Organization By Id
		.DESCRIPTION
			Gets List Of Workspaces From TFCloud Organization By Id
		.PARAMETER  WorkspaceId
			TFCloud Workspace Ids to list.
		.EXAMPLE
			PS C:\> Get-TfCloudWorkspaceDetails -WorkspaceId ws-xxxxx
	#>
	[CmdletBinding()]
	[OutputType([Object])]
	param(
		[Parameter(ValueFromPipelineByPropertyName, HelpMessage="TFCloud Workspace Names")]
		[Alias('Id')]
		[string[]]$WorkspaceId
	)
	begin {
		Write-Verbose "Getting TFCloud Workspaces"
	} 
	process {
		foreach ( $workspace in $WorkspaceId ) {
			Write-Verbose "Getting TFCloud Workspace For Id: ${workspace}"
			$url = "$($Global:DefaultTfCloudOrg.ServerUri)workspaces/${workspace}"
			$workspaceList = Calling-Get -url $url
			foreach ($workspaceOut in $workspaceList.data) {
				$workspaceOut | Add-Member -NotePropertyName "name" -NotePropertyValue $workspaceOut.attributes.name
				if ( $name ) { 
					foreach ( $workspaceName in $name ) {
						if ($workspaceOut.name -eq $workspaceName) {
							write-output $workspaceOut
						}
					}
				} else {
					write-output $workspaceOut
				}
			}
		}
	}
}
function New-TfCloudWorkspace {
	<#
		.SYNOPSIS
			Creates A VCS Workspace In A TFCloud Organization
		.DESCRIPTION
			Creates A VCS Workspace In A TFCloud Organization
		.PARAMETER  Name
			TFCloud Workspace Name To Create
		.PARAMETER  TfVersion
			Terraform Version For Workspace
		.PARAMETER  WorkDir
			Working Directory For Workspace
		.PARAMETER  repoId
			ID Of Repository To Use
		.PARAMETER  oauthTokenId
			ID Of oauth toke to use
		.EXAMPLE
			PS C:\> New-TfCloudWorkspace -Name "<<WORKSPACE_NAME>" -TfVersion "<TERRAFORM_VERSION>" -WorkDir "<WORK_DIR>" -repoId "<REPO_ID>" -oauthTokenId "<OAUTH_TOKEN_ID>"
	#>
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
	param(
		[Parameter(Mandatory=$True, HelpMessage="TFCloud Workspace Name")]
		[string]$Name,
		[Parameter(Mandatory=$True, HelpMessage="Terraform Version")]
		[string]$TfVersion,
		[Parameter(Mandatory=$True, HelpMessage="Working Directory")]
		[string]$WorkDir,
		[Parameter(Mandatory=$True, HelpMessage="Repo Identifier")]
		[string]$repoId,
		[Parameter(Mandatory=$True, HelpMessage="Oauth Token Id")]
		[string]$oauthTokenId
	)
	begin {
		Write-Verbose "Creating TF Cloud Workspace $Name"
	} 
	process { 
		$url = "$($Global:DefaultTfCloudOrg.OrganizationUri)workspaces"

		$body = @{
            "data" = @{
                "attributes" = @{
					"name" = $name
					"terraform_version" = $TfVersion
					"working-directory" = $WorkDir
					"vcs-repo" = @{
						"identifier" = $repoId
						"oauth-token-id" = $oauthTokenId
					}
				}
                "type" = "workspaces"
            }
        } | ConvertTo-Json -Depth 5
		if ($PSCmdlet.ShouldProcess($Name)) {
			$workspaceCreate = Calling-Post -url $url -Body $body
		}
		$workspaceCreate.data | Add-Member -NotePropertyName "name" -NotePropertyValue $workspaceCreate.data.attributes.name
		Write-Output $workspaceCreate.data
	}
}
function Get-TfCloudRunsByWorkspace {
	<#
		.SYNOPSIS
			Gets List Of Runs From TFCloud Workspace
		.DESCRIPTION
			Gets List Of Runs From TFCloud Workspace
		.PARAMETER  WorkspaceName
			TFCloud Workspace Name to list Runs For.  
		.EXAMPLE
			PS C:\> Get-TfCloudRuns
		.EXAMPLE
			PS C:\> Get-TfCloudRuns -name workspace1
	#>
	[CmdletBinding()]
	[OutputType([Object])]
	param(
		[Parameter(ValueFromPipelineByPropertyName, Mandatory=$True, HelpMessage="TFCloud Workspace Name")]
		[Alias('Name')]
		[string[]]$WorkspaceName
	)
	begin {
		Write-Verbose "Getting TFCloud Runs For Workspaces"
	} 
	process {
		foreach ( $workspace in $WorkspaceName) {
			Write-Verbose "Looking Up Id For Workspace: $workspace"
			$workspaceDetails = Get-TfCloudWorkspaces -Name $workspace
			$workspaceId = $workspaceDetails.id

			$url = "$($Global:DefaultTfCloudOrg.ServerUri)workspaces/${workspaceId}/runs"
			$runsList = Calling-Get -url $url
			foreach ($run in $runsList.data) {
				$run | Add-Member -NotePropertyName "status" -NotePropertyValue $run.attributes.status
				$run | Add-Member -NotePropertyName "workspaceName" -NotePropertyValue $workspaceDetails.name
				write-output $run
			}
		}
	}
}
function Start-TfCloudRun {
	<#
		.SYNOPSIS
			Runs A Workspace In A TFCloud Organization
		.DESCRIPTION
			Runs A Workspace In A TFCloud Organization
		.PARAMETER  WorkspaceName
			TFCloud Workspace Name To Run
		.PARAMETER  Message
			TFCloud Workspace Message For Run
		.PARAMETER  configVersionId
			TFCloud Config Version Id For Run
		.PARAMETER  DestroyTrue
			Sets Operation To Destroy
		.EXAMPLE
			PS C:\> Start-TfCloudRun -name workspace1
	#>
	[CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
	param(
		[Parameter(ValueFromPipelineByPropertyName, Mandatory=$True, HelpMessage="TFCloud Workspace Name")]
		[Alias('Name')]
		[string[]]$WorkspaceName,
		[Parameter(Mandatory=$True, HelpMessage="Run Message")]
		[string]$Message,
		[string]$configVersionId,
		[switch]$DestroyTrue = $False
	)
	begin {
		Write-Verbose "Creating TF Cloud Workspace Runs"
	} 
	process { 
		$url = "$($Global:DefaultTfCloudOrg.ServerUri)runs"
		foreach ( $workspace in $WorkspaceName) {
			Write-Verbose "Looking Up Id For Workspace: $workspace"
			$workspaceDetails = Get-TfCloudWorkspaces -Name $workspace
			$workspaceId = $workspaceDetails.id

			$bodyObject = @{
            	"data" = @{
                	"attributes" = @{
						"is-destroy" = $DestroyTrue
						"message" = $Message
					}
                	"type" = "runs"
					"relationships" = @{
						"workspace" = @{
							"data" = @{
								"type" = "workspaces"
								"id" = $workspaceId
							}
						}
					}
            	}
        	}
			if ( $configVersionId ) {
				$config_version = @{
					"configuration-version" = @{
						"data" = @{
							"type" = "configuration-versions"
							"id" = $configVersionId
						}
					}
				}
				$bodyObject.data = $bodyObject.data += $config_version
			}
			$body = $bodyObject | ConvertTo-Json -Depth 5

			if ($PSCmdlet.ShouldProcess($workspace)) {
				$workspaceRun = Calling-Post -url $url -Body $body
				$workspaceRun.data | Add-Member -NotePropertyName "status" -NotePropertyValue $workspaceRun.data.attributes.status
				$workspaceRun.data | Add-Member -NotePropertyName "workspaceName" -NotePropertyValue $workspace
				Write-Output $workspaceRun.data
			}
		}
	}
}
Function Get-TfCloudRunDetails {
	<#
		.SYNOPSIS
			Gets Details On A TF Cloud Run, Can Wait For Completion
		.DESCRIPTION
			Gets Details On A TF Cloud Run, Can Wait For Completion
		.PARAMETER  RunID
			TFCloud Run IDs To Get Details On
		.PARAMETER  WaitForCompletion
			Wait for the TF Cloud Run to complete.
		.PARAMETER  StopAtPlanned
			When waiting for TF Cloud Run to complete, exit when the status is Planned.
		.EXAMPLE
			PS C:\> Get-TfCloudRunDetails -RunID run-xxxx
	#>
    [CmdletBinding()]
    [OutputType([Object])]
    Param(
        [Parameter(ValueFromPipelineByPropertyName, Mandatory = $true, HelpMessage = "TF Cloud Run Id.")]
		[Alias('Id')]
		[string[]]$RunID,
        [Parameter(Mandatory=$false, HelpMessage = "Wait for the TF Cloud Run to complete.")]
		[Switch]$WaitForCompletion,
        [Parameter(Mandatory=$false, HelpMessage = "When waiting for TF Cloud Run to complete, exit when the status is Planned.")]
		[Switch]$StopAtPlanned
    )
	Begin {
		Write-verbose "Getting TF Cloud Run Details"
    	$StatesToWaitFor = @("applying", 'apply_queued', "canceled", "confirmed", "pending", "planning", "policy_checked", "policy_checking", "policy_override", "plan_queued")
		If (!$StopAtPlanned)
    	{
        	$StatesToWaitFor += 'planned'
    	}
	}
	Process {
		foreach ( $run in $runId ) {
			$url = "$($Global:DefaultTfCloudOrg.ServerUri)runs/${run}"
			Write-verbose "Getting Run Details for Id: $run"
			if ($WaitForCompletion) {
            	$bFirstRequest = $true
            	do {
                	if (!$bFirstRequest) { Start-Sleep 10 }
					$runDetails = Calling-Get -url $url
					$bFirstRequest = $false
					$runStatus = $runDetails.data.attributes.status
					$runDetails.data | Add-Member -NotePropertyName "status" -NotePropertyValue $runStatus
                	Write-Verbose "Terraform Workspace Run '$RunID' in '$runStatus' state"
            	} while ($runStatus -in $StatesToWaitFor)
        	} else {
            	$runDetails = Calling-Get -url $url
            	$runStatus = $runDetails.data.attributes.status
				$runDetails.data | Add-Member -NotePropertyName "status" -NotePropertyValue $runStatus
        	}
			$runWorkspaceId = $runDetails.data.relationships.workspace.data.id
			$runWorkspaceDetails = Get-TfCloudWorkspaceDetails -WorkspaceId $runWorkspaceId
			$runDetails.data | Add-Member -NotePropertyName "workspaceName" -NotePropertyValue $runWorkspaceDetails.name
			Write-Output $runDetails.data
    	}
	}    
}
Function Get-TFCloudPlan {
	<#
		.SYNOPSIS
			Gets A Plan For A TFCloud Run
		.DESCRIPTION
			Gets A Plan For A TFCloud Run
		.PARAMETER  RunID
			TFCloud Run ID To Query
		.EXAMPLE
			PS C:\> Get-TFCloudPlan -RunID run-xxxx
	#>
    [CmdletBinding()]
    [OutputType([Object])]
    Param(
		[Parameter(ValueFromPipelineByPropertyName, Mandatory = $true, HelpMessage = "TF Cloud Run Id.")]
		[Alias('Id')]
		[string[]]$RunID
    )
	Begin {
		Write-Verbose "Getting TF Cloud Plans For Runs"
	}
	Process {
		foreach ( $run in $RunID ) {
			Write-Verbose "Getting TF Cloud Plan For Run Id: $run"
			$url = "$($Global:DefaultTfCloudOrg.ServerUri)runs/${run}"
			$runsList = Calling-Get -url $url
			foreach ($runOut in $runsList.data) {
				$planId = $runOut.relationships.plan.data.id
				$url = "$($Global:DefaultTfCloudOrg.ServerUri)plans/${planId}"
				$planList = Calling-Get -url $url
				foreach($plan in $planList.data) {
					Write-Output $plan
				}
			}
		}
	}
}
Function Get-TFCloudPlanLog {
	<#
		.SYNOPSIS
			Gets A Plan Log For A TFCloud Plan
		.DESCRIPTION
			Gets A Plan Log For A TFCloud Plan
		.PARAMETER  PlanId
			TFCloud Plan ID To Query
		.EXAMPLE
			PS C:\> Get-TFCloudPlanLog -PlanId plan-xxxx
	#>
    [CmdletBinding()]
    [OutputType([string])]
    Param(
        [Parameter(ValueFromPipelineByPropertyName, Mandatory = $true, HelpMessage = "TF Cloud Plan Id.")]
		[Alias('Id')]
		[string[]]$PlanId
    )
	Begin {
		Write-Verbose "Getting TF Cloud Plan Logs"
	}
	Process {
		foreach ( $plan in $PlanID ) {
			Write-Verbose "Getting TF Cloud Plan Log For Plan Id: $plan"
			$url = "$($Global:DefaultTfCloudOrg.ServerUri)plans/${plan}"
			$planList = Calling-Get -url $url
			foreach ($planOut in $planList.data) {
				$planLogUri = $planOut.attributes.'log-read-url'
				$planLog = Calling-Get -url $planLogUri
				Write-Output $planLog
			}
		}
	}
}
function Get-TfCloudConfigVersionsByWorkspace {
	<#
		.SYNOPSIS
			Gets List Of Configuration Versions From TFCloud Workspace
		.DESCRIPTION
			Gets List Of Configuration Versions From TFCloud Workspace
		.PARAMETER  WorkspaceName
			TFCloud Workspace Name to list Configuration Versions For.  
		.EXAMPLE
			PS C:\> Get-TfCloudConfigVersions
		.EXAMPLE
			PS C:\> Get-TfCloudConfigVersions -name workspace1
	#>
	[CmdletBinding()]
	[OutputType([Object])]
	param(
		[Parameter(ValueFromPipelineByPropertyName, Mandatory=$True, HelpMessage="TFCloud Workspace Name")]
		[Alias('Name')]
		[string[]]$WorkspaceName
	)
	begin {
		Write-Verbose "Getting TFCloud Configuration Versions"
	} 
	process {
		foreach ( $workspace in $WorkspaceName ) {
			Write-Verbose "Getting Configuration Versions For Workspace: $workspace"
			$workspaceDetails = Get-TfCloudWorkspaces -Name $workspace
			$workspaceId = $workspaceDetails.id

			$url = "$($Global:DefaultTfCloudOrg.ServerUri)workspaces/${workspaceId}/configuration-versions"
			$configVersionList = Calling-Get -url $url
			foreach ($configVersion in $configVersionList.data) {
				write-output $configVersion
			}
		}
	}
}
function Get-TfCloudConfigVersionDetails {
	<#
		.SYNOPSIS
			Gets Configuration Version By ID
		.DESCRIPTION
			Gets Configuration Version By ID
		.PARAMETER  configVersionId
			TFCloud Config Version Id To List
		.EXAMPLE
			PS C:\> Get-function Get-TfCloudConfigVersion -configVersionId cv-xxxxxxx
	#>
	[CmdletBinding()]
	[OutputType([Object])]
	param(
		[Parameter(ValueFromPipelineByPropertyName, Mandatory=$True, HelpMessage="TFCloud Config Version Id")]
		[Alias('Id')]
		[string[]]$configVersionId
	)
	begin {
		Write-Verbose "Getting TFCloud Configuration Version Details"
	} 
	process {
		foreach ( $configId in $configVersionId ) {
			Write-Verbose "Getting Configuration Version For ID: $configVersionId"
			$url = "$($Global:DefaultTfCloudOrg.ServerUri)configuration-versions/${configId}"
			$configVersionList = Calling-Get -url $url
			foreach ($configVersion in $configVersionList.data) {
				write-output $configVersion
			}
		}
	}
}
function Get-TfCloudOAuthClients {
	<#
		.SYNOPSIS
			Gets List Of OAuth Clients From TFCloud Organization. Lists all OAuth Clients if no name(s) specified.
		.DESCRIPTION
			Gets List Of OAuth Clients From TFCloud Organization. Lists all OAuth Clients if no name(s) specified.
		.PARAMETER  Name
			TFCloud OAuth Clients Name(s) to list.  Lists all OAuth Clients if left blank
		.EXAMPLE
			PS C:\> Get-TfCloudOAuthClients
		.EXAMPLE
			PS C:\> Get-TfCloudOAuthClients -name client1,client2
	#>
	[CmdletBinding()]
	[OutputType([Object])]
	param(
		[Parameter(ValueFromPipeline=$True, HelpMessage="TFCloud OAuth Client Names")]
		[string[]]$Name
	)
	begin {
		Write-Verbose "Getting TFCloud OAuth Clients"
	} 
	process {
		$url = "$($Global:DefaultTfCloudOrg.OrganizationUri)oauth-clients"
		$oauthClientList = Calling-Get -url $url
		foreach ($client in $oauthClientList.data) {
			$client | Add-Member -NotePropertyName "name" -NotePropertyValue $client.attributes.name
			if ( $name ) { 
				foreach ( $clientName in $name ) {
					if ($client.name -eq $clientName) {
						write-output $client
					}
				}
			} else {
				write-output $client
			}
		}
	}
	
}
function Get-TfCloudOAuthTokens {
	<#
		.SYNOPSIS
			Gets List Of OAuth Tokens From TFCloud OAuth Client
		.DESCRIPTION
			Gets List Of OAuth Tokens From TFCloud OAuth Client
		.PARAMETER  Name
			TFCloud OAuth Clients Name to get tokens from.
		.EXAMPLE
			PS C:\> Get-TfCloudOAuthTokens
		.EXAMPLE
			PS C:\> Get-TfCloudOAuthTokens -name client1
	#>
	[CmdletBinding()]
	[OutputType([Object])]
	param(
		[Parameter(ValueFromPipelineByPropertyName, Mandatory=$True, HelpMessage="TFCloud OAuth Client Id")]
		[Alias('Id')]
		[string[]]$clientId
	)
	begin {
		Write-Verbose "Getting TFCloud OAuth Tokens"
	} 
	process {
		foreach ( $id in $clientId ) {
			Write-Verbose "Getting OAuth Token For ClientId: $id"
			$url = "$($Global:DefaultTfCloudOrg.ServerUri)oauth-clients/${id}/oauth-tokens"
			$oauthTokenList = Calling-Get -url $url
			foreach ($token in $oauthTokenList.data) {
				write-output $token
			}
		}
	}
}

export-modulemember -Function Connect-JpTfCloud
export-modulemember -Function Disconnect-JpTfCloud
export-modulemember -Function Get-TfCloudWorkspace
export-modulemember -Function Get-TfCloudWorkspaceDetails
export-modulemember -Function New-TfCloudWorkspace
export-modulemember -Function Get-TfCloudRunsByWorkspace
export-modulemember -Function Get-TfCloudRunDetails
export-modulemember -Function Start-TfCloudRun
export-modulemember -Function Get-TFCloudPlan
export-modulemember -Function Get-TFCloudPlanLog
export-modulemember -Function Get-TfCloudConfigVersionsByWorkspace
export-modulemember -Function Get-TfCloudConfigVersionDetails
export-modulemember -Function Get-TfCloudOAuthClients
export-modulemember -Function Get-TfCloudOAuthTokens