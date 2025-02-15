<# Notes
# TODO: Create Pester tests

PS C:\> New-UUID -Namespace '2bde4a90-d05f-401c-9492-e40884ead1d8' -Name 'Ubuntu'
    Should output '2c4de342-38b7-51cf-b940-2309a097f518'

PS C:\> New-UUIDNamespace -Namespace '2bde4a90-d05f-401c-9492-e40884ead1d8' -Name 'Ubuntu'
    Should output '2c4de342-38b7-51cf-b940-2309a097f518'

PS C:\> Convert-UUID ([ref]'906F89D8-00DA-3583-8057-A7425FB9FDD4') -Reverse
    Should output '8D98F609-AD00-3853-0875-7A24F59BDF4D'

PS C:\> Convert-UUIDBytes ([guid]'2bde4a90-d05f-401c-9492-e40884ead1d8').ToByteArray()
    Should output b2eda409-0df5-04c1-9492-e40884ead1d8
#>

Set-Variable -Name 'LITTLE_ENDIAN' -Value ([System.BitConverter]::IsLittleEndian) -Option Constant -Scope Global -ea SilentlyContinue

# Import all scripts from the Private folder
$PrivateScripts = Get-ChildItem -Path $PSScriptRoot\Private -Filter *.ps1
foreach ($Script in $PrivateScripts) {
    . $Script.FullName
}

# Import all scripts from the Public folder
$PublicScripts = Get-ChildItem -Path $PSScriptRoot\Public -Filter *.ps1
foreach ($Script in $PublicScripts) {
    . $Script.FullName
}

Export-ModuleMember -Function *-* -Alias *
Export-ModuleMember -Variable 'LITTLE_ENDIAN'
