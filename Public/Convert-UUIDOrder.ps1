function Convert-UUIDOrder {
    [OutputType([guid])]
    [Alias('Convert-GUIDOrder', 'cvgo')]
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory,
            Position=0,
            ValueFromPipeline
        )]
        [guid]$GUID
    )

    Begin {
        $LITTLE_ENDIAN = [BitConverter]::IsLittleEndian
        $ConvertedBytes = [byte[]]::new(16)
    }

    Process {
        $Bytes = $GUID.ToByteArray()
        if ($LITTLE_ENDIAN) {
            # Reverse the byte order for little-endian systems
            [Array]::Reverse($Bytes, 0, 4)
            [Array]::Reverse($Bytes, 4, 2)
            [Array]::Reverse($Bytes, 6, 2)
        }

        for($i = 0; $i -lt 16; $i++) {
            $ByteHI = [byte]($Bytes[$i] -shl 4 -band 0xF0)
            $ByteLO = [byte]($Bytes[$i] -shr 4 -band 0x0F)
            $ConvertedBytes[$i] = $ByteHI -bor $ByteLO
        }

        $ConvertedGUID = [guid]::new($ConvertedBytes)

        Return $ConvertedGUID
    }
}
