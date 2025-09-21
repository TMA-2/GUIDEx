# Flips GUID byte array between little- and big-endianness

function Convert-UUIDBytes {
    [Alias('Convert-GUIDBytes','cvgb')]
    [OutputType([byte[]])]
    Param(
        [Parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline
        )]
        [ValidateCount(16,16)]
        [byte[]]$GUID,

        [ValidateSet('Class','ShortOrder','LongOrder')]
        $Method = 'ShortOrder'
    )

    Process {
        $Timer = [System.Diagnostics.Stopwatch]::StartNew()
        switch ($Method) {
            'Class' {
                # method 1: create new GUID, return as byte[] with bigendian = True
                if ($PSEdition -eq 'Core') {
                    $ReturnBytes = [guid]::new($GUID, $global:LITTLEENDIAN).ToByteArray()
                } else {
                    Throw [System.PlatformNotSupportedException]::new('GUID constructor overload is only available in PowerShell Core.')
                }
            }
            'ShortOrder' {
                # method 2: constructing the bytes in order
                [byte[]]$ReturnBytes = $GUID[3..0] + $GUID[5..4] + $GUID[7..6] + $GUID[8..15]
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
                $ReturnBytes = $GUID
            }
        }

        $Timer.Stop()
        "Method {0} took {1:d3}ms" -f $Method,$Timer.ElapsedMilliseconds | Write-Verbose

        Return $ReturnBytes
    }
} # Convert-UUIDBytes()
