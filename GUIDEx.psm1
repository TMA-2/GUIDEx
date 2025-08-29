<# Notes
# TODO: Create Pester tests
# TODO: Compare New-UUID and New-UUIDNamespace. Clean one or the other.
# TODO: Compare Convert-UUID and Convert-UUIDBytes. Clean one or the other.

# GOOD: Working, I think. Test outputted UUID for both versions.
New-UUID -Namespace '2bde4a90-d05f-401c-9492-e40884ead1d8' -Name 'Ubuntu'
    Should output '2c4de342-38b7-51cf-b940-2309a097f518'

# FIXME: Outputting bytes before GUID
New-UUIDNamespace -Namespace '2bde4a90-d05f-401c-9492-e40884ead1d8' -Name 'Ubuntu'
    Should output '2c4de342-38b7-51cf-b940-2309a097f518'

# BUG: Line 104 = "Value cannot be null. (Parameter 'd')" when using -Reverse -RespectBitOrder
# BUG: Bytes 1-3, 7 are empty when using -Reverse.
Convert-UUID ([guid]'906F89D8-00DA-3583-8057-A7425FB9FDD4') -Reverse
    Should change input to '8D98F609-AD00-3853-0875-7A24F59BDF4D'

# FIXME: Returns unmodified byte array unless passed with -Method Class
Convert-UUIDBytes ([guid]'2bde4a90-d05f-401c-9492-e40884ead1d8').ToByteArray()
    Should output b2eda409-0df5-04c1-9492-e40884ead1d8

# GOOD: Working
Convert-UUIDOrder '906F89D8-00DA-3583-8057-A7425FB9FDD4'
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
