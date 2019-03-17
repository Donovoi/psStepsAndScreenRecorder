function new-psScreenRecord
{
<#
	.SYNOPSIS
		Simple Screen-Capture done in PowerShell
 
        Needs ffmpeg: https://www.ffmpeg.org/
			
	.DESCRIPTION
		Simple Screen-Capture done in PowerShell.
        Useful for making tutorial  and demonstration videos
 
        Also draws a big red dot where your cursor is, if it is in the defined window bounds
 
        Uses FFMPeg to make a video file
        Video file can then be edited in your fav video editor
        Like Blender :)


        You will need to download and setup FFMPEG first

        https://www.ffmpeg.org/

        The default path to the ffmpeg exe is c:\program files\ffmpeg\bin
 
        
 
	.PARAMETER outFolder
		The folder to 
            a) Temporarily keep the jpegs
            b) Save the mpeg file
 
            Is Mandatory
 
            
    .PARAMETER fps
		Framerate used to calculate both how often to take a screenshot
        And what to use to process the ffmpeg call
 
    .PARAMETER videoName
		Name + Extension to output the video file as
        By default will use out.mp4
 
    .PARAMETER ffMPegPath
		Path to ffMpeg
        Suggest you modify this to be where yours is by default
 
    .PARAMETER confirm
        Skip asking if you want to continue

    .PARAMETER leaveImages
        Skip deleting the temporary images after screen-capture

    .PARAMETER tempPath
        Where to store the images before compiling them into a video
    
 
	.EXAMPLE
		new-psScreenRecord -outFolder 'C:\temp\testVid' -Verbose 
 
	DESCRIPTION
	------------
		Will create a new video file with 'out.mp4' filename in c:\temp\testVid folder
 
 
	OUTPUT
	------------
		N/A
 
	
    
    .NOTES
		Author: Adrian Andersson
		
			
			
        Changelog
        
            2017-09-13  - AA
                - New script, cleaned-up from an old one I had saved

            2019-03-14 - AA
                - Moved to bartender module
             
            2019-03-14 - AA
                - Changed the ffmpegPath to use the allUsersProfile path
                - Throw better errors
                - Added a couple write-hosts so users were not left wondering what was going on with the capture process
                    - Normally I don't condone write-host but it seemed to make sense in this case
                -Changed var name to ffmpegArg
                - Moved images to temp folder rather than output folder
                - Fixed confirm switch so it actually works
                - Fixed the help

            2019-03-17 - AA
                - Second attempt at fixing screen scaling bug
 
    .COMPONENT
        psScreenCapture
