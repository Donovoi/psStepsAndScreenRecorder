#
# Module manifest for module 'psScreenRecorder'
#
# Generated by: Adrian.Andersson
#
# Generated on: 14/03/2019
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'psScreenRecorder.psm1'

# Version number of this module.
ModuleVersion = '1.0.2.1'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = '66b95cf8-97e8-4448-8015-38d0e35456a0'

# Author of this module
Author = 'Adrian.Andersson'

# Company or vendor of this module
CompanyName = 'Domain Group'

# Copyright statement for this module
Copyright = '2019 Domain Group'

# Description of the functionality provided by this module
Description = 'Desktop Video Capture with PowerShell'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.0.0.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'convert-mp4togif', 'install-ffMpeg', 'new-psScreenRecord'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
# VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @()

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        # Tags = @()

        # A URL to the license for this module.
        # LicenseUri = ''

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/adrian-andersson/psScreenRecorder'

        # A URL to an icon representing this module.
        IconUri = 'https://github.com/adrian-andersson/psScreenRecorder/icon.png'

        # ReleaseNotes of this module
        # ReleaseNotes = ''

    } # End of PSData hashtable


    # bartenderCopyright
    bartenderCopyright = '2019 Domain Group'

    # builtOn
    builtOn = '2019-03-14T14:24:29'

    # builtBy
    builtBy = 'Adrian.Andersson'

    # moduleCompiledBy
    moduleCompiledBy = 'Bartender | A Framework for making PowerShell Modules'

    # bartenderVersion
    bartenderVersion = '6.1.21'

    # moduleRevision
    moduleRevision = '1.0.2.1'

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

