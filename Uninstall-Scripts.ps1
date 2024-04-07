<#
	.SYNOPSIS
	Uninstalls prerequisites for scripts.
	
	.DESCRIPTION
	Uninstalls prerequisites for scripts.

	.INPUTS
	None.

	.OUTPUTS
	None.

	.EXAMPLE
	PS> .\Uninstall-Scripts
#>
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Requires -Version 5.0
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param ([Parameter()] [switch] $UpdateHelp,
	   [Parameter(Mandatory = $true)] [string] $ModulesPath)

Begin
{
	$script = $MyInvocation.MyCommand.Name
	if(-Not (Test-Path ".\$script"))
	{
		Write-Host "Installation must be run from the same directory as the installer script."
		exit
	}

	if(-Not (Test-Path $ModulesPath))
	{
		Write-Host "'$ModulesPath' was not found."
		exit
	}

	$Env:PSModulePath += ";$ModulesPath"
	
	if (-Not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
		Start-Process -FilePath "pwsh.exe" -ArgumentList "-File `"$PSCommandPath`"", "-ModulesPath `"$ModulesPath`"" -Verb RunAs
		exit
	}
}

Process
{	
	Remove-PathFromProfile -PathVariable 'Path' -Path (Get-Location).Path
	
	Remove-AliasFromProfile -Script 'Update-WinGetApps' -Alias 'uwga'
	Remove-AliasFromProfile -Script 'Update-WinGetApps' -Alias 'wgup'
	Remove-AliasFromProfile -Script 'Get-WinGetXHelp' -Alias 'wghelp'
	Remove-AliasFromProfile -Script 'Get-WinGetXHelp' -Alias 'gwgh'
}

End
{
	Format-Profile
	Complete-Install
}