param (
    [string] $OutDir = '.\bld\ISEFontSmoothing\',
    [switch] $Publish,
    [string] $ApiKey
)

if (-not (Test-Path $OutDir))
{
    New-Item -ItemType Directory -Path $OutDir -Force -Verbose | Out-Null
}

Copy-Item -Path @('.\*.psd1','.\*.psm1') -Destination $OutDir -Force -Verbose

if ($Publish)
{
    Import-Module PowerShellGet

    Publish-Module -Name (Resolve-Path $OutDir) -NuGetApiKey $ApiKey -Verbose
}

