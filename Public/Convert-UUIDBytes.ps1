# Flips GUID byte array between little- and big-endianness
# TODO: Test performance vs. ByteswapGuid()
# TODO: Combine with Convert-UUID, adding a [bytes[]] pipeline parameter (if [guid] doesn't automatically convert)
# DONE: STANDARDIZE FUNC
#   [x]: PARAM BLOCK
#   [x]: PIPELINE SUPPORT
#   [x]: PROCESS BLOCK
function Convert-UUIDBytes {
    [Alias('Convert-GUIDBytes','cvgb')]
    [OutputType([byte[]])]
    Param(
        [Parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline
        )]
        [byte[]]$GUID,
        [ValidateSet('Class','ShortOrder','LongOrder')]
        $Method = 'ShortOrder'
    )

    Process {
        switch ($Method) {
            'Class' {
                # method 1: create new GUID, return as byte[] with bigendian = True
                if ($PSEdition -eq 'Core') {
                    $NewGUID = [guid]::new($GUID, $script:LITTLEENDIAN)
                } else {
                    Throw [System.PlatformNotSupportedException]::new('GUID constructor overload is only available in PowerShell Core.')
                }
            }
            'ShortOrder' {
                # method 2: constructing the bytes in order
                [byte[]]$NewGUID = $GUID[3..0] + $GUID[5..4] + $GUID[7..6] + $GUID[8..15]
                $NewGUID = [guid]::new($NewGUID)
            }
            'LongOrder' {
                # method 3: laborious, hard-to-follow method
                # swap 1st and 4th bytes
                [byte]$temp = $GUID[0]
                $GUID[0] = $GUID[3]
                $GUID[3] = $temp
                # swap 2nd and 3rd bytes
                $temp = $GUID[1]
                $GUID[1] = $GUID[2]
                $GUID[2] = $temp
                # swap 5th and 6th bytes
                $temp = $GUID[4]
                $GUID[4] = $GUID[5]
                $GUID[5] = $temp
                # swap 7th and 8th bytes
                $temp = $GUID[6]
                $GUID[6] = $GUID[7]
                $GUID[7] = $temp
                $NewGUID = $GUID
            }
        }

        # "Method {0} took {1:n3}ms" -f $Method,$Timer.TotalMilliseconds | Write-Host
        Return $NewGUID
    }
} # BSGUID()
