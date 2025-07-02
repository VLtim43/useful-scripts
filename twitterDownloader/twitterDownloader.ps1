<#
.SYNOPSIS
    Generic PS1 skeleton: loads .env, sets up per-script output folder, loops over inputs.

.PARAMETER InputPath
    Path to a file or folder to process. If omitted, you can define your own default.

.PARAMETER Verbose
    Enables verbose logging.
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false)][string]$InputPath,
    [switch]$Verbose
)

### 1. Load .env ###
function Load-DotEnv {
    param([string]$Path = ".env")
    if (Test-Path $Path) {
        Get-Content $Path | ForEach-Object {
            $line = $_.Trim()
            if ($line -like '#*' -or [string]::IsNullOrWhiteSpace($line)) { return }
            $parts = $line -split '=', 2
            if ($parts.Count -eq 2) {
                $key   = $parts[0].Trim()
                $value = $parts[1].Trim().Trim("'`"")
                # Export as env-var and PS variable
                $Env:$key = $value
                Set-Variable -Scope Global -Name $key -Value $value
            }
        }
    }
}
Load-DotEnv

### 2. Determine global output root ###
if ($Env:GLOBAL_OUTPUT) {
    $GlobalOutput = $Env:GLOBAL_OUTPUT
} else {
    $GlobalOutput = Join-Path $PSScriptRoot "output"
}
if (-not (Test-Path $GlobalOutput)) {
    New-Item -ItemType Directory -Path $GlobalOutput | Out-Null
}

### 3. Create per-script output folder ###
$ScriptName = [IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
$OutputDir  = Join-Path $GlobalOutput $ScriptName
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

### 4. Gather items to process ###
if ($InputPath) {
    if (-not (Test-Path $InputPath)) {
        Write-Error "Input path '$InputPath' not found."
        exit 1
    }
    $itm = Get-Item $InputPath
    $Items = $itm.PSIsContainer ? (Get-ChildItem $itm.FullName -File) : ,$itm
} else {
    # fallback: e.g. all .txt in script folder
    $Items = Get-ChildItem -Path $PSScriptRoot -Filter '*.txt' -File
}

$Total     = $Items.Count
$Processed = 0
$Failed    = 0

### 5. Main loop ###
foreach ($Item in $Items) {
    try {
        Write-Verbose "Processing: $($Item.FullName)"
        # >>> INSERT YOUR CUSTOM LOGIC HERE <<<
        # e.g.:
        #   $lines = Get-Content $Item.FullName
        #   foreach ($line in $lines) { … }
        #   Export results into $OutputDir

        # simulate success
        $Processed++
    }
    catch {
        Write-Warning "Failed on $($Item.Name): $_"
        $Failed++
    }
}

### 6. Summary ###
Write-Host "`n=== Summary for '$ScriptName' ==="
Write-Host " Total items : $Total"
Write-Host " Processed   : $Processed"
Write-Host " Failed      : $Failed"
