Connect-MicrosoftTeams

$Output = ''
$dateTime = Get-Date -Format "yyyMMdd-hhmmss"
# $teams = Get-Team
$fileExport = "$Env:HOMEPATH\Teamsdata$dateTime.csv"

foreach ($team in Get-Team) {
    # $teamUsers = Get-TeamUser -GroupId $team.GroupID
    foreach ($tUser in Get-TeamUser -GroupId $team.GroupID) {
        $Output += $team.DisplayName + "," + $tUser.user + "," + $tUser.Name + "," + $tUser.Role + "`n"
    }
    $Output | Out-File "$fileExport"
}

start notepad.exe $fileExport