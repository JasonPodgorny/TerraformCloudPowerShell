# JP_TfCloud_Powershell
Powershell Module For Managing Terraform Cloud API Via REST Calls.   Extremely fast.   Can be expanded quickly.   Terraform Cloud has lots of cool options that are available in REST.

Only have a few functions currently, some were created from scratch, others were borrowed and rewritten to conform to my personal style from here: https://github.com/tyconsulting/TerraformEnterprise-PS

This module also serves as a great starting point for any REST oriented Powershell modules, and could be repurposed with the calls to TF Cloud being replaced with calls to any REST based endpoint.

Current Commandlets:

Connect-JpTfCloud
Disconnect-JpTfCloud

Get-TfCloudWorkspaces
New-TfCloudWorkspace

Get-TfCloudRuns
Get-TfCloudRunDetails
Start-TfCloudRun
Get-TFCloudPlan
Get-TFCloudPlanLog

Get-TfCloudConfigVersions
Get-TfCloudConfigVersion

Get-TfCloudOAuthClients
Get-TfCloudOAuthTokens