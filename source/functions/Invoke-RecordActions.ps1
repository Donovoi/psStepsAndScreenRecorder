function Get-FFmpeg {
    param (
        [string]$Url = "https://ffmpeg.zeranoe.com/builds/win64/static/ffmpeg-4.2.2-win64-static.zip",
        [string]$DestinationPath,
        [switch]$LocalDependencies,
        [string]$LocalPath
    )

    if ($LocalDependencies) {
        $DestinationPath = Join-Path -Path $LocalPath -ChildPath "ffmpeg\bin\ffmpeg.exe"
        if (-Not (Test-Path -Path $DestinationPath)) {
            Write-Output "FFmpeg not found locally. Downloading..."
            $zipPath = Join-Path -Path $LocalPath -ChildPath "ffmpeg.zip"
            try {
                Invoke-WebRequest -Uri $Url -OutFile $zipPath -ErrorAction Stop
                Expand-Archive -Path $zipPath -DestinationPath (Join-Path -Path $LocalPath -ChildPath "ffmpeg") -ErrorAction Stop
                Remove-Item -Path $zipPath -ErrorAction Stop
                Write-Output "FFmpeg downloaded and installed locally."
            }
            catch {
                throw "Failed to download or extract FFmpeg: $_"
            }
        } else {
            Write-Output "FFmpeg is already installed locally."
        }
    } else {
        if (-Not (Test-Path -Path $DestinationPath)) {
            Write-Output "FFmpeg not found. Downloading..."
            $zipPath = "$env:TEMP\ffmpeg.zip"
            try {
                Invoke-WebRequest -Uri $Url -OutFile $zipPath -ErrorAction Stop
                Expand-Archive -Path $zipPath -DestinationPath (Split-Path -Parent $DestinationPath) -ErrorAction Stop
                Remove-Item -Path $zipPath -ErrorAction Stop
                Write-Output "FFmpeg downloaded and installed."
            }
            catch {
                throw "Failed to download or extract FFmpeg: $_"
            }
        } else {
            Write-Output "FFmpeg is already installed."
        }
    }
}

function Install-psScreenRecorder {
    param (
        [switch]$LocalDependencies,
        [string]$LocalPath
    )

    if ($LocalDependencies) {
        $modulePath = Join-Path -Path $LocalPath -ChildPath "psScreenRecorder"
        if (-Not (Test-Path -Path $modulePath)) {
            Write-Output "psScreenRecorder module not found locally. Installing..."
            try {
                Save-Module -Name psScreenRecorder -Path $LocalPath -Force -ErrorAction Stop
                Write-Output "psScreenRecorder module installed locally."
            }
            catch {
                throw "Failed to install psScreenRecorder module locally: $_"
            }
        } else {
            Write-Output "psScreenRecorder module is already installed locally."
            Import-Module -Name $modulePath\psScreenRecorder
        }
    } else {
        if (-Not (Get-Module -ListAvailable -Name psScreenRecorder)) {
            Write-Output "psScreenRecorder module not found. Installing..."
            try {
                Install-Module -Name psScreenRecorder -Scope CurrentUser -Force -ErrorAction Stop
                Write-Output "psScreenRecorder module installed."
            }
            catch {
                throw "Failed to install psScreenRecorder module: $_"
            }
        } else {
            Write-Output "psScreenRecorder module is already installed."
        }
    }
}

function Start-StepsRecorder {
    Start-Process -FilePath "C:\Windows\System32\psr.exe"
    Start-Sleep -Seconds 5
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.SendKeys]::SendWait("%a")
    Write-Output "Steps Recorder started."
}

function Stop-AndSave-StepsRecorder {
    param (
        [string]$SavePath
    )

    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.SendKeys]::SendWait("%o")
    Start-Sleep -Seconds 1
    [System.Windows.Forms.SendKeys]::SendWait("%f")
    Start-Sleep -Seconds 1
    [System.Windows.Forms.SendKeys]::SendWait("s")
    Start-Sleep -Seconds 1
    [System.Windows.Forms.SendKeys]::SendWait("$SavePath")
    Start-Sleep -Seconds 1
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
    Write-Output "Steps Recorder stopped and saved to $SavePath."
}

function Compress-Files {
    param (
        [string]$SourcePath1,
        [string]$SourcePath2,
        [string]$DestinationPath
    )

    try {
        Compress-Archive -Path $SourcePath1, $SourcePath2 -DestinationPath $DestinationPath -ErrorAction Stop
        Write-Output "Files compressed into $DestinationPath."
    }
    catch {
        throw "Failed to compress files: $_"
    }
}

function Invoke-RecordActions {
    param (
        [string]$OutFolder = "C:\temp\ScreenRecord",
        [string]$VideoName = "ScreenCapture.mp4",
        [string]$StepsFileName = "StepsRecording.mht",
        [string]$ZipFileName = "RecordingBundle.zip",
        [int]$Duration = 30,
        [switch]$LocalDependencies,
        [string]$LocalPath
    )

    # Ensure output directory exists
    if (-Not (Test-Path -Path $OutFolder)) {
        New-Item -Path $OutFolder -ItemType Directory -Force | Out-Null
    }

    $ffmpegPath = if ($LocalDependencies) { Join-Path -Path $LocalPath -ChildPath "ffmpeg\bin\ffmpeg.exe" } else { "$env:ProgramFiles\ffmpeg\bin\ffmpeg.exe" }
    $videoPath = Join-Path -Path $OutFolder -ChildPath $VideoName
    $stepsPath = Join-Path -Path $OutFolder -ChildPath $StepsFileName
    $zipPath = Join-Path -Path $OutFolder -ChildPath $ZipFileName

    Get-FFmpeg -DestinationPath $ffmpegPath -LocalDependencies:$LocalDependencies -LocalPath $LocalPath
    Install-psScreenRecorder -LocalDependencies:$LocalDependencies -LocalPath $LocalPath

    try {
        Start-StepsRecorder

        Import-Module psScreenRecorder
        New-psScreenRecord -outFolder $OutFolder -videoName $VideoName -fps 30 -ffMPegPath $ffmpegPath

        Start-Sleep -Seconds $Duration

        Stop-AndSave-StepsRecorder -SavePath $stepsPath
        Stop-psScreenRecord

        Compress-Files -SourcePath1 $videoPath -SourcePath2 $stepsPath -DestinationPath $zipPath

        Write-Output "Recording and steps have been saved and bundled into: $zipPath"
    }
    catch {
        throw "An error occurred during the recording process: $_"
    }
}
