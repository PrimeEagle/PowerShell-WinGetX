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
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param (	[Parameter()] [string] $ExclusionFile
	  )
DynamicParam { Build-BaseParameters }

Begin
{	
	Write-LogTrace "Execute: $(Get-RootScriptName)"
	$minParams = Get-MinimumRequiredParameterCount -CommandInfo (Get-Command $MyInvocation.MyCommand.Name)
	$cmd = @{}

	if(Get-BaseParamHelpFull) { $cmd.HelpFull = $true }
	if((Get-BaseParamHelpDetail) -Or ($PSBoundParameters.Count -lt $minParams)) { $cmd.HelpDetail = $true }
	if(Get-BaseParamHelpSynopsis) { $cmd.HelpSynopsis = $true }
	
	if($cmd.Count -gt 1) { Write-DisplayHelp -Name "$(Get-RootScriptPath)" -HelpDetail }
	if($cmd.Count -eq 1) { Write-DisplayHelp -Name "$(Get-RootScriptPath)" @cmd }
}
Process
{
	try
	{
		$isDebug = Assert-Debug
			
		$exclusionPatterns = @()
		
		if($ExclusionFile)
		{
			$exclusionPatterns = Get-Content $ExclusionFile | Where-Object { $_ -ne "" }
		}
		
		$updatableApps = winget upgrade --query | Select-String -Pattern '^\s*[^ ]+\s+' -AllMatches | ForEach-Object { $_.Matches[0].Value.Trim() }

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

		foreach ($app in $appsToUpdate) {
			Write-Host "Updating $app..."
			winget upgrade $app
		}
	}
	catch [System.Exception]
	{
		Write-DisplayError $PSItem.ToString() -Exit
	}
}
End
{
	Write-DisplayHost "Done." -Style Done
}
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------