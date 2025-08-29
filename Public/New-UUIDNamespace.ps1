# Example usage:
# $namespace = [Guid]::Parse("6ba7b810-9dad-11d1-80b4-00c04fd430c8") # DNS namespace
# $name = "example.com"
# PS C:\> $uuidv5 = New-UUID -Namespace $namespace -Name $name
# PS C:\> Write-Output $uuidv5
# cfbff0d1-9375-5685-968c-48ce8b15ae17
function New-UUIDNamespace {
    <#
    .SYNOPSIS
    Generates a UUID version 3 (UUIDv3) or version 5 (UUIDv5) based on a namespace and a name.

    .DESCRIPTION
    The New-UUID function generates a UUID version 3 or version 5, which are universally unique identifiers that are generated using a namespace identifier and a name. UUIDv3 uses MD5 hashing, while UUIDv5 uses SHA-1 hashing to create the identifier.

    .PARAMETER Namespace
    The namespace identifier, which is a UUID that defines the scope of the name.

    .PARAMETER Name
    The name from which the UUID will be generated. This is typically a string.

    .PARAMETER Version
    The version of the UUID to generate. Accepts 3 or 5. Default is 5.

    .OUTPUTS
    System.Guid
    The generated UUID version 3 or 5.

    .EXAMPLE
    PS C:\> New-UUID -Namespace "6ba7b810-9dad-11d1-80b4-00c04fd430c8" -Name "example" -Version 5
    Generates a UUIDv5 based on the provided namespace and name.

    .EXAMPLE
    PS C:\> New-UUID -Namespace "6ba7b810-9dad-11d1-80b4-00c04fd430c8" -Name "example" -Version 3
    Generates a UUIDv3 based on the provided namespace and name.

    .NOTES
    UUID version 3 is defined in RFC 4122.
    UUID version 5 is defined in RFC 4122.
    #>
    [Alias('New-GUIDNamespace','ngns')]
    [OutputType([guid])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [Guid]$Namespace,
        [Parameter(Mandatory, Position = 1, ValueFromPipeline)]
        [string]$Name,
        [ValidateSet(3, 5)]
        [int]$Version = 5
    )

    Begin {
        Set-Variable -Name 'LITTLE_ENDIAN' -Value ([System.BitConverter]::IsLittleEndian) -Option Constant -Scope Global -ea SilentlyContinue
    }

    Process {
        # Convert the namespace GUID to a byte array, keeping the endianness from swapping
        if($PSEdition -eq 'Core') {
            $NamespaceBytes = $Namespace.ToByteArray($LITTLE_ENDIAN)
        } elseif($PSEdition -eq 'Desktop') {
            $NamespaceBytes = $Namespace.ToByteArray() | Convert-BinaryLSB
        }

        # Convert the name to a byte array
        $NameBytes = [System.Text.Encoding]::UTF8.GetBytes($Name)

        # Combine namespace and name
        $CombinedBytes = $NamespaceBytes + $NameBytes

        # Create a hash based on the version
        if ($Version -eq 5) {
            $HashAlgorithm = [System.Security.Cryptography.SHA1]::Create()
        } elseif ($Version -eq 3) {
            $HashAlgorithm = [System.Security.Cryptography.MD5]::Create()
        }
        $VersionByte = $Version -shl 4

        # Compute the hash
        $HashBytes = $HashAlgorithm.ComputeHash($CombinedBytes)[0..15]

        # Set the version and variant bits
        $HashBytes[6] = ($HashBytes[6] -band 0x0F) -bor $VersionByte
        $HashBytes[8] = ($HashBytes[8] -band 0x3F) -bor 0x80

        # verify it's a byte array and not a generic object[]
        $HashBytes = $HashBytes -as [byte[]]

        # Create a new GUID from the hash
        if($PSEdition -eq 'Core') {
            $uuid = [Guid]::New($HashBytes, $LITTLE_ENDIAN)
        } elseif($PSEdition -eq 'Desktop') {
            $uuid = [Guid]::New($HashBytes)
        }
        return $uuid
    }

    End {
        $HashAlgorithm.Dispose()
    }
}

