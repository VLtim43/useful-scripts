$filePath = "input.txt"

# Initialize variables
$currentGallery = ""
$outputDirectory = Join-Path (Get-Location) "output"
$galleryDlPath = "$HOME/Downloads/gallery-dl.exe"

# Ensure the output directory exists
if (-not (Test-Path $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}

# Process the input file
Get-Content $filePath | ForEach-Object {
    $line = $_.Trim()

    if ($line -notmatch "^https?://") {
        # Update the current gallery name
        $currentGallery = $line
    }
    else {
        # Extract URL and optional author from the line
        $urlParts = $line -split '\s+', 2
        $url = $urlParts[0]
        $author = if ($urlParts.Count -eq 2) { $urlParts[1] } else { "" }

        # Build the output filename dynamically
        #if ($currentGallery -ne "" -and $author -ne "") {
        #    $outputFilename = "[${author}][${currentGallery}]{id}.{extension}"
        #}
        #elseif ($currentGallery -ne "") {
        #    $outputFilename = "[${currentGallery}]{id}.{extension}"
        #}
        #elseif ($author -ne "") {
        #    $outputFilename = "[${author}]{id}.{extension}"
        #}
        #else {
        #    $outputFilename = "{id}.{extension}"
        #}

 	$outputFilename = "{id}.{extension}"

        # Run gallery-dl with the constructed filename
        & $galleryDlPath $url --filename $outputFilename --dest $outputDirectory -o skip=false
    }
}
