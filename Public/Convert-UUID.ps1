using namespace System
using namespace System.Management.Automation

function Convert-UUID {
    [Alias('Convert-GUID','cvg')]
    [OutputType([Guid])]
    [CmdletBinding()]
    Param(
        [Parameter(
            Position = 0,
            ValueFromPipelineByPropertyName
        )]
        [object]
        $InputObject,

        # performs a nibble swap on each byte
        [switch]
        $Reverse,

        [switch]
        $RespectBitOrder
    )

    begin {
        $FunctionName = $MyInvocation.MyCommand.Name
    }

    process {
        # create temp var to work with and check data type
        Write-Verbose "${FunctionName}: Type = $($InputObject.GetType())"

        if ($InputObject -is [guid]) {
            # convert GUID to bytearray first
            $TempVar = $InputObject.ToByteArray()
        } elseif ($InputObject -is [byte[]]) {
            $TempVar = $InputObject
            # check byte length
            if ($TempVar.Length -ne 16) {
                Throw [System.Management.Automation.ErrorRecord]::new([System.TypeLoadException]::new("Unexpected byte[] length of $($TempVar.Length) != 16."), 3,'InvalidData', $InputObject)
            }
        } else {
            Throw [System.Management.Automation.ErrorRecord]::new([System.TypeLoadException]::new("Unexpected data type $($InputObject.GetType()) != Byte[] or Guid."), 4,'InvalidType', $InputObject)
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

        Write-Verbose "Setting [$($GUID.GetType())]`$GUID = the modified byte array..."
        # update passed reference with new value
        if ($GUID -is [guid]) {
            # create new GUID and set to the passed var
            if ($Reverse) {
                # FIXME: $GUIDBytes is null with no other args
                $GUID = [guid]::new($GUIDInt32, $GUIDInt16A, $GUIDInt16B, $GUIDBytes)
            } else {
                $GUID = [guid]::new($TempBytes)
            }
        } else {
            # otherwise, just assign the swapped byte array
            $GUID = $TempBytes
        }
        $GUID
    }
} # ByteswapGuid()
