[CmdletBinding()]
param(
    [string]$SourceRepo = "Sallehhuddin95/architecture-guidelines-kit",
    [string]$Branch = "main",
    [string]$TargetPath = "."
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Section {
    param([string]$Message)

    Write-Host ""
    Write-Host $Message -ForegroundColor Cyan
}

function Read-Choice {
    param(
        [string]$Prompt,
        [object[]]$Options,
        [string]$DefaultKey
    )

    while ($true) {
        Write-Host ""
        Write-Host $Prompt -ForegroundColor Yellow

        for ($index = 0; $index -lt $Options.Count; $index++) {
            $option = $Options[$index]
            Write-Host ("{0}. {1}" -f ($index + 1), $option.Label)
        }

        $raw = Read-Host ("Choose 1-{0} [{1}]" -f $Options.Count, $DefaultKey)

        if ([string]::IsNullOrWhiteSpace($raw)) {
            $raw = $DefaultKey
        }

        if ($raw -match '^\d+$') {
            $numericIndex = [int]$raw - 1
            if ($numericIndex -ge 0 -and $numericIndex -lt $Options.Count) {
                return $Options[$numericIndex].Key
            }
        }

        foreach ($option in $Options) {
            if ($raw -eq $option.Key) {
                return $option.Key
            }
        }

        Write-Host "Invalid choice. Try again." -ForegroundColor Red
    }
}

function Read-YesNo {
    param(
        [string]$Prompt,
        [bool]$Default = $true
    )

    $defaultToken = if ($Default) { "Y/n" } else { "y/N" }

    while ($true) {
        $raw = Read-Host ("{0} [{1}]" -f $Prompt, $defaultToken)

        if ([string]::IsNullOrWhiteSpace($raw)) {
            return $Default
        }

        switch ($raw.Trim().ToLowerInvariant()) {
            "y" { return $true }
            "yes" { return $true }
            "n" { return $false }
            "no" { return $false }
            default { Write-Host "Please answer yes or no." -ForegroundColor Red }
        }
    }
}

function Ensure-ParentDirectory {
    param([string]$Path)

    $parent = Split-Path -Path $Path -Parent
    if (-not [string]::IsNullOrWhiteSpace($parent) -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent | Out-Null
    }
}

function Copy-Selection {
    param(
        [string]$SourceRoot,
        [string]$DestinationRoot,
        [string]$RelativePath,
        [bool]$OverwriteExisting,
        [System.Collections.Generic.List[string]]$Copied,
        [System.Collections.Generic.List[string]]$Skipped
    )

    $sourcePath = Join-Path $SourceRoot $RelativePath
    $destinationPath = Join-Path $DestinationRoot $RelativePath

    if (-not (Test-Path -LiteralPath $sourcePath)) {
        throw "Missing source path: $RelativePath"
    }

    if ((Test-Path -LiteralPath $destinationPath) -and -not $OverwriteExisting) {
        $Skipped.Add($RelativePath)
        return
    }

    if ((Get-Item -LiteralPath $sourcePath) -is [System.IO.DirectoryInfo]) {
        Ensure-ParentDirectory -Path $destinationPath
        Copy-Item -LiteralPath $sourcePath -Destination $destinationPath -Recurse -Force
    }
    else {
        Ensure-ParentDirectory -Path $destinationPath
        Copy-Item -LiteralPath $sourcePath -Destination $destinationPath -Force
    }

    $Copied.Add($RelativePath)
}

function Add-UniquePath {
    param(
        [System.Collections.Generic.List[string]]$Paths,
        [string]$RelativePath
    )

    if (-not $Paths.Contains($RelativePath)) {
        $Paths.Add($RelativePath)
    }
}

Write-Section "Architecture Guidelines Kit Installer"
Write-Host "Target repo: $(Resolve-Path -LiteralPath $TargetPath)"

$installMode = Read-Choice -Prompt "What are you setting up?" -DefaultKey "1" -Options @(
    @{ Key = "new"; Label = "New project repo" },
    @{ Key = "existing"; Label = "Existing project repo" }
)

$projectType = Read-Choice -Prompt "What kind of project is this?" -DefaultKey "3" -Options @(
    @{ Key = "frontend"; Label = "Frontend only" },
    @{ Key = "backend"; Label = "Backend only" },
    @{ Key = "fullstack"; Label = "Full stack" },
    @{ Key = "generic"; Label = "Generic or undecided" }
)

$setupLevel = Read-Choice -Prompt "How much guidance do you want?" -DefaultKey "1" -Options @(
    @{ Key = "minimal"; Label = "Minimal core guidance" },
    @{ Key = "full"; Label = "Full governance setup" }
)

$includeAgents = Read-YesNo -Prompt "Include Copilot custom agents?" -Default ($setupLevel -eq "full")
$includeWorkflow = Read-YesNo -Prompt "Include workflow guides?" -Default ($setupLevel -eq "full")
$includeSpecs = Read-YesNo -Prompt "Include spec templates and spec guides?" -Default $true
$includeAdrStarters = Read-YesNo -Prompt "Include starter ADR files?" -Default ($setupLevel -eq "full")
$overwriteExisting = Read-YesNo -Prompt "Overwrite existing matching files in the target repo?" -Default $false

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("architecture-guidelines-kit-" + [guid]::NewGuid().ToString("N"))
$zipPath = Join-Path $tempRoot "repo.zip"
$extractRoot = Join-Path $tempRoot "extract"

$repoName = ($SourceRepo.TrimEnd("/") -split "/")[-1]
$archiveFolder = "{0}-{1}" -f $repoName, $Branch
$sourceArchiveUrl = "https://github.com/{0}/archive/refs/heads/{1}.zip" -f $SourceRepo, $Branch

$copied = [System.Collections.Generic.List[string]]::new()
$skipped = [System.Collections.Generic.List[string]]::new()
$pathsToCopy = [System.Collections.Generic.List[string]]::new()

try {
    New-Item -ItemType Directory -Path $tempRoot | Out-Null
    New-Item -ItemType Directory -Path $extractRoot | Out-Null

    Write-Section "Downloading source repo"
    Write-Host $sourceArchiveUrl
    Invoke-WebRequest -Uri $sourceArchiveUrl -OutFile $zipPath
    Expand-Archive -Path $zipPath -DestinationPath $extractRoot -Force

    $sourceRoot = Join-Path $extractRoot $archiveFolder
    if (-not (Test-Path -LiteralPath $sourceRoot)) {
        throw "Downloaded archive did not contain expected folder: $archiveFolder"
    }

    $resolvedTarget = Resolve-Path -LiteralPath $TargetPath

    Add-UniquePath -Paths $pathsToCopy -RelativePath "CONSTITUTION.md"
    Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/architecture"
    Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/shared"
    Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/adr/README.md"

    if ($installMode -eq "new") {
        Add-UniquePath -Paths $pathsToCopy -RelativePath "NEW_PROJECT_BOOTSTRAP.md"
    }
    else {
        Add-UniquePath -Paths $pathsToCopy -RelativePath "EXISTING_PROJECT_ADOPTION.md"
    }

    switch ($projectType) {
        "frontend" {
            Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/frontend"
        }
        "backend" {
            Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/backend"
        }
        "fullstack" {
            Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/frontend"
            Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/backend"
        }
    }

    if ($includeWorkflow) {
        Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/workflow"
    }

    if ($includeSpecs) {
        Add-UniquePath -Paths $pathsToCopy -RelativePath "specs"
    }

    if ($includeAdrStarters) {
        Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/adr/0001-adopt-feature-driven-frontend.md"
        Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/adr/0002-adopt-layered-fastapi-backend.md"
        Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/adr/0003-use-server-managed-sessions.md"
        Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/adr/0004-reject-client-tampering-of-protected-fields.md"
    }

    if ($includeAgents) {
        Add-UniquePath -Paths $pathsToCopy -RelativePath ".github/agents"
        Add-UniquePath -Paths $pathsToCopy -RelativePath ".github/instructions"
    }

    Write-Section "Copying selected files"
    foreach ($relativePath in $pathsToCopy) {
        Copy-Selection -SourceRoot $sourceRoot -DestinationRoot $resolvedTarget -RelativePath $relativePath -OverwriteExisting:$overwriteExisting -Copied $copied -Skipped $skipped
    }

    Write-Section "Install summary"
    Write-Host ("Copied: {0}" -f $copied.Count) -ForegroundColor Green
    foreach ($entry in $copied) {
        Write-Host ("  + {0}" -f $entry)
    }

    if ($skipped.Count -gt 0) {
        Write-Host ("Skipped existing: {0}" -f $skipped.Count) -ForegroundColor DarkYellow
        foreach ($entry in $skipped) {
            Write-Host ("  - {0}" -f $entry)
        }
    }

    Write-Section "Read these first"
    Write-Host "1. CONSTITUTION.md"
    Write-Host "2. docs/architecture/ARCHITECTURE_GUIDELINE.md"
    Write-Host "3. docs/shared/"
    if ($projectType -eq "frontend" -or $projectType -eq "fullstack") {
        Write-Host "4. docs/frontend/"
    }
    if ($projectType -eq "backend" -or $projectType -eq "fullstack") {
        Write-Host "4. docs/backend/"
    }

    Write-Host ""
    Write-Host "Trim or rewrite anything that does not match the target repo before real feature work starts." -ForegroundColor Cyan
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}