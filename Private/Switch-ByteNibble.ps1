function Switch-ByteNibble {
    <#
        .SYNOPSIS
        Swaps the nibbles (4-bit halves) of each byte in a byte array or GUID.

        .DESCRIPTION
        Takes a byte array or GUID and swaps the high and low nibbles of each byte.
        This is useful for certain encoding/decoding operations.

        .EXAMPLE
        Switch-ByteNibble -Bytes @(0x12, 0x34, 0x56)
        Returns byte array with nibbles swapped: @(0x21, 0x43, 0x65)

        .EXAMPLE
        [Guid]'12345678-1234-1234-1234-123456789012' | Switch-ByteNibble
        Returns a new GUID with nibbles swapped in each byte.
    #>
    [OutputType([byte[]], ParameterSetName = 'Bytes')]
    [OutputType([guid], ParameterSetName = 'Guid')]
    [CmdletBinding(DefaultParameterSetName = 'Bytes')]
    param (
        [Parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline,
            ParameterSetName = 'Bytes'
        )]
        [byte[]]$Bytes,

        [Parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline,
            ParameterSetName = 'Guid'
        )]
        [Guid]$Guid
    )

    begin {
        $FunctionName = $MyInvocation.MyCommand.Name
        $ParamSet = $PSCmdlet.ParameterSetName
        $VERBOSE = $PSBoundParameters.ContainsKey('Verbose')
        function Show-Step {
            param (
                [string]$Step,
                [byte]$Byte1,
                [byte]$Byte2
            )

            $Byte1Fmt = [System.Convert]::ToString($Byte1, 2).PadLeft(8, '0')
            $Byte2Fmt = [System.Convert]::ToString($Byte2, 2).PadLeft(8, '0')

            '{0}: {1} - 0x{2:X2} => 0x{3:X2}; 0b{4} => 0b{5}' -f $FunctionName, $Step, $Byte1, $Byte2, $Byte1Fmt, $Byte2Fmt
        }
    }

    process {
        if ($ParamSet -eq 'Guid') {
            $Bytes = $Guid.ToByteArray()
            Write-Verbose "${FunctionName}: Input GUID converted to $($Bytes.Count) bytes"
            <# if($LITTLE_ENDIAN) {
                $Bytes = [byte[]]$Bytes[3..0] + [byte[]]$Bytes[5..4] + [byte[]]$Bytes[7..6] + [byte[]]$Bytes[8..15]
            } #>
        }

        $bytecount = 0
        $reversedBytes = [byte[]]::new($Bytes.Length)

        foreach ($byte in $Bytes) {
            # $reversedByte = [byte]0
            <# for ($i = 0; $i -lt 8; $i++) {
                $reversedByte = $reversedByte -bor (($byte -shr $i -band 1) -shl (7 - $i))
            } #>
            # Left nibble <-> Right nibble
            $leftBits = $byte -shl 4 -band 0xF0
            $rightBits = $byte -shr 4 -band 0x0F
            $reversedByte = $leftBits -bor $rightBits

            Show-Step -Step $bytecount -Byte1 $byte -Byte2 $reversedByte | Write-Debug
            $reversedBytes[$bytecount] = $reversedByte
            $bytecount++
        }

        if ($ParamSet -eq 'Guid') {
            Write-Verbose " ${FunctionName}: Outputting $($reversedBytes.Count) bytes as GUID"
            return [Guid]::new($reversedBytes)
        }
        elseif ($ParamSet -eq 'Bytes') {
            Write-Verbose " ${FunctionName}: Outputting $($reversedBytes.Count) bytes as $($reversedBytes.GetType().Name)"
            return ,$reversedBytes
            # Write-Output (,$reversedBytes)
        }
    }
}
