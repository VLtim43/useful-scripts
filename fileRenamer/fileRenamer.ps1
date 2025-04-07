param(
    [Parameter(Mandatory = $true)]
    [string]$FolderPath,

    [Parameter(Mandatory = $true)]
    [string]$StringToRemove
)

# Get all files in the folder
Get-ChildItem -Path $FolderPath -File | ForEach-Object {
    $oldName = $_.Name
    $newName = $oldName -replace [regex]::Escape($StringToRemove), ""

    Write-Host "Renaming '$oldName' to '$newName'"

    if ($newName -ne $oldName) {
        Rename-Item -Path $_.FullName -NewName $newName
    }
}
