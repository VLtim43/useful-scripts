$filePath = "input.txt"

$currentAuthor = ""

$outputDirectory = Join-Path (Get-Location) "output"
if (-not (Test-Path $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}

$galleryDlPath = "$HOME/Downloads/gallery-dl.exe"

# Read file and process each line
Get-Content $filePath | ForEach-Object {
    $line = $_.Trim()

    if ($line -notmatch "^https?://") {
        # Update the current author
        $currentAuthor = $line
    }
    else {
        # Split the line into URL and tags
        $parts = $line -split '\s+'
        $url, $tags = $line -split '\s+', 2
        $tags = $tags -replace '^\s*', '' 


        if ($tags -ne "") {
            $outputFilename = "${currentAuthor} ${tags} {filename}.{extension}"
        }
        else {
            $outputFilename = "${currentAuthor} {filename}.{extension}"
        }

        # Log for debugging
        # Write-Output $url, $tags

         & $galleryDlPath $url --filename $outputFilename --dest $outputDirectory -o skip=false
        # & $galleryDlPath -K $url > tmpfile.txt
    }
}
