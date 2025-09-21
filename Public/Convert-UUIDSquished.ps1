function Convert-UUIDSquished {
    <#
    .SYNOPSIS
    Converts a GUID to the format stored by Windows Installer, e.g. in the Products registry key.

    .DESCRIPTION
    The cmdlet is idempotent -- this means you can give it a regular MSI GUID, or a GUID in the "Squished" format, and it will convert in either direction automatically.

    .PARAMETER GUID
    A GUID in a supported format. Curly braces and hyphens optional.

    .PARAMETER Format
    The GUID output format. Default is "b".
    Supported options are:
    b - Default format with hyphens and curly braces (the typical format)
    d - Default format with hyphens
    n - Default format without hyphens (use this for Product registry keys)
    p - Default format with parentheses and hyphens
    x - Hexadecimal format

    .EXAMPLE
    PS C:\> Convert-UUIDSquished "01020304-0506-0708-090a-0b0c0d0e0f10"

    Output:
    {04030201-0605-0807-090a-0b0c0d0e0f10}

    .NOTES
    General notes
    #>
    [OutputType([guid])]
    [Alias('Convert-UUIDOrder', 'Convert-GUIDSquished', 'cvgs')]
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory,
            Position=0,
            ValueFromPipeline
        )]
        [guid]
        $GUID,

        [ValidateSet('d','n','p','b','x',IgnoreCase)]
        [string]
        $Format = 'b'
    )

    Begin {
        if(-not (Get-Variable 'LITTLE_ENDIAN' -Scope Global -ErrorAction SilentlyContinue)) {
            Set-Variable -Name 'LITTLE_ENDIAN' -Value [BitConverter]::IsLittleEndian -Scope Script
        }
        $ConvertedBytes = [byte[]]::new(16)
    }

    Process {
        try {
            $Bytes = $GUID.ToByteArray()
            if ($LITTLE_ENDIAN) {
                # Reverse the byte order for little-endian systems
                [Array]::Reverse($Bytes, 0, 4)
                [Array]::Reverse($Bytes, 4, 2)
                [Array]::Reverse($Bytes, 6, 2)
            }
        }
        catch {
            $Err = $_
            throw "Exception $($Err.Exception.HResult) converting GUID to Byte[] > $($Err.Exception.Message)"
        }

        # apparently this is a nibble swap
        <# for($i = 0; $i -lt 16; $i++) {
            $ByteHI = [byte]($Bytes[$i] -shl 4 -band 0xF0)
            $ByteLO = [byte]($Bytes[$i] -shr 4 -band 0x0F)
            $ConvertedBytes[$i] = $ByteHI -bor $ByteLO
        } #>
        try {
            $ConvertedBytes = $Bytes | Switch-ByteNibble
        }
        catch {
            $Err = $_
            throw "Exception $($Err.Exception.HResult) performing nibble swap on GUID bytes > $($Err.Exception.Message)"
        }

        $ConvertedGUID = [guid]::new($ConvertedBytes)

        Return $ConvertedGUID.ToString($Format)
    }
}
