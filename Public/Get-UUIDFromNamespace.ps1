using namespace System.Text
using namespace System.Security.Cryptography

function Get-UUIDFromNamespace {
    <#
    .SYNOPSIS
    Gets a UUID version 3 (UUIDv3) or version 5 (UUIDv5) derived from a namespace and a name.

    .DESCRIPTION
    The Get-UUIDFromNamespace function gets a UUID version 3 or version 5, which are universally unique identifiers that are generated using a namespace identifier and a name. UUIDv3 uses MD5 hashing, while UUIDv5 uses SHA-1 hashing to create the identifier.

    .PARAMETER Namespace
    The namespace identifier, which is a UUID that defines the scope of the name.

    .PARAMETER Name
    The name from which the UUID will be generated. This is typically a string.

    .PARAMETER Version
    The version of the UUID to generate. Accepts 3 or 5. Default is 5.

    .PARAMETER Encoding
    The encoding method to use for the name. UTF8 for standard RFC compliance, UTF16LE for Windows Terminal compatibility.

    .OUTPUTS
    System.Guid
    The UUID version 3 or 5 derived from the namespace and name.

    .EXAMPLE
    PS C:\> Get-UUIDFromNamespace -Namespace "6ba7b810-9dad-11d1-80b4-00c04fd430c8" -Name "example" -Version 5
    Gets a UUIDv5 based on the provided namespace and name.

    .EXAMPLE
    PS C:\> Get-UUIDFromNamespace -Namespace "6ba7b810-9dad-11d1-80b4-00c04fd430c8" -Name "example" -Version 3
    Gets a UUIDv3 based on the provided namespace and name.

    .EXAMPLE
    PS C:\> $terminalNS = [guid]"{2bde4a90-d05f-401c-9492-e40884ead1d8}"
    PS C:\> Get-UUIDFromNamespace -Namespace $terminalNS -Name "Ubuntu" -Encoding UTF16LE
    Gets a UUID for Windows Terminal profile using Terminal's namespace and UTF16LE encoding.

    .NOTES
    UUID version 3 is defined in RFC 4122.
    UUID version 5 is defined in RFC 4122.
    #>
    [Alias('Get-GUIDFromNamespace','gufn')]
    [OutputType([guid])]
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline
        )]
        [Alias('NS')]
        [Guid]
        $Namespace,

        [Parameter(
            Mandatory,
            Position = 1,
            ValueFromPipeline
        )]
        [string]
        $Name,

        [ValidateSet(3, 5)]
        [int]
        $Version = 5,

        [Parameter(
            HelpMessage = 'Use UTF16LE for Windows Terminal compatibility.'
        )]
        [ValidateSet('UTF8', 'UTF16LE')]
        [string]
        $Encoding = 'UTF16LE'
    )

    begin {
        Set-Variable -Name 'LITTLE_ENDIAN' -Value ([BitConverter]::IsLittleEndian) -Option Constant -Scope Global -ea SilentlyContinue
        function convertUTF16Bytes {
            [CmdletBinding()]
            param (
                [Parameter(ValueFromPipeline)]
                [string]$String
            )
            process {
                $UTF16Enc = [UnicodeEncoding]::new($false, $false)
                $UTF16Bytes = $UTF16Enc.GetBytes($String)
                $AsciiStr = [Encoding]::ASCII.GetString($UTF16Bytes)
                $UTF8Bytes = [Encoding]::UTF8.GetBytes($AsciiStr)
                return $UTF8Bytes
            }
        }
    }

    process {
        # Convert the namespace GUID to a byte array, keeping the endianness from swapping
        if($PSEdition -eq 'Core') {
            $NamespaceBytes = $Namespace.ToByteArray($LITTLE_ENDIAN)
        }
        elseif($PSEdition -eq 'Desktop') {
            $NamespaceBytes = $Namespace.ToByteArray() | Switch-ByteNibble
        }

        # Convert the name to a byte array
        switch ($Encoding) {
            'UTF16LE' {
                $NameBytes = $Name | convertUTF16Bytes
            }
            'UTF8' {
                $NameBytes = [Encoding]::UTF8.GetBytes($Name)
            }
        }

        # Combine namespace and name
        $CombinedBytes = $NamespaceBytes + $NameBytes

        # Create a hash based on the version
        if ($Version -eq 5) {
            $HashAlgorithm = [SHA1]::Create()
        }
        elseif ($Version -eq 3) {
            $HashAlgorithm = [MD5]::Create()
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
        }
        elseif($PSEdition -eq 'Desktop') {
            $uuid = [Guid]::New($HashBytes)
        }
        return $uuid
    }

    end {
        $HashAlgorithm.Dispose()
    }
}

