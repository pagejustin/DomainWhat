$jsonExternals = Get-Content .\externalVariables.json | ConvertFrom-Json

#generate list from file share named in external variables use the exclude swtich to prevent retreiving files based on expression
$folders = Get-ChildItem $jsonExternals.Paths.SourceFolder # -Exclude z-*
$folders | Export-Csv $jsonExternals.Paths.ImportList
#read from file 
$queryList = Import-CSV $jsonExternals.Paths.ImportList

#change between $queryList or $folders if reading from a CSV or a folder
foreach ($folder in $queryList) {
        $folderName = $folder.PSChildName
        $sourceFolder = $jsonExternals.Paths.SourceFolder+$folderName
        Write-Host "1 - Querying Source Folder $sourceFolder"
        $folderInfo = Get-Item $sourceFolder -ErrorAction Continue -ErrorVariable ProcessError | Select-Object PSChildName, LastAccessTime, LastWriteTime, Attributes
        if ($ProcessError) {
            Write-Host "1.5 - No folder" 
            Continue
        }             
        else {
            Write-Host "2 - Calculating $folderName"
            $folderSize = (Get-ChildItem $sourceFolder -Recurse -File | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum #full byte size of folder - even the small stuff counts
            $folderSizeGB = "{0}" -f [math]::Round(($folderSize / 1GB), 4) #Math to determine size in GB to the 4th decimal
            $Output = @{
                    PSChildName = $folderInfo.PSChildName
                    size = $folderSize
                    SizeGB = $folderSizeGB
                    LastAccessTime = $folderInfo.LastAccessTime
                    LastWriteTime = $folderInfo.LastWriteTime
                    Attributes = $folderInfo.Attributes} 
            Write-Host "3 - Writing results to file"
            New-Object PSObject -property $Output | Select-Object PSChildName, Size, SizeGB, LastAccessTime, LastWriteTime, Attributes | Export-Csv $jsonExternals.Paths.ExportFile -Append -NoTypeInformation
        }
    }

