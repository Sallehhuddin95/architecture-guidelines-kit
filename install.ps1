[CmdletBinding()]
param(
    [string]$SourceRepo = "Sallehhuddin95/architecture-guidelines-kit",
    [string]$Branch = "main",
    [string]$TargetPath = "."
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Test-InstallerSourceRoot {
    param([string]$Path)

    return (
        (Test-Path -LiteralPath (Join-Path $Path "CONSTITUTION.md")) -and
        (Test-Path -LiteralPath (Join-Path $Path "docs")) -and
        (Test-Path -LiteralPath (Join-Path $Path "specs"))
    )
}

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

function Read-MultiChoice {
    param(
        [string]$Prompt,
        [object[]]$Options
    )

    while ($true) {
        Write-Host ""
        Write-Host $Prompt -ForegroundColor Yellow

        for ($index = 0; $index -lt $Options.Count; $index++) {
            $option = $Options[$index]
            Write-Host ("{0}. {1}" -f ($index + 1), $option.Label)
        }

        $raw = Read-Host "Choose numbers separated by commas (e.g. 1,2)"

        $keys = @()
        $valid = $true

        foreach ($part in ($raw -split ',')) {
            $part = $part.Trim()
            if ($part -match '^\d+$') {
                $numericIndex = [int]$part - 1
                if ($numericIndex -ge 0 -and $numericIndex -lt $Options.Count) {
                    $key = $Options[$numericIndex].Key
                    if ($keys -notcontains $key) {
                        $keys += $key
                    }
                }
                else {
                    $valid = $false
                }
            }
            elseif (-not [string]::IsNullOrWhiteSpace($part)) {
                $valid = $false
            }
        }

        if ($valid -and $keys.Count -gt 0) {
            return $keys
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
    @{ Key = "mobile"; Label = "Mobile only (React Native/Expo)" },
    @{ Key = "fullstack"; Label = "Full stack" },
    @{ Key = "generic"; Label = "Generic or undecided" }
)

$frontendFrameworks = @()
$backendFrameworks = @()

if ($projectType -eq "frontend" -or $projectType -eq "fullstack") {
    $frontendFrameworks = Read-MultiChoice -Prompt "Which frontend framework(s)?" -Options @(
        @{ Key = "nextjs"; Label = "Next.js" },
        @{ Key = "angular"; Label = "Angular (standalone)" }
    )
}

if ($projectType -eq "backend" -or $projectType -eq "fullstack") {
    $backendFrameworks = Read-MultiChoice -Prompt "Which backend framework(s)?" -Options @(
        @{ Key = "fastapi"; Label = "FastAPI" },
        @{ Key = "django"; Label = "Django + DRF" },
        @{ Key = "express"; Label = "Express + TypeScript" }
    )
}

$setupLevel = Read-Choice -Prompt "How much guidance do you want?" -DefaultKey "1" -Options @(
    @{ Key = "minimal"; Label = "Minimal core guidance" },
    @{ Key = "full"; Label = "Full governance setup" }
)

$includeAgents = Read-YesNo -Prompt "Include custom agents (Copilot and opencode)?" -Default ($setupLevel -eq "full")
$includeWorkflow = Read-YesNo -Prompt "Include workflow guides?" -Default ($setupLevel -eq "full")
$includeSpecs = Read-YesNo -Prompt "Include spec templates and spec guides?" -Default $true
$includeMobile = Read-YesNo -Prompt "Also include mobile (React Native/Expo) guidance?" -Default ($projectType -eq "mobile")
$includeAdrStarters = Read-YesNo -Prompt "Include starter ADR files?" -Default ($setupLevel -eq "full")
$overwriteExisting = Read-YesNo -Prompt "Overwrite existing matching files in the target repo?" -Default $false

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("architecture-guidelines-kit-" + [guid]::NewGuid().ToString("N"))
$clonedSourceRoot = Join-Path $tempRoot "source"

$repoCloneUrl = "https://github.com/{0}.git" -f $SourceRepo

$copied = [System.Collections.Generic.List[string]]::new()
$skipped = [System.Collections.Generic.List[string]]::new()
$pathsToCopy = [System.Collections.Generic.List[string]]::new()

try {
    if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot) -and (Test-InstallerSourceRoot -Path $PSScriptRoot)) {
        $sourceRoot = $PSScriptRoot
        Write-Section "Using local source repo"
        Write-Host $sourceRoot
    }
    else {
        New-Item -ItemType Directory -Path $tempRoot | Out-Null

        Write-Section "Cloning source repo"
        Write-Host $repoCloneUrl
        git clone --depth 1 --branch $Branch $repoCloneUrl $clonedSourceRoot | Out-Null

        if ($LASTEXITCODE -ne 0 -or -not (Test-InstallerSourceRoot -Path $clonedSourceRoot)) {
            throw "Failed to clone a usable source repo from $repoCloneUrl"
        }

        $sourceRoot = $clonedSourceRoot
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

    foreach ($framework in $frontendFrameworks) {
        switch ($framework) {
            "nextjs" {
                Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/frontend/FRONTEND_GUIDELINE.md"
                Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/frontend/naming.md"
                Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/frontend/testing.md"
            }
            "angular" {
                Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/frontend/ANGULAR_GUIDELINE.md"
            }
        }
    }

    foreach ($framework in $backendFrameworks) {
        switch ($framework) {
            "fastapi" {
                Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/backend/BACKEND_GUIDELINE.md"
                Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/backend/api-design.md"
                Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/backend/database.md"
                Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/backend/migrations.md"
                Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/backend/naming.md"
                Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/backend/security.md"
                Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/backend/testing.md"
            }
            "django" {
                Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/backend/DJANGO_GUIDELINE.md"
            }
            "express" {
                Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/backend/EXPRESS_GUIDELINE.md"
            }
        }
    }

    if ($includeMobile) {
        Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/mobile"
    }

    if ($includeWorkflow) {
        Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/workflow"
    }

    if ($includeSpecs) {
        Add-UniquePath -Paths $pathsToCopy -RelativePath "specs"
    }

    if ($includeAdrStarters) {
        Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/adr/0003-use-server-managed-sessions.md"
        Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/adr/0004-reject-client-tampering-of-protected-fields.md"

        foreach ($framework in $frontendFrameworks) {
            switch ($framework) {
                "nextjs" {
                    Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/adr/0001-adopt-feature-driven-frontend.md"
                }
                "angular" {
                    Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/adr/0006-adopt-angular-standalone-frontend.md"
                }
            }
        }

        foreach ($framework in $backendFrameworks) {
            switch ($framework) {
                "fastapi" {
                    Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/adr/0002-adopt-layered-fastapi-backend.md"
                }
                "django" {
                    Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/adr/0007-adopt-django-drf-backend.md"
                }
                "express" {
                    Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/adr/0008-adopt-express-typescript-backend.md"
                }
            }
        }

        if ($includeMobile) {
            Add-UniquePath -Paths $pathsToCopy -RelativePath "docs/adr/0005-adopt-react-native-expo-for-mobile.md"
        }
    }

    if ($includeAgents) {
        Add-UniquePath -Paths $pathsToCopy -RelativePath ".github/agents/README.md"
        Add-UniquePath -Paths $pathsToCopy -RelativePath ".github/agents/architect.agent.md"
        Add-UniquePath -Paths $pathsToCopy -RelativePath ".github/agents/reviewer.agent.md"
        Add-UniquePath -Paths $pathsToCopy -RelativePath ".github/agents/tester.agent.md"
        Add-UniquePath -Paths $pathsToCopy -RelativePath ".github/agents/refactor.agent.md"
        Add-UniquePath -Paths $pathsToCopy -RelativePath ".github/agents/documentation.agent.md"

        Add-UniquePath -Paths $pathsToCopy -RelativePath ".opencode/README.md"
        Add-UniquePath -Paths $pathsToCopy -RelativePath ".opencode/opencode.json"
        Add-UniquePath -Paths $pathsToCopy -RelativePath ".opencode/agents/architect.md"
        Add-UniquePath -Paths $pathsToCopy -RelativePath ".opencode/agents/reviewer.md"
        Add-UniquePath -Paths $pathsToCopy -RelativePath ".opencode/agents/tester.md"
        Add-UniquePath -Paths $pathsToCopy -RelativePath ".opencode/agents/refactor.md"
        Add-UniquePath -Paths $pathsToCopy -RelativePath ".opencode/agents/documentation.md"

        foreach ($framework in $frontendFrameworks) {
            switch ($framework) {
                "nextjs" {
                    Add-UniquePath -Paths $pathsToCopy -RelativePath ".github/agents/expert-nextjs-developer.agent.md"
                    Add-UniquePath -Paths $pathsToCopy -RelativePath ".opencode/agents/nextjs-architect.md"
                }
                "angular" {
                    Add-UniquePath -Paths $pathsToCopy -RelativePath ".github/agents/expert-angular-developer.agent.md"
                    Add-UniquePath -Paths $pathsToCopy -RelativePath ".opencode/agents/angular-architect.md"
                }
            }
        }

        foreach ($framework in $backendFrameworks) {
            switch ($framework) {
                "fastapi" {
                    Add-UniquePath -Paths $pathsToCopy -RelativePath ".github/agents/expert-fastapi-developer.agent.md"
                    Add-UniquePath -Paths $pathsToCopy -RelativePath ".opencode/agents/fastapi-architect.md"
                }
                "django" {
                    Add-UniquePath -Paths $pathsToCopy -RelativePath ".github/agents/expert-django-developer.agent.md"
                    Add-UniquePath -Paths $pathsToCopy -RelativePath ".opencode/agents/django-architect.md"
                }
                "express" {
                    Add-UniquePath -Paths $pathsToCopy -RelativePath ".github/agents/expert-express-developer.agent.md"
                    Add-UniquePath -Paths $pathsToCopy -RelativePath ".opencode/agents/express-architect.md"
                }
            }
        }

        if ($includeMobile) {
            Add-UniquePath -Paths $pathsToCopy -RelativePath ".github/agents/expert-react-native-developer.agent.md"
            Add-UniquePath -Paths $pathsToCopy -RelativePath ".opencode/agents/react-native-architect.md"
        }
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
    if ($frontendFrameworks.Count -gt 0) {
        Write-Host "4. the copied frontend framework doc(s) in docs/frontend/"
    }
    if ($backendFrameworks.Count -gt 0) {
        Write-Host "4. the copied backend framework doc(s) in docs/backend/"
    }
    if ($includeMobile) {
        Write-Host "4. docs/mobile/"
    }

    Write-Host ""
    Write-Host "Trim or rewrite anything that does not match the target repo before real feature work starts." -ForegroundColor Cyan
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}