<#
	.SYNOPSIS
	Updates apps using winget.
	
	.DESCRIPTION
	Updates apps using winget.

	.INPUTS
	Exclusion file.

	.OUTPUTS
	None.

	.EXAMPLE
	PS> .\Update-WinGetApps -ExclusionFilePath "exclusion.txt"
#>
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Requires -Version 5.0
[CmdletBinding(SupportsShouldProcess)]
param ([Parameter()] [switch] $UpdateHelp,
	   [Parameter(Mandatory = $true)] [string] $ExclusionFilePath)

Process
{	
# Read the exclusion patterns from the file
    $exclusionPatterns = Get-Content $ExclusionFilePath | Where-Object { $_ -ne "" }

    # Get all updatable packages from winget
    $updatableApps = winget upgrade --query | Select-String -Pattern '^\s*[^ ]+\s+' -AllMatches | ForEach-Object { $_.Matches[0].Value.Trim() }

    # Filter out the apps that match the exclusion patterns
    $appsToUpdate = $updatableApps | Where-Object {
        $app = $_
        $excluded = $false
        foreach ($pattern in $exclusionPatterns) {
            if ($app -like $pattern) {
                $excluded = $true
                break
            }
        }
        -not $excluded
    }

    # Update each app
    foreach ($app in $appsToUpdate) {
        Write-Host "Updating $app..."
        winget upgrade $app
    }

    Write-Host "Done"
}