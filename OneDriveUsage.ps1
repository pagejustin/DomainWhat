<#
.SYNOPSIS
  Name: Get-OneDriveUsageData.ps1
  The purpose of this script gets usage data from personal OneDrive Folders
  
.DESCRIPTION
  This script queries usage data of Office 365 SharePoint <tenant>-my.sharepoint.com/personal sites. It doesn't look for licensed OneDrive users but for actual activity in OneDrive sites. It gives a more accurate picture of who is actually using OneDrive.

.PARAMETER InitialDirectory
  The initial directory which this example script will use.
  
.PARAMETER Add
  A switch parameter that will cause the example function to ADD content. Add or remove PARAMETERs as required.

.NOTES
    Updated: 2020-05-25       First File to Github.
   
  Author: Justin Page

.EXAMPLE

.EXAMPLE 

See Help about_Comment_Based_Help for more .Keywords

#>
param(
  [parameter()]
  [string]$SPOAdminURL
)

$fileExport = "$Env:homepath\OneDriveUsers.csv"

Connect-SPOService -Url $SPOAdminURL 

Get-SPOSite -Template SPSPERS#10 -IncludePersonalSite:$true -Limit ALL | select LastContentModifiedDate, Status, StorageUsageCurrent, URL, Owner, Title, StorageQuota | Export-Csv "$fileExport" -NoTypeInformation
