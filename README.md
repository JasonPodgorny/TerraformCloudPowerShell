# JP_TfCloud_Powershell
Powershell Module For Managing Terraform Cloud API Via REST Calls.   Extremely fast.   Can be expanded quickly.   This entire module was created in about a day, you essentially just create functions to map to the API call, make the call, return the resulting object.

Terraform Cloud has lots of cool options that are available in REST so more will be added as more use cases are needed and you can take this and easily add your own.

Slightly limited set of commandlets to start, some were created from scratch, others were borrowed and rewritten to conform to my personal style from here: https://github.com/tyconsulting/TerraformEnterprise-PS

You can chain them together, for example:
```
Get-TfCloudWorkspace | Get-TfCloudRunsByWorkspace | Get-TfCloudPlan
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