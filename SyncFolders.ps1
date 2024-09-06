function SyncFolders {
    param(
        [string]$sourcePath,
        [string]$replicaPath,
        [string]$logPath
    )
    $sourceItems = Get-ChildItem $sourcePath -Recurse
    $replicaItems = Get-ChildItem $replicaPath -Recurse

    #create log
    New-Item -Path $logPath -ItemType File -Force

    foreach ($sourceItem in $sourceItems) {
        $replicaItem = $replicaItems | Where-Object { $_.FullName -eq $sourceItem.FullName }

        if ($replicaItem) {
            if ($sourceItem.LastWriteTime -ne $replicaItem.LastWriteTime) {
                Write-Host "copy $sourceItem.FullName to $replicaItem.FullName"
                Copy-Item $sourceItem.FullName $replicaItem.FullName -Force
                Add-Content $logPath "copy $sourceItem.FullName to $replicaItem.FullName"
            }
        } else {
            #add replica
            Write-Host "add $sourceItem.FullName in $replicaPath"
            Copy-Item $sourceItem.FullName $replicaPath -Force
            Add-Content $logPath "add $sourceItem.FullName in $replicaPath"
        }
    }
    #delete 
    $replicaItems | Where-Object { -not ($sourceItems | Where-Object { $_.FullName -eq $_.FullName })} | Remove-Item -Force
    Add-Content $logPath "delete items from $replicaPath doesn't in $sourcePath"
}




$sourcePath = $args[0]
$replicaPath = $args[1]
$logPath = $args[2]
if ($sourcePath -and $replicaPath -and $logPath) {
    SyncFolders $sourcePath $replicaPath $logPath
} else {
    Write-Error "no source, replica, or log"
}

