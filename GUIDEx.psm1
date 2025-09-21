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
