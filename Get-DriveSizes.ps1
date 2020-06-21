$jsonExternals = Get-Content .\externalVariables.json | ConvertFrom-Json

#generate list from file share named in external variables use the exclude swtich to prevent retreiving files based on expression
$folders = Get-ChildItem $jsonExternals.Paths.SourceFolder # -Exclude z-* 
#read from file 
$queryList = Get-Content $jsonExternals.Paths.ImportList

#change between $queryList or $folders if reading from a CSV or a folder
foreach ($folder in $queryList) {
        $folderName = $folder
        $sourceFolder = $jsonExternals.Paths.SourceFolder+$folderName
        Write-Host "1 - Querying Source Folder $sourceFolder"
        $folderInfo = Get-Item $sourceFolder -ErrorAction Continue -ErrorVariable ProcessError | Select-Object PSChildName, LastAccessTime, LastWriteTime, Attributes
        if ($ProcessError) {
            Write-Host "1.5 - No folder" 
            Continue
        }             
        else {
            Write-Host "2 - Calculating $folder"
            $folderSize = "{0} GB" -f [math]::Round(((Get-ChildItem $sourceFolder -Recurse -File | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1GB), 2)
            $Output = @{
                    PSChildName = $folderInfo.PSChildName
                    SizeGB = $folderSize
                    LastAccessTime = $folderInfo.LastAccessTime
                    LastWriteTime = $folderInfo.LastWriteTime
                    Attributes = $folderInfo.Attributes} 
            Write-Host "3 - Writing results to file"
            New-Object PSObject -property $Output | Select-Object PSChildName, SizeGB, LastAccessTime, LastWriteTime, Attributes | Export-Csv $jsonExternals.Paths.ExportFile -Append -NoTypeInformation
        }
    }
