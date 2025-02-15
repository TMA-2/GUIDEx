function Convert-BinaryLSB {
    [OutputType(ParameterSetName = 'Byte', [byte[]])]
    [OutputType(ParameterSetName = 'Guid', [Guid])]
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline,
            ParameterSetName = 'Byte'
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

            '{0}: {1:X2} -> {2:X2}; 0b{3} -> 0b{4}' -f $Step, $Byte1, $Byte2, $Byte1Fmt, $Byte2Fmt
        }
    }

    process {
        if ($ParamSet -eq 'Guid') {
            $Bytes = $Guid.ToByteArray()
        }

        $reversedBytes = @()
        foreach ($byte in $bytes) {
            $reversedByte = [byte]0
            for ($i = 0; $i -lt 8; $i++) {
                # ex: 0xF8 -> 0x8F
                $reversedByte = $reversedByte -bor (($byte -shr $i -band 1) -shl (7 - $i))
                Show-Step -Step $i -Byte1 $byte -Byte2 $reversedByte | Write-Verbose
            }
            $reversedBytes += $reversedByte
        }

        if ($ParamSet -eq 'Guid') {
            return [Guid]::NewGuid($reversedBytes)
        } elseif ($ParamSet -eq 'Byte') {
            return $reversedBytes
        }
    }
}
