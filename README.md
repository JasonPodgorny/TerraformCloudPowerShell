# JP_TfCloud_Powershell
Powershell Module For Managing Terraform Cloud API Via REST Calls.   Extremely fast.   Can be expanded quickly.   This entire module was created in about a day, you essentially just create functions to map to the API call, make the call, return the resulting object.

Terraform Cloud has lots of cool options that are available in REST so more will be added as more use cases are needed and you can take this and easily add your own.

Slightly limited set of commandlets to start, some were created from scratch, others were borrowed and rewritten to conform to my personal style from here: https://github.com/tyconsulting/TerraformEnterprise-PS

One enhancement over the above reference module is that the commandlets are designed to take pipeline inputs from each other so you can chain them together.  For example you can start a run and wait for completion in one simple command like in the outputs below.

You could use Get-Workspace to get a full list of workspaces and pipe that into these to execute a run across all of them.   Lots of options for using in combination.

```
terraform> Start-TfCloudRun -WorkspaceName centralus_dev_app-test_rg-test -Message "Test Run" | Get-TfCloudRunDetails -WaitForCompletion -Verbose
VERBOSE: Getting TF Cloud Run Details

Confirm
Are you sure you want to perform this action?
Performing the operation "Start-TfCloudRun" on target "centralus_dev_app-test_rg-test".
[Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"): y


VERBOSE: Getting Run Details for Id: run-kr3E9GArHeWcCzg1
VERBOSE: Invoking REST GET at URL https://app.terraform.io/api/v2/runs/run-kr3E9GArHeWcCzg1
VERBOSE: GET https://app.terraform.io/api/v2/runs/run-kr3E9GArHeWcCzg1 with 0-byte payload
VERBOSE: received 1711-byte response of content type application/vnd.api+json; charset=utf-8
VERBOSE: Terraform Workspace Run 'run-kr3E9GArHeWcCzg1' in 'pending' state
VERBOSE: Invoking REST GET at URL https://app.terraform.io/api/v2/runs/run-kr3E9GArHeWcCzg1
VERBOSE: GET https://app.terraform.io/api/v2/runs/run-kr3E9GArHeWcCzg1 with 0-byte payload
VERBOSE: received 1848-byte response of content type application/vnd.api+json; charset=utf-8
VERBOSE: Terraform Workspace Run 'run-kr3E9GArHeWcCzg1' in 'planning' state
VERBOSE: Invoking REST GET at URL https://app.terraform.io/api/v2/runs/run-kr3E9GArHeWcCzg1
VERBOSE: GET https://app.terraform.io/api/v2/runs/run-kr3E9GArHeWcCzg1 with 0-byte payload
VERBOSE: received 1848-byte response of content type application/vnd.api+json; charset=utf-8
VERBOSE: Terraform Workspace Run 'run-kr3E9GArHeWcCzg1' in 'planning' state
VERBOSE: Invoking REST GET at URL https://app.terraform.io/api/v2/runs/run-kr3E9GArHeWcCzg1
VERBOSE: GET https://app.terraform.io/api/v2/runs/run-kr3E9GArHeWcCzg1 with 0-byte payload
VERBOSE: received 2005-byte response of content type application/vnd.api+json; charset=utf-8
VERBOSE: Terraform Workspace Run 'run-kr3E9GArHeWcCzg1' in 'planned_and_finished' state
VERBOSE: Getting TFCloud Workspaces
VERBOSE: Getting TFCloud Workspace For Id: ws-NgL72A1hy88hdjVX
VERBOSE: Invoking REST GET at URL https://app.terraform.io/api/v2/workspaces/ws-NgL72A1hy88hdjVX
VERBOSE: GET https://app.terraform.io/api/v2/workspaces/ws-NgL72A1hy88hdjVX with 0-byte payload
VERBOSE: received -1-byte response of content type application/vnd.api+json; charset=utf-8


id            : run-kr3E9GArHeWcCzg1
type          : runs
attributes    : @{actions=; canceled-at=; created-at=2021-04-14T19:28:02.088Z; has-changes=False; is-destroy=False; message=Test Run; plan-only=False; source=tfe-api; status-timestamps=; status=planned_and_finished;
                trigger-reason=manual; target-addrs=; permissions=}
relationships : @{workspace=; apply=; configuration-version=; created-by=; plan=; run-events=; policy-checks=; comments=}
links         : @{self=/api/v2/runs/run-kr3E9GArHeWcCzg1}
status        : planned_and_finished
workspaceName : centralus_dev_app-test_rg-test


```

This module also serves as a great starting point for any REST oriented Powershell modules, and could be repurposed with the calls to TF Cloud being replaced with calls to any REST based endpoint.   This was repurposed from one of my other REST examples in a very short time.

Current Commandlets:

```
Connect-JpTfCloud
Disconnect-JpTfCloud
```

```
Get-TfCloudWorkspace
Get-TfCloudWorkspaceDetails
New-TfCloudWorkspace
```

```
Get-TfCloudRunsByWorkspace
Get-TfCloudRunDetails
Start-TfCloudRun
Get-TFCloudPlan
Get-TFCloudPlanLog
```

```
Get-TfCloudConfigVersionsByWorkspace
Get-TfCloudConfigVersionDetails
```

```
Get-TfCloudOAuthClients
Get-TfCloudOAuthTokens
```