#>	
 
    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$false,Position=0)]
        [Alias("path")]
        [string]$outFolder = 'C:\temp\ffmpeg\out',
        [Parameter(Mandatory=$false,Position=1)]
        [Alias("framerate")]
        [string]$fps = 24, 
        [Parameter(Mandatory=$false,Position=2)]
        [string]$videoName = 'out.mp4',
        [Parameter(Mandatory=$false,Position=3)]
        [string]$ffMPegPath = $(get-childitem -path "$($env:ALLUSERSPROFILE)\ffmpeg" -filter 'ffmpeg.exe' -Recurse|sort-object -Property LastWriteTime -Descending|select-object -First 1).fullname,
        [Parameter(Mandatory=$false,Position=5)]
        [switch]$confirm,
        [Parameter(Mandatory=$false,Position=6)]
        [switch]$leaveImages,
        [Parameter(Mandatory=$false,Position=4)]
        [string]$tempPath = "$($env:temp)\ffmpeg"
    )
    begin{
 
        
        #Return the script name when running verbose, makes it tidier
        write-verbose "===========Executing $($MyInvocation.InvocationName)==========="
        #Return the sent variables when running debug
        Write-Debug "BoundParams: $($MyInvocation.BoundParameters|Out-String)"
 
 
        Write-Verbose 'Adding a new C# Assembly to get the Foreground Window'
        #This assembly is needed to get the current process
        #So we know when we have gone BACK to PowerShell
        #Use an array since its tidier than a here string
        $typeDefinition = @(
            'using System;',
            'using System.Runtime.InteropServices;',
            'public class UserWindows {',
            '   [DllImport("user32.dll")]',
            '   public static extern IntPtr GetForegroundWindow();',
            '}'
        )

        Add-Type $($typeDefinition -join "`n")

        write-verbose 'Loading other required assemblies'
        Add-Type -AssemblyName system.drawing
        add-type -AssemblyName system.windows.forms




        #We need to calculate the sleep-time based on the FPS
        #We want to know how many miliseconds to take a snap - as a whole number
        #Based on the frame-rate
        #This should be accurate enough
        write-verbose 'Calculating capture time'
        $msWait =[math]::Floor(1/$($fps/1000)) 
    
 
    }process{

        write-verbose 'Checking for ffmpeg'
        if(!$(test-path -Path $ffMPegPath -ErrorAction SilentlyContinue))
        {
            throw 'FFMPEG not found - either provide the path variable or run the install-ffmmpeg command'
        }

        if(!$(test-path $tempPath))
        {
            write-verbose 'Creating ffmpeg temp directory'
            try{
                $outputDir = new-item -ItemType Directory -Path $tempPath -Force -ErrorAction Stop
                write-verbose 'Directory Created'
            }catch{
                throw 'Unable to create ffmpeg temp directory'
            }
        }
        
 
        Write-Verbose 'Getting THIS POWERSHELL Session handle number so we know what to ignore'
        #This is used in conjunction with the above service, to identify when we get back to the ps window
        $thisWindowHandle = $(Get-Process -Name *powershell* |Where-Object{$_.MainWindowHandle -eq $([userwindows]::GetForegroundWindow())}).MainWindowHandle
 
        Write-Verbose 'Ensuring output folder is ok'
        if(Test-Path $outfolder -ErrorAction SilentlyContinue)
        {
            Write-Verbose 'Folder exists, will need to remove '
            Write-Warning 'Output folder already exists. This process will recreate it'
            if(!$confirm)
            {
                if($($Host.UI.PromptForChoice('Continue','Are you sure you wish to continue', @('No','Yes'), 1)) -eq 1)
                {
                    write-host 'Continuing with screen capture'
                }else{
                    return -1
                }
 
            }
            Write-Verbose 'Removing existing jpegs in folder and video file if it exists'
            remove-item "$tempPath\*.jpg" -Force
            remove-item $outFolder\$videoName -Force -ErrorAction SilentlyContinue #SilentlyCont in case the file doesn't exist
 
        }else{
            Write-Verbose 'Creating new output folder'
            new-item -Path $outFolder -ItemType Directory -Force
 
        }


        #Get the window size
        Write-Verbose 'Getting the Window Size'
        Read-Host 'VIDEO RECORD, put mouse cursor in top left corner of capture area and press any key'
        $start = [System.Windows.Forms.Cursor]::Position
        Read-Host 'VIDEO RECORD, put mouse cursor in bottom right corner of capture area and press any key'
        $end = [System.Windows.Forms.Cursor]::Position

        $scale = get-screenScaling
 
        $horStart = get-EvenNumber $($($start.x * $scale))
        $verStart = get-EvenNumber $($($start.y * $scale))
        $horEnd = get-EvenNumber $($($end.x * $scale))
        $verEnd = get-EvenNumber $($($end.y * $scale))
        $boxSize = "box size: Xa: $horStart, Ya: $verStart, Xb: $horEnd, Yb: $verEnd, $($horEnd - $horStart) pixels wide, $($verEnd - $verStart) pixles tall"
        Write-Verbose $boxSize
        if(!$confirm)
        {
            $startCapture = $($Host.UI.PromptForChoice('Continue',"Capture will start 2 seconds after this window looses focus. `n Press CTRL+C to force stop", @('No','Yes'), 1))
        }else{
            $startCapture = $true
        }
        if($startCapture -eq $true -or $startCapture -eq 1)
        {
            write-host 'Starting screen capture'
            #Start up the capture process
            $num = 1 #Iteration number for screenshot naming
            $capture = $false #Switch to say when to stop capture
            #Wait for PowerShell to loose focus
            while($capture -eq $false)
            {
                if([userwindows]::GetForegroundWindow() -eq $thisWindowHandle)
                {
                    write-verbose 'Powershell still in focus'
                    Start-Sleep -Milliseconds 60
                }else{
                    write-verbose 'Powershell lost focus'
                    write-host 'Focus Lost - Starting screen capture'
                    Start-Sleep -Seconds 2
                    $capture=$true
                    $stopwatch = [System.Diagnostics.stopwatch]::StartNew()
                }
            }
            #Do another loop until PowerShell regains focus
            while($capture -eq $true)
            {
                if([userwindows]::GetForegroundWindow() -eq $thisWindowHandle)
                {
                    write-verbose 'Powershell has regained focus, so exit the loop'
                    $capture = $false
                }else{
                    write-verbose 'Powershell does not have focus, so capture a screenshot'
                    $x = "{0:D5}" -f $num
                    $path = "$tempPath\$x.jpg"
                    Out-screenshot -horStart $horStart -verStart $verStart -horEnd $horEnd -verEnd $verEnd -path $path -captureCursor
                    $num++
                    Start-Sleep -milliseconds $msWait
                }    
            }
 
        }else{
            return -1
        }
 
 
    }End{
        $stopwatch.stop()
        $numberOfImages = $(get-childitem $tempPath -Filter '*.jpg').count
        #Gasp ... a write host appeared
        #Since we aren't returning any objects this seems like a good option
        Write-Host 'Capture complete, compiling video'
        $actualFrameRate = $numberOfImages / $stopwatch.Elapsed.TotalSeconds
        $actualFrameRate = [math]::Ceiling($actualFrameRate)
        Write-Verbose "Time Elapsed: $($stopwatch.Elapsed.ToString())"
        Write-Verbose "Total Number of Images: $numberOfImages"
        Write-Verbose "ActualFrameRate: $actualFrameRate"
        Write-Verbose 'Creating video using ffmpeg'
        $ffmpegArg = "-framerate $actualFrameRate -i $tempPath\%05d.jpg -c:v libx264 -vf fps=$actualFrameRate -pix_fmt yuv420p $outFolder\$videoName -y"
        Start-Process -FilePath $ffMPegPath -ArgumentList $ffmpegArg -Wait
        if(!$leaveImages)
        {
            Write-Verbose 'Cleaning up jpegs'
            remove-item "$tempPath\*.jpg" -Force
        }
 
    }
 
}
