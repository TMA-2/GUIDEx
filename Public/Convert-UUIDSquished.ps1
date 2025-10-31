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
    .EXAMPLE
    PS C:\> Convert-UUIDSquished "01020304-0506-0708-090a-0b0c0d0e0f10" -Format n

    Output:
    0403020106050807090a0b0c0d0e0f10
    .OUTPUTS
    [Guid] if Format is not specified.
    [String] if Format specified.
    .NOTES
    A "squished GUID" (SQUID) is a compressed format of a standard Windows Installer GUID, used to save space in the registry.
    It removes hyphens and curly braces from the GUID and rearranges the hexadecimal digits, and is used internally by the installer to identify products and their updates.
    You can find them used in: HKLM\Software\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products
    .COMPONENT
    Windows Installer
    .LINK
    About SQUIDs
    https://lordjeb.com/2013/10/01/windows-installer-squids/
    .LINK
    Converting a Regular GUID to a Compressed GUID
    https://community.revenera.com/s/article/converting-a-regular-guid-to-a-compressed-guid
    #>
    [OutputType([guid])]
    [OutputType([string],ParameterSetName='Formatted')]
    [Alias('Convert-SQUID', 'Convert-GUIDSquished', 'cvgs')]
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline
        )]
        [guid]
        $GUID,

        [Parameter(
            Position = 1,
            ValueFromPipelineByPropertyName,
            ParameterSetName = 'Formatted'
        )]
        [ValidateSet(IgnoreCase,'d','n','p','b','x')]
        [string]
        $Format
    )

    Begin {
        $FunctionName = $MyInvocation.MyCommand.Name
        if(-not (Get-Variable 'LITTLE_ENDIAN' -Scope Global -ea SilentlyContinue)) {
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
            Write-Verbose "${FunctionName}: Processed $($Bytes.Count) bytes for $GUID"
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
            $ConvertedBytes = Switch-ByteNibble -Bytes $Bytes
            Write-Verbose "${FunctionName}: Swapped $($ConvertedBytes.Count) $($ConvertedBytes.GetType().Name)"
        }
        catch {
            $Err = $_
            throw "Exception $($Err.Exception.HResult) performing nibble swap on GUID bytes > $($Err.Exception.Message)"
        }

        try {
            $ConvertedGUID = [guid]::new($ConvertedBytes -as [byte[]])
        }
        catch {
            $Err = $_
            throw "Exception $($Err.Exception.HResult) parsing converted GUID bytes > $($Err.Exception.Message)"
        }

        if ($Format) {
            Return $ConvertedGUID.ToString($Format).ToUpperInvariant()
        }
        else {
            $ConvertedGUID
        }
    }
}
