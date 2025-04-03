function Convert-BinaryLSB {
    # [OutputType(ParameterSetName = 'Byte', [byte])]
    [OutputType(ParameterSetName = 'Bytes', [byte[]])]
    [OutputType(ParameterSetName = 'Guid', [Guid])]
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

    Begin {
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

            '{0}: 0x{1:X2} -> 0x{2:X2}; 0b{3} -> 0b{4}' -f $Step, $Byte1, $Byte2, $Byte1Fmt, $Byte2Fmt
        }
    }

    process {
        if ($ParamSet -eq 'Guid') {
            $Bytes = $Guid.ToByteArray()
            <# if($LITTLE_ENDIAN) {
                $Bytes = [byte[]]$Bytes[3..0] + [byte[]]$Bytes[5..4] + [byte[]]$Bytes[7..6] + [byte[]]$Bytes[8..15]
            } #>
        }

        $bytecount = 0
        $reversedBytes = [byte[]]::new($Bytes.Length)

        foreach ($byte in $bytes) {
            $reversedByte = [byte]0
            <# for ($i = 0; $i -lt 8; $i++) {
                $reversedByte = $reversedByte -bor (($byte -shr $i -band 1) -shl (7 - $i))
            } #>
            $LeftBits = $byte -shl 4 -band 0xF0
            $RightBits = $byte -shr 4 -band 0x0F
            $reversedByte = $LeftBits -bor $RightBits
            
            Show-Step -Step $bytecount -Byte1 $byte -Byte2 $reversedByte | Write-Verbose
            $reversedBytes[$bytecount] = $reversedByte
            $bytecount++
        }

        if ($ParamSet -eq 'Guid') {
            return [Guid]::new($reversedBytes)
        } elseif ($ParamSet -eq 'Bytes') {
            return $reversedBytes
        }
    }
}
