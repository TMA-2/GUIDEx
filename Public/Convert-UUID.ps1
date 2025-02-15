# P1: Test functionality (Pester?)
# BUG: creating a guid from byte[] with manually swapped order un-swaps it...
#   in PS 5.1, or in PS7 if BigEndian = False
# TODO: Verify [ref] works as expected
# TODO: Test performance vs. Convert-UUIDBytes
# TODO: Add option to convert to... whatever the MSI Installer product GUID order is
# TODO: STANDARDIZE
#   [x]: PARAM BLOCK
#   [ ]: PIPELINE SUPPORT
#   [x]: PROCESS BLOCK
function Convert-UUID {
    [Alias('Convert-GUID','cvud')]
    [OutputType([System.Guid])]
    [CmdletBinding()]
    Param(
        [Parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName
        )]
        [ref]
        $GUID,
        # swaps the low/high 4-bit order of bytes
        [switch]
        $Reverse,
        [switch]
        $RespectBitOrder
    )

    Process {
        # create temp var to work with and check data type
        Write-Verbose "Convert-GUIDBytes - Type = $($GUID.Value.GetType())"

        if ($GUID.Value -is [guid]) {
            # convert GUID to bytearray first
            $TempVar = $GUID.Value.ToByteArray()
        } elseif ($GUID.Value -is [byte[]]) {
            $TempVar = $GUID.Value
            # check byte length
            if ($TempVar.Length -ne 16) {
                Throw [System.Management.Automation.ErrorRecord]::new([System.TypeLoadException]::new("Unexpected byte[] length of $($TempVar.Length) != 16."), 3,'InvalidData', $GUID.Value)
            }
        } else {
            Throw [System.Management.Automation.ErrorRecord]::new([System.TypeLoadException]::new("Unexpected data type $($GUID.Value.GetType()) != Byte[] or Guid."), 4,'InvalidType', $GUID.Value)
        }

        # easy method
        # reverse first 4 bytes, next 2 by 2, and append the last 8 normally
        if ($Reverse) {
            Write-Verbose "-Reverse specified. Creating low/high swapped bytes according to LE = $script:LITTLEENDIAN"
            if ($SCRIPT:LITTLEENDIAN -and $RespectBitOrder) {
                # [guid] will reverse the order if LE, it seems
                [byte[]]$TempBytes = $TempVar | Convert-Byte
            } else {
                # reverse manually if BE
                $TempBytes = [byte[]]::new(0)
                # For [guid]::New(int32, int16, int16, byte[]) method so the damn order is respected
                [UInt32]$GUIDInt32 = 0
                [UInt16]$GUIDInt16A = 0
                [UInt16]$GUIDInt16B = 0
                $Position = 0
                $TempVar[0..3] | Convert-Byte | ForEach-Object {
                    $Mask = $Position * 8
                    $GUIDInt32 += $PSItem -shl $Mask
                    $Position++
                }
                $Position = 0
                $TempVar[4..5] | Convert-Byte | ForEach-Object {
                    $Mask = $Position * 8
                    $GUIDInt16A += $PSItem -shl $Mask
                    $Position++
                }
                $Position = 0
                $TempVar[6..7] | Convert-Byte | ForEach-Object {
                    $Mask = $Position * 8
                    $GUIDInt16B += $PSItem -shl $Mask
                    $Position++
                }
                [Byte[]]$GUIDBytes = $TempVar[8..15]

                # $TempBytes += $TempVar[3..0] | Convert-Byte
                # $TempBytes += $TempVar[5..4] | Convert-Byte
                # $TempBytes += $TempVar[7..6] | Convert-Byte
                # $TempBytes += $TempVar[8..15] | Convert-Byte
            }
        } else {
            Write-Verbose "Creating bytes according to LE = $script:LITTLEENDIAN"
            if ($SCRIPT:LITTLEENDIAN -and $RespectBitOrder) {
                # [guid] will reverse the order if LE, it seems
                [byte[]]$TempBytes = $TempVar
            } else {
                # reverse manually if BE
                [byte[]]$TempBytes = $TempVar[3..0] + $TempVar[5..4] + $TempVar[7..6] + $TempVar[8..15]
            }
        }

        Write-Verbose "Setting [$($GUID.Value.GetType())]`$GUID = the modified byte array..."
        # update passed reference with new value
        if ($GUID.Value -is [guid]) {
            # create new GUID and set to the passed var
            if ($RespectBitOrder) {
                $GUID.Value = [guid]::new($TempBytes)
            } else {
                $GUID.Value = [guid]::new($GUIDInt32, $GUIDInt16A, $GUIDInt16B, $GUIDBytes)
            }
        } else {
            # otherwise, just assign the swapped byte array
            $GUID.Value = $TempBytes
        }
    }
} # ByteswapGuid()
