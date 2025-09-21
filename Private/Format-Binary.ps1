function Format-Binary {
    Param(
        [Parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline)]
        [byte[]]$Bytes
    )

    foreach($Byte in $Bytes) {
        $ConvertedByte = '0b' + [convert]::ToString($Byte, 2).PadLeft(8, '0')
        $ConvertedHex = '0x' + [convert]::ToString($Byte, 16).PadLeft(2, '0').ToUpper()
        Write-Output "$ConvertedHex - $ConvertedByte"
    }
}